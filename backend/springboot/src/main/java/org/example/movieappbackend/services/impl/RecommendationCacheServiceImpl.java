package org.example.movieappbackend.services.impl;

import lombok.extern.slf4j.Slf4j;
import org.example.movieappbackend.entities.Movie;
import org.example.movieappbackend.entities.Recommendation;
import org.example.movieappbackend.entities.User;
import org.example.movieappbackend.exceptions.ResourceNotFoundException;
import org.example.movieappbackend.payloads.MovieDto;
import org.example.movieappbackend.payloads.MovieRecommendationDto;
import org.example.movieappbackend.payloads.RecommendationResponseDto;
import org.example.movieappbackend.repositories.MovieRepo;
import org.example.movieappbackend.repositories.RecommendationRepo;
import org.example.movieappbackend.services.RecommendationCacheService;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.parameters.P;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Slf4j
public class RecommendationCacheServiceImpl implements RecommendationCacheService {

    @Autowired
    private RecommendationRepo recommendationRepo;

    @Autowired
    private MovieRepo movieRepo;

    @Autowired
    private ModelMapper modelMapper;

    @Value("${recommendation.cache.hours:24}")
    private int cacheHours;

    @Override
    @Transactional
    public void saveRecommendationsToCache(Long userId, RecommendationResponseDto mlRecommendations) {
        log.info("Saving recommendations to cache for user {}", userId);

        // Clear old cached recommendations
        recommendationRepo.deleteAllByUserId(userId);

        List<Long> movieIds = mlRecommendations.getRecommendations().stream().map(MovieDto::getId).collect(Collectors.toList());

        Map<Long, Movie> movieMap = this.movieRepo.findAllById(movieIds).stream().collect(Collectors.toMap(Movie::getId, Function.identity()));

        User userRef = new User();
        userRef.setId(userId);

        List<Recommendation> recommendations = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (MovieDto mlRec : mlRecommendations.getRecommendations()) {
            // Optional<Movie> movieOpt = movieRepo.findById(mlRec.getId());

            Movie movie = movieMap.get(mlRec.getId());

//            if (movieOpt.isEmpty()) {
//                log.warn("Movie {} not found in database", mlRec.getId());
//                continue;
//            }

            if(movie == null) {
                log.warn("Movie {} not found in database", mlRec.getId());
                continue;
            }

//            User user = new User();
//            user.setId(userId);

            Recommendation rec = new Recommendation();
            rec.setUser(userRef);
            rec.setMovie(movie);
            rec.setCachedAt(now);
            rec.setPredictedScore(mlRec.getPredictedScore());

            recommendations.add(rec);
        }

        recommendationRepo.saveAll(recommendations);
        log.info("Saved {} recommendations to cache for user {}", recommendations.size(), userId);
    }

    @Override
    public RecommendationResponseDto getCachedRecommendations(Long userId) {
        log.info("Fetching cached recommendations for user: {}", userId);

        List<Recommendation> cached = recommendationRepo.findByUserIdOrderByPredictedScoreDesc(userId);

        if (cached.isEmpty()) {
            log.warn("No cached recommendations found for user {}", userId);
            return null; // Let main service handle fallback
        }

        // ✅ FIXED: Complete the mapping from Recommendation to MovieDto
        List<MovieDto> recDTOs = cached.stream()
                .map(recommendation -> {
                    Movie movie = recommendation.getMovie();
                    // This will include posterUrl from the Movie entity
                    MovieDto dto = modelMapper.map(movie, MovieDto.class);
                    dto.setPredictedScore(recommendation.getPredictedScore());
                    return dto;
                })
                .collect(Collectors.toList());

        RecommendationResponseDto response = new RecommendationResponseDto();
        response.setUserId(userId.intValue());
        response.setRecommendations(recDTOs);

        return response;
    }

    @Override
    public boolean isCacheValid(Long userId) {
        List<Recommendation> cachedRecs = recommendationRepo.findByUserId(userId);

        if (cachedRecs.isEmpty()) {
            log.info("No cached recommendations found for user {}", userId);
            return false;
        }

        // Check the timestamp of the first cached recommendation
        LocalDateTime cachedAt = cachedRecs.get(0).getCachedAt();
        if (cachedAt == null) {
            log.info("Cached recommendations for user {} have no timestamp — invalidating cache", userId);
            return false;
        }

        long hoursSinceCached = Duration.between(cachedAt, LocalDateTime.now()).toHours();
        boolean valid = hoursSinceCached < cacheHours; // cacheHours = e.g. 24

        log.info("Cache for user {} valid: {} ({} hours old)", userId, valid, hoursSinceCached);

        return valid;
    }
}