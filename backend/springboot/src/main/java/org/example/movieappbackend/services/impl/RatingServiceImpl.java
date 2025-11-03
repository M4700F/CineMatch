package org.example.movieappbackend.services.impl;

import org.example.movieappbackend.entities.Movie;
import org.example.movieappbackend.entities.Rating;
import org.example.movieappbackend.entities.User;
import org.example.movieappbackend.exceptions.ApiException;
import org.example.movieappbackend.exceptions.ResourceNotFoundException;
import org.example.movieappbackend.payloads.RatingDto;
import org.example.movieappbackend.repositories.MovieRepo;
import org.example.movieappbackend.repositories.RatingRepo;
import org.example.movieappbackend.repositories.UserRepo;
import org.example.movieappbackend.services.RatingService;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class RatingServiceImpl implements RatingService {
    @Autowired
    private UserRepo userRepo;

    @Autowired
    private MovieRepo movieRepo;

    @Autowired
    private RatingRepo ratingRepo;

    @Autowired
    private ModelMapper modelMapper;

    @Override
    public RatingDto addRating(Long userId, Long movieId, double score) {
        if (score < 0.5 || score > 5.0) {
            throw new ApiException("Score must be between 0.5 and 5.0");
        }

        Optional<Rating> existingRating = this.ratingRepo.findByUserIdAndMovieId(userId, movieId);
        if(existingRating.isPresent()){
            Rating rating = existingRating.get();
            rating.setScore(score);
            Rating updated = this.ratingRepo.save(rating);
            return this.modelMapper.map(updated, RatingDto.class);
        }

        User user = this.userRepo.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User", "Id", userId));
        Movie movie = this.movieRepo.findById(movieId).orElseThrow(() -> new ResourceNotFoundException("Movie", "Id", movieId));

        Rating rating = new Rating();

        rating.setUser(user);
        rating.setMovie(movie);
        rating.setScore(score);

        Rating savedRating = ratingRepo.save(rating);

        return this.modelMapper.map(savedRating, RatingDto.class);

    }

    @Override
    public List<RatingDto> getMyRatings() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();

        User user = this.userRepo.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("User", "email " + email, 0));
        List<Rating> ratings = this.ratingRepo.findByUserId(user.getId());
        return ratings.stream().map(rating -> this.modelMapper.map(rating, RatingDto.class)).toList();
    }
}
