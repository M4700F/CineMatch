package org.example.movieappbackend.controllers;

import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.example.movieappbackend.entities.Movie;
import org.example.movieappbackend.entities.Rating;
import org.example.movieappbackend.entities.User;
import org.example.movieappbackend.exceptions.ResourceNotFoundException;
import org.example.movieappbackend.payloads.RatingDto;
import org.example.movieappbackend.repositories.MovieRepo;
import org.example.movieappbackend.repositories.RatingRepo;
import org.example.movieappbackend.repositories.UserRepo;
import org.example.movieappbackend.services.RatingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/ratings")
@Slf4j
public class RatingController {

    @Autowired
    private RatingService ratingService;

    /**
     * Add or update a rating
     */
    @PostMapping("/{userId}/{movieId}/{score}")
    public ResponseEntity<RatingDto> addRating(@Valid
            @PathVariable("userId") Long userId,
            @PathVariable("movieId") Long movieId,
            @PathVariable("score") double score) {

        RatingDto ratingDto = this.ratingService.addRating(userId, movieId, score);
        return new ResponseEntity<>(ratingDto, HttpStatus.CREATED);
    }

    /**
     * Get user's ratings
     */
    @GetMapping("/my-ratings")
    public ResponseEntity<List<RatingDto>> getMyRatings(){
        List<RatingDto> myRatings = this.ratingService.getMyRatings();
        return new ResponseEntity<>(myRatings, HttpStatus.OK);
    }
}