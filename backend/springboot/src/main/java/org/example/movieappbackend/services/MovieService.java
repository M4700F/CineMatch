package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.MovieDto;
import org.example.movieappbackend.payloads.MoviePageResponse;
import org.springframework.data.domain.Page;

import java.util.List;

public interface MovieService {
    MovieDto createMovie(MovieDto movieDto);

    MovieDto updateMovie(MovieDto movieDto, Long movieId);

    MovieDto getMovieById(Long movieId);

    MoviePageResponse getAllMovies(int page, int size, String sortBy, String sortDir);

    void deleteMovieById(Long movieId);

    List<MovieDto> searchMovieByTitle(String keyword);

    void updateAllPosters();
}
