package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.GeminiRequest;
import org.example.movieappbackend.payloads.GeminiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.List;


@Service
public class GeminiService {
    private static final Logger logger = LoggerFactory.getLogger(GeminiService.class);

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    private final RestTemplate restTemplate;

    public GeminiService() {
        this.restTemplate = new RestTemplate();
    }

    public String generateResponse(String userMessage) {
        try {
            // Add movie-specific context to the prompt
            String enhancedPrompt = buildMovieContextPrompt(userMessage);

            // Build request for Gemini API
            GeminiRequest.Part part = new GeminiRequest.Part(enhancedPrompt);
            GeminiRequest.Content content = new GeminiRequest.Content(List.of(part));
            GeminiRequest request = new GeminiRequest(List.of(content));

            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // Create request entity
            HttpEntity<GeminiRequest> entity = new HttpEntity<>(request, headers);

            // Build URL with API key
            String urlWithKey = apiUrl + "?key=" + apiKey;

            logger.debug("Sending request to Gemini API: {}", urlWithKey);
            logger.debug("Request body: {}", request);

            // Call Gemini API
            ResponseEntity<GeminiResponse> response = restTemplate.exchange(
                    urlWithKey,
                    HttpMethod.POST,
                    entity,
                    GeminiResponse.class
            );

            logger.debug("Gemini API response status: {}", response.getStatusCode());

            // Extract response text
            if (response.getBody() != null &&
                    response.getBody().getCandidates() != null &&
                    !response.getBody().getCandidates().isEmpty()) {

                GeminiResponse.Candidate firstCandidate = response.getBody().getCandidates().get(0);
                if (firstCandidate.getContent() != null &&
                        firstCandidate.getContent().getParts() != null &&
                        !firstCandidate.getContent().getParts().isEmpty()) {

                    String responseText = firstCandidate.getContent().getParts().get(0).getText();
                    logger.debug("Extracted response text: {}", responseText);
                    return responseText;
                }
            }

            logger.warn("No valid response from Gemini API");
            return "I apologize, but I couldn't generate a response. Please try again.";

        } catch (HttpClientErrorException e) {
            logger.error("Client error calling Gemini API: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            return "I encountered an error processing your request. Please check your API key and try again.";
        } catch (HttpServerErrorException e) {
            logger.error("Server error calling Gemini API: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            return "The AI service is temporarily unavailable. Please try again later.";
        } catch (Exception e) {
            logger.error("Unexpected error calling Gemini API", e);
            return "An unexpected error occurred. Please try again.";
        }
    }

    private String buildMovieContextPrompt(String userMessage) {
        // Add context to make Gemini focus on movies
        return "You are a knowledgeable and friendly movie assistant AI named Gemini. " +
                "You help users discover movies, provide recommendations, discuss plots, actors, directors, and everything related to cinema. " +
                "Always be enthusiastic about movies and provide detailed, helpful responses. " +
                "If asked about topics unrelated to movies, gently redirect the conversation back to cinema while still being helpful.\n\n" +
                "User: " + userMessage + "\n\n" +
                "Assistant:";
    }
}
