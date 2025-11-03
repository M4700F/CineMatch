package org.example.movieappbackend.controllers;

import org.example.movieappbackend.payloads.MoodDiscoveryRequest;
import org.example.movieappbackend.payloads.MoodDiscoveryResponse;
import org.example.movieappbackend.services.MoodDiscoveryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/mood-discovery")
@CrossOrigin(origins = "*")
public class MoodDiscoveryController {

    private static final Logger logger = LoggerFactory.getLogger(MoodDiscoveryController.class);

    @Autowired
    private MoodDiscoveryService moodDiscoveryService;

    /**
     * Get movie recommendations based on mood
     * POST /api/mood-discovery
     */
    @PostMapping
    public ResponseEntity<?> discoverByMood(@RequestBody MoodDiscoveryRequest request) {
        try {
            logger.info("Received mood discovery request for mood: {}", request.getMood());

            // Validate request
            if (request.getMood() == null || request.getMood().trim().isEmpty()) {
                logger.warn("Empty mood received");
                Map<String, String> errorResponse = new HashMap<>();
                errorResponse.put("error", "Mood cannot be empty");
                return ResponseEntity.badRequest().body(errorResponse);
            }

            // Get recommendations from service
            MoodDiscoveryResponse response = moodDiscoveryService.getMoviesByMood(request);

            logger.info("Successfully generated {} movie recommendations for mood: {}",
                    response.getMovies().size(), request.getMood());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("Error processing mood discovery request", e);
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to get movie recommendations: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Get available moods
     * GET /api/mood-discovery/moods
     */
    @GetMapping("/moods")
    public ResponseEntity<?> getAvailableMoods() {
        try {
            Map<String, Object> response = new HashMap<>();
            response.put("moods", java.util.List.of(
                    "happy", "romantic", "thrilling", "mysterious",
                    "adventurous", "chill", "emotional", "inspired"
            ));
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error getting moods", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "ok");
        response.put("service", "Mood Discovery API");
        return ResponseEntity.ok(response);
    }
}