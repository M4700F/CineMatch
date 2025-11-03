package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.RatingDto;

import java.util.List;

public interface RatingService {
    RatingDto addRating(Long userId, Long movieId, double score);
    List<RatingDto> getMyRatings();
}
