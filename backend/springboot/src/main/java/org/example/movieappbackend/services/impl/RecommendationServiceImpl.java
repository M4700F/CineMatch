package org.example.movieappbackend.services.impl;

import lombok.extern.slf4j.Slf4j;
import org.example.movieappbackend.entities.Movie;
import org.example.movieappbackend.entities.Rating;
import org.example.movieappbackend.payloads.*;
import org.example.movieappbackend.repositories.MovieRepo;
import org.example.movieappbackend.repositories.RatingRepo;
import org.example.movieappbackend.services.RecommendationCacheService;
import org.example.movieappbackend.services.RecommendationService;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Slf4j
public class RecommendationServiceImpl implements RecommendationService {
    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private RatingRepo ratingRepo;

    @Autowired
    private MovieRepo movieRepo;

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private RecommendationCacheService recommendationCacheService;

    @Value("${fastapi.base-url}")
    private String fastApiBaseUrl;


    @Override
    public RecommendationResponseDto getRecommendationsForUser(Long userId) {
        log.info("Getting recommendations for user: {}", userId);

        // ✅ Step 1: Check if cached recommendations exist and are still valid
        if (recommendationCacheService.isCacheValid(userId)) {
            log.info("Returning cached recommendations for user {}", userId);
            return recommendationCacheService.getCachedRecommendations(userId);
        }

        // Get user's ratings
        List<Rating> userRatings = ratingRepo.findByUserId(userId);

        if (userRatings.isEmpty()) {
            log.info("User {} has no ratings, returning popular movies", userId);
            return getPopularMoviesAsRecommendations(userId);
        }

        // Call FastAPI
        try {
            // Convert ratings to DTO
            List<UserRatingDto> ratingDTOs = userRatings.stream()
                    .map(r -> new UserRatingDto(
                            r.getMovie().getId().intValue(),
                            r.getScore()
                    ))
                    .collect(Collectors.toList());

            RecommendationRequestDto request = new RecommendationRequestDto();
            request.setUserId(userId.intValue());
            request.setUserRatings(ratingDTOs);
            request.setTopN(10);

            String url = fastApiBaseUrl + "/recommend";

            log.info("Calling FastAPI at: {}", url);

            ResponseEntity<Map> response = restTemplate.postForEntity(
                    url,
                    request,
                    Map.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                List<Map<String, Object>> recommendations =
                        (List<Map<String, Object>>) response.getBody().get("recommendations");

                if (recommendations != null && !recommendations.isEmpty()) {
                    // ✅ OPTIMIZED: Extract movie IDs and scores first
                    Map<Long, Double> movieIdToScore = new HashMap<>();
                    List<Long> movieIds = new ArrayList<>();

                    for (Map<String, Object> rec : recommendations) {
                        Integer movieId = (Integer) rec.get("movie_id");
                        if (movieId == null) {
                            movieId = (Integer) rec.get("movieId");
                        }

                        if (movieId != null) {
                            Long mid = movieId.longValue();
                            movieIds.add(mid);

                            // Extract predicted_score
                            Object scoreObj = rec.get("predicted_score");
                            if (scoreObj instanceof Number) {
                                movieIdToScore.put(mid, ((Number) scoreObj).doubleValue());
                            }
                        }
                    }

                    // ✅ Fetch ALL movies in ONE query
                    Map<Long, Movie> movieMap = movieRepo.findAllById(movieIds).stream()
                            .collect(Collectors.toMap(Movie::getId, Function.identity()));

                    // ✅ Build DTOs using the pre-fetched movies
                    List<MovieDto> enrichedMovies = movieIds.stream()
                            .map(movieId -> {
                                Movie movie = movieMap.get(movieId);
                                if (movie == null) return null;

                                MovieDto dto = modelMapper.map(movie, MovieDto.class);
                                dto.setPredictedScore(movieIdToScore.get(movieId));
                                return dto;
                            })
                            .filter(Objects::nonNull)
                            .collect(Collectors.toList());

                    RecommendationResponseDto dto = new RecommendationResponseDto(
                            userId.intValue(),
                            enrichedMovies
                    );

                    this.recommendationCacheService.saveRecommendationsToCache(userId, dto);

                    return dto;
                }
            }

        } catch (Exception e) {
            log.error("Error calling FastAPI for user {}: {}", userId, e.getMessage());
            e.printStackTrace();
            // Fallback to cached recommendations
            RecommendationResponseDto cached = this.recommendationCacheService.getCachedRecommendations(userId);
            if (cached != null) {
                return cached;
            }
        }

        return getPopularMoviesAsRecommendations(userId);
    }

    /**
     * Get recommendations for new user based on genre preferences
     */
    @Override
    public RecommendationResponseDto getRecommendationsForNewUser(Long userId, NewUserPreferencesDto preferencesDto) {
        log.info("Getting recommendations for new user: {}", userId);

        try {
            RecommendationRequestDto request = new RecommendationRequestDto();
            request.setUserId(userId.intValue());
            request.setNewUserPreferences(preferencesDto);
            request.setTopN(10);

            String url = fastApiBaseUrl + "/recommend";

            ResponseEntity<Map> response = restTemplate.postForEntity(
                    url,
                    request,
                    Map.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                List<Map<String, Object>> recommendations =
                        (List<Map<String, Object>>) response.getBody().get("recommendations");

                if (recommendations != null && !recommendations.isEmpty()) {
                    // ✅ OPTIMIZED: Extract movie IDs and scores first
                    Map<Long, Double> movieIdToScore = new HashMap<>();
                    List<Long> movieIds = new ArrayList<>();

                    for (Map<String, Object> rec : recommendations) {
                        Integer movieId = (Integer) rec.get("movie_id");
                        if (movieId == null) {
                            movieId = (Integer) rec.get("movieId");
                        }

                        if (movieId != null) {
                            Long mid = movieId.longValue();
                            movieIds.add(mid);

                            // Extract predicted_score
                            Object scoreObj = rec.get("predicted_score");
                            if (scoreObj instanceof Number) {
                                movieIdToScore.put(mid, ((Number) scoreObj).doubleValue());
                            }
                        }
                    }

                    // ✅ Fetch ALL movies in ONE query
                    Map<Long, Movie> movieMap = movieRepo.findAllById(movieIds).stream()
                            .collect(Collectors.toMap(Movie::getId, Function.identity()));

                    // ✅ Build DTOs using the pre-fetched movies
                    List<MovieDto> enrichedMovies = movieIds.stream()
                            .map(movieId -> {
                                Movie movie = movieMap.get(movieId);
                                if (movie == null) return null;

                                MovieDto dto = modelMapper.map(movie, MovieDto.class);
                                dto.setPredictedScore(movieIdToScore.get(movieId));
                                return dto;
                            })
                            .filter(Objects::nonNull)
                            .collect(Collectors.toList());

                    RecommendationResponseDto dto = new RecommendationResponseDto(userId.intValue(), enrichedMovies);

                    /*
                     * Cache the preference-based recommendations
                     */
                    this.recommendationCacheService.saveRecommendationsToCache(userId, dto);

                    return dto;
                }
            }

        } catch (Exception e) {
            log.error("Error getting recommendations for new user: {}", e.getMessage());
            e.printStackTrace();
        }

        return getPopularMoviesAsRecommendations(userId);
    }



    @Override
    public RecommendationResponseDto getPopularMoviesAsRecommendations(Long userId) {
        log.info("Returning popular movies for user: {}", userId);

        List<Movie> popularMovies = movieRepo.findTop10Movies();

        List<MovieDto> movieDtos = popularMovies.stream()
                .map(movie -> modelMapper.map(movie, MovieDto.class))
                .collect(Collectors.toList());

        return new RecommendationResponseDto(userId.intValue(), movieDtos);
    }

    @Override
    public List<MovieDto> getSimilarMovies(Long movieId, int topN) {
        log.info("Getting similar movies for movie: {}", movieId);
        try {
            String url = fastApiBaseUrl + "/similar-movies/" + movieId + "?top_n=" + topN;

            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                List<Map<String, Object>> similarMovies =
                        (List<Map<String, Object>>) response.getBody().get("similar_movies");

                if (similarMovies != null && !similarMovies.isEmpty()) {
                    // ✅ OPTIMIZED: Extract all movie IDs first
                    List<Long> movieIds = similarMovies.stream()
                            .map(movie -> {
                                Integer mid = (Integer) movie.get("movie_id");
                                if (mid == null) {
                                    mid = (Integer) movie.get("movieId");
                                }
                                return mid != null ? mid.longValue() : null;
                            })
                            .filter(Objects::nonNull)
                            .collect(Collectors.toList());

                    // ✅ Fetch ALL movies in ONE query
                    Map<Long, Movie> movieMap = movieRepo.findAllById(movieIds).stream()
                            .collect(Collectors.toMap(Movie::getId, Function.identity()));

                    // ✅ Build DTOs maintaining order
                    return movieIds.stream()
                            .map(mid -> {
                                Movie m = movieMap.get(mid);
                                return m != null ? modelMapper.map(m, MovieDto.class) : null;
                            })
                            .filter(Objects::nonNull)
                            .collect(Collectors.toList());
                }
            }

        } catch (Exception e) {
            log.error("Error getting similar movies: {}", e.getMessage());
            e.printStackTrace();
        }

        return Collections.emptyList();
    }
}