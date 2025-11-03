package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.GeminiRequest;
import org.example.movieappbackend.payloads.GeminiResponse;
import org.example.movieappbackend.payloads.MoodDiscoveryRequest;
import org.example.movieappbackend.payloads.MoodDiscoveryResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class MoodDiscoveryService {

    private static final Logger logger = LoggerFactory.getLogger(MoodDiscoveryService.class);

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    private final RestTemplate restTemplate;

    public MoodDiscoveryService() {
        this.restTemplate = new RestTemplate();
    }

    public MoodDiscoveryResponse getMoviesByMood(MoodDiscoveryRequest request) {
        try {
            String mood = request.getMood();
            int count = request.getCount() != null ? request.getCount() : 10;

            // Build specialized prompt for movie recommendations
            String prompt = buildMoodPrompt(mood, count);

            // Call Gemini API
            String geminiResponse = callGeminiApi(prompt);

            // Parse movie recommendations from response
            List<MoodDiscoveryResponse.MovieRecommendation> movies = parseMovieRecommendations(geminiResponse);

            // Build response
            MoodDiscoveryResponse response = new MoodDiscoveryResponse();
            response.setMood(mood);
            response.setMovies(movies);
            response.setDescription(extractDescription(geminiResponse));

            return response;

        } catch (Exception e) {
            logger.error("Error getting movies by mood", e);
            throw new RuntimeException("Failed to get movie recommendations: " + e.getMessage());
        }
    }

    private String buildMoodPrompt(String mood, int count) {
        return String.format(
                "You are a movie recommendation expert. A user is feeling '%s' and wants movie suggestions.\n\n" +
                        "Please recommend exactly %d movies that perfectly match this mood. " +
                        "For each movie, provide:\n" +
                        "1. Movie title\n" +
                        "2. Release year\n" +
                        "3. Brief reason why it matches the '%s' mood (1-2 sentences)\n\n" +
                        "Format your response EXACTLY like this:\n\n" +
                        "Based on your '%s' mood, here are perfect movie recommendations:\n\n" +
                        "1. [Movie Title] (Year) - [Reason why it matches the mood]\n" +
                        "2. [Movie Title] (Year) - [Reason]\n" +
                        "...\n\n" +
                        "Be specific with movie titles and years. Focus on well-known, highly-rated films that truly capture the essence of feeling '%s'.",
                mood, count, mood, mood, mood
        );
    }

    private String callGeminiApi(String prompt) {
        try {
            // Build request
            GeminiRequest.Part part = new GeminiRequest.Part(prompt);
            GeminiRequest.Content content = new GeminiRequest.Content(List.of(part));
            GeminiRequest request = new GeminiRequest(List.of(content));

            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // Create request entity
            HttpEntity<GeminiRequest> entity = new HttpEntity<>(request, headers);

            // Build URL with API key
            String urlWithKey = apiUrl + "?key=" + apiKey;

            logger.debug("Calling Gemini API for mood discovery");

            // Call Gemini API
            ResponseEntity<GeminiResponse> response = restTemplate.exchange(
                    urlWithKey,
                    HttpMethod.POST,
                    entity,
                    GeminiResponse.class
            );

            // Extract response text
            if (response.getBody() != null &&
                    response.getBody().getCandidates() != null &&
                    !response.getBody().getCandidates().isEmpty()) {

                GeminiResponse.Candidate firstCandidate = response.getBody().getCandidates().get(0);
                if (firstCandidate.getContent() != null &&
                        firstCandidate.getContent().getParts() != null &&
                        !firstCandidate.getContent().getParts().isEmpty()) {

                    return firstCandidate.getContent().getParts().get(0).getText();
                }
            }

            throw new RuntimeException("No valid response from Gemini API");

        } catch (Exception e) {
            logger.error("Error calling Gemini API", e);
            throw new RuntimeException("Failed to call Gemini API: " + e.getMessage());
        }
    }

    private List<MoodDiscoveryResponse.MovieRecommendation> parseMovieRecommendations(String response) {
        List<MoodDiscoveryResponse.MovieRecommendation> movies = new ArrayList<>();

        try {
            // Pattern to match: number. Title (year) - description
            // Examples:
            // 1. The Shawshank Redemption (1994) - A powerful story...
            // 2. Forrest Gump (1994) - An inspiring journey...
            Pattern pattern = Pattern.compile(
                    "\\d+\\.\\s*([^(]+)\\s*\\((\\d{4})\\)\\s*[-–]\\s*(.+?)(?=\\n\\d+\\.|$)",
                    Pattern.DOTALL
            );

            Matcher matcher = pattern.matcher(response);

            while (matcher.find()) {
                String title = matcher.group(1).trim();
                String year = matcher.group(2).trim();
                String description = matcher.group(3).trim();

                MoodDiscoveryResponse.MovieRecommendation movie =
                        new MoodDiscoveryResponse.MovieRecommendation();
                movie.setTitle(title);
                movie.setYear(Integer.parseInt(year));
                movie.setDescription(description);
                movie.setReason(description); // Same as description for now

                movies.add(movie);

                logger.debug("Parsed movie: {} ({})", title, year);
            }

            // If parsing failed, try a simpler pattern
            if (movies.isEmpty()) {
                logger.warn("Primary pattern failed, trying fallback parsing");
                movies = parseFallback(response);
            }

        } catch (Exception e) {
            logger.error("Error parsing movie recommendations", e);
            // Return fallback movies if parsing fails
            movies = getFallbackMovies();
        }

        return movies;
    }

    private List<MoodDiscoveryResponse.MovieRecommendation> parseFallback(String response) {
        List<MoodDiscoveryResponse.MovieRecommendation> movies = new ArrayList<>();

        // Try to extract any movie titles with years
        Pattern simplePattern = Pattern.compile("([A-Z][^\\n(]{2,50})\\s*\\((\\d{4})\\)");
        Matcher matcher = simplePattern.matcher(response);

        while (matcher.find() && movies.size() < 10) {
            String title = matcher.group(1).trim();
            String year = matcher.group(2).trim();

            MoodDiscoveryResponse.MovieRecommendation movie =
                    new MoodDiscoveryResponse.MovieRecommendation();
            movie.setTitle(title);
            movie.setYear(Integer.parseInt(year));
            movie.setDescription("Recommended for your selected mood");
            movie.setReason("A great match for your current mood");

            movies.add(movie);
        }

        return movies;
    }

    private String extractDescription(String response) {
        // Extract the first paragraph or introduction line
        String[] lines = response.split("\\n");
        for (String line : lines) {
            line = line.trim();
            if (!line.isEmpty() && !line.matches("^\\d+\\..*") && line.length() > 20) {
                return line;
            }
        }
        return "Here are movie recommendations based on your mood.";
    }

    private List<MoodDiscoveryResponse.MovieRecommendation> getFallbackMovies() {
        // Fallback movies in case of parsing error
        List<MoodDiscoveryResponse.MovieRecommendation> movies = new ArrayList<>();

        MoodDiscoveryResponse.MovieRecommendation movie1 = new MoodDiscoveryResponse.MovieRecommendation();
        movie1.setTitle("The Shawshank Redemption");
        movie1.setYear(1994);
        movie1.setDescription("A timeless classic about hope and friendship");
        movies.add(movie1);

        MoodDiscoveryResponse.MovieRecommendation movie2 = new MoodDiscoveryResponse.MovieRecommendation();
        movie2.setTitle("Inception");
        movie2.setYear(2010);
        movie2.setDescription("A mind-bending thriller that will keep you engaged");
        movies.add(movie2);

        return movies;
    }
}
