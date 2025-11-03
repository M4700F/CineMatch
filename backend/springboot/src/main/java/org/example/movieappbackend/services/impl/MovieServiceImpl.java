package org.example.movieappbackend.services.impl;

import org.example.movieappbackend.entities.Movie;
import org.example.movieappbackend.exceptions.ResourceNotFoundException;
import org.example.movieappbackend.payloads.MovieDto;
import org.example.movieappbackend.payloads.MoviePageResponse;
import org.example.movieappbackend.repositories.MovieRepo;
import org.example.movieappbackend.services.MovieService;
import org.example.movieappbackend.services.TMDBService;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Stream;

@Service
public class MovieServiceImpl implements MovieService {

    @Autowired
    private MovieRepo movieRepo;

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private TMDBService tmdbService;

    @Override
    public MovieDto createMovie(MovieDto movieDto) {
        Movie movie = this.modelMapper.map(movieDto, Movie.class);
        this.movieRepo.save(movie);
        return this.modelMapper.map(movie, MovieDto.class);
    }

    @Override
    public MovieDto updateMovie(MovieDto movieDto, Long movieId) {
        Movie movie = this.movieRepo.findById(movieId).orElseThrow(() -> new ResourceNotFoundException("Movie", "Id", movieId));
        movie.setTitle(movieDto.getTitle());
        movie.setGenres(movieDto.getGenres());
        movie.setReleaseYear(movieDto.getReleaseYear());
        return this.modelMapper.map(movie, MovieDto.class);
    }

    @Override
    public MovieDto getMovieById(Long movieId) {
        Movie movie = this.movieRepo.findById(movieId).orElseThrow(() -> new ResourceNotFoundException("Movie", "Id", movieId));
        return this.modelMapper.map(movie, MovieDto.class);
    }

    @Override
    public MoviePageResponse getAllMovies(int pageNumber, int pageSize, String sortBy, String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase("ASC")
                ? Sort.by(sortBy).ascending()
                : Sort.by(sortBy).descending();

        Pageable pageable = PageRequest.of(pageNumber, pageSize, sort);
        Page<Movie> moviePage = this.movieRepo.findAll(pageable);
        return maptoMoviePageResponse(moviePage);
    }

    private MoviePageResponse maptoMoviePageResponse(Page<Movie> moviePage) {

        Page<MovieDto> movieDtoPage = moviePage.map(movie -> this.modelMapper.map(movie, MovieDto.class));

        MoviePageResponse moviePageResponse = new MoviePageResponse();

        moviePageResponse.setContent(movieDtoPage.getContent());
        moviePageResponse.setPageNumber(movieDtoPage.getNumber());
        moviePageResponse.setPageSize(movieDtoPage.getSize());
        moviePageResponse.setTotalPages(movieDtoPage.getTotalPages());
        moviePageResponse.setLastPage(movieDtoPage.isLast());

        return moviePageResponse;

    }


    @Override
    public void deleteMovieById(Long movieId) {
        Movie movie = this.movieRepo.findById(movieId).orElseThrow(() -> new ResourceNotFoundException("Movie", "Id", movieId));
        this.movieRepo.delete(movie);
    }

    @Override
    public List<MovieDto> searchMovieByTitle(String keyword) {
        List<Movie> movies = this.movieRepo.findByTitleContainingIgnoreCase(keyword);
        return movies.stream().map(movie -> this.modelMapper.map(movie, MovieDto.class)).toList();
    }

    @Override
    public void updateAllPosters() {
        List<Movie> movies = this.movieRepo.findAll();

        for(Movie movie : movies){
            if(movie.getPosterUrl() == null || movie.getPosterUrl().isEmpty()) {
                String posterURL = tmdbService.fetchPosterURL(movie.getTitle());
                if(posterURL != null) {
                    movie.setPosterUrl(posterURL);
                    movieRepo.save(movie);
                    System.out.println("Poster updated for " + movie.getTitle());
                }
                else {
                    System.out.println("Poster not found for " + movie.getTitle());
                }
            }
        }
    }
}
