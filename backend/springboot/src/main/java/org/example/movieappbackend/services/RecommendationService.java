package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.MovieDto;
import org.example.movieappbackend.payloads.MovieRecommendationDto;
import org.example.movieappbackend.payloads.NewUserPreferencesDto;
import org.example.movieappbackend.payloads.RecommendationResponseDto;

import java.util.List;

public interface RecommendationService {
    RecommendationResponseDto getRecommendationsForUser(Long userId);
    RecommendationResponseDto getRecommendationsForNewUser(Long userId, NewUserPreferencesDto preferencesDto);
    RecommendationResponseDto getPopularMoviesAsRecommendations(Long userId);
    List<MovieDto>getSimilarMovies(Long movieId, int topN);
}
