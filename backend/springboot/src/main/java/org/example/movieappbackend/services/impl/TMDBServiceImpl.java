package org.example.movieappbackend.services.impl;

import org.example.movieappbackend.services.TMDBService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Service
public class TMDBServiceImpl implements TMDBService {

    @Value("${tmdb.api.key}")
    private String apiKey;

    @Value("${tmdb.api.url}")
    private String baseUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public String fetchPosterURL(String movieTitle) {
        try {
            String encodedTitle = URLEncoder.encode(movieTitle, StandardCharsets.UTF_8);
            String url = String.format("%s/search/movie?api_key=%s&query=%s", baseUrl, apiKey, encodedTitle);

            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            var results = (java.util.List<Map<String, Object>>) response.get("results");

            if (results != null && !results.isEmpty()) {
                String posterPath = (String) results.get(0).get("poster_path");
                return "https://image.tmdb.org/t/p/w500" + posterPath;
            } else {
                return null; // no poster found
            }

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
