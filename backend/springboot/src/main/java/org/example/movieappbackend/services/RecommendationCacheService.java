package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.RecommendationResponseDto;

public interface RecommendationCacheService {
    void saveRecommendationsToCache(Long userId, RecommendationResponseDto mlRecommendations);
    RecommendationResponseDto getCachedRecommendations(Long userId);
    boolean isCacheValid(Long userId);
}
