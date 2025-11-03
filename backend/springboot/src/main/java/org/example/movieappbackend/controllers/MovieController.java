package org.example.movieappbackend.controllers;

import jakarta.validation.Valid;
import org.example.movieappbackend.configs.AppConstants;
import org.example.movieappbackend.payloads.ApiResponse;
import org.example.movieappbackend.payloads.MovieDto;
import org.example.movieappbackend.payloads.MoviePageResponse;
import org.example.movieappbackend.services.MovieService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/movies")
public class MovieController {

    @Autowired
    private MovieService movieService;

    @PostMapping("/")
    public ResponseEntity<MovieDto> createMovie(@Valid @RequestBody MovieDto movieDto){
        MovieDto movie = this.movieService.createMovie(movieDto);
        return new ResponseEntity<>(movie, HttpStatus.CREATED);
    }

    @PutMapping("/{movieId}")
    public ResponseEntity<MovieDto> updateMovie(@Valid @RequestBody MovieDto movieDto, @PathVariable("movieId") Long movieId){
        MovieDto updatedMovie = this.movieService.updateMovie(movieDto, movieId);
        return new ResponseEntity<>(updatedMovie, HttpStatus.OK);
    }

    @GetMapping("/{movieId}")
    public ResponseEntity<MovieDto> getMovieById(@Valid @PathVariable("movieId") Long movieId){
        MovieDto movieById = this.movieService.getMovieById(movieId);
        return new ResponseEntity<>(movieById, HttpStatus.OK);
    }

    // Please do pagination

    //    GET /movies                          // page=0, size=10 (defaults)
    //    GET /movies?page=2&size=20          // page 2, 20 items per page
    //    GET /movies?page=0&size=10&sortBy=title&sortDir=DESC
    @GetMapping("/")
    public ResponseEntity<MoviePageResponse> getAllMovies(
            @RequestParam(defaultValue = AppConstants.PAGE_NUMBER) int pageNumber,
            @RequestParam(defaultValue = AppConstants.PAGE_SIZE) int pageSize,
            @RequestParam(defaultValue = AppConstants.SORT_BY) String sortBy,
            @RequestParam(defaultValue = AppConstants.SORT_DIR) String sortDir
    ){
        MoviePageResponse moviePageResponse = this.movieService.getAllMovies(pageNumber, pageSize, sortBy, sortDir);
        return new ResponseEntity<>(moviePageResponse, HttpStatus.OK);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{movieId}")
    public ApiResponse deleteMovie(@Valid @PathVariable("movieId") Long movieId){
        this.movieService.deleteMovieById(movieId);
        return new ApiResponse("Movie has been successfully deleted with ID: " + movieId, true);
    }

    // search by title
    @GetMapping("/search/{keywords}")
    public ResponseEntity<List<MovieDto>> searchPost(@PathVariable("keywords") String keywords){
        List<MovieDto> movieDtos = this.movieService.searchMovieByTitle(keywords);
        return new ResponseEntity<List<MovieDto>>(movieDtos, HttpStatus.OK);
    }

    @PostMapping("/update-posters")
    public String updatePosters() {
        movieService.updateAllPosters();
        return "Poster update process started";
    }
}
