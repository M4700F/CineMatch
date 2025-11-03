package org.example.movieappbackend.controllers;

import org.example.movieappbackend.payloads.ChatRequest;
import org.example.movieappbackend.services.GeminiService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*")
public class GeminiController {

    private static final Logger logger = LoggerFactory.getLogger(GeminiController.class);

    @Autowired
    private GeminiService geminiService;

    @PostMapping
    public ResponseEntity<Map<String, Object>> chat(@RequestBody ChatRequest request) {
        try {
            logger.info("Received chat request: {}", request.getMessage());

            // Validate request
            if (request.getMessage() == null || request.getMessage().trim().isEmpty()) {
                logger.warn("Empty message received");
                Map<String, Object> errorResponse = new HashMap<>();
                errorResponse.put("error", "Message cannot be empty");
                return ResponseEntity.badRequest().body(errorResponse);
            }

            // Get response from Gemini
            String geminiResponse = geminiService.generateResponse(request.getMessage());

            // Build response in format expected by Flutter app
            Map<String, Object> response = new HashMap<>();
            Map<String, String> responsePart = new HashMap<>();
            responsePart.put("text", geminiResponse);
            response.put("response", List.of(responsePart));

            logger.info("Successfully generated response");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("Error processing chat request", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Internal server error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "ok");
        response.put("service", "Gemini Chat API");
        return ResponseEntity.ok(response);
    }
}