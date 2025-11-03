package org.example.movieappbackend.services.impl;

import org.example.movieappbackend.entities.Favorite;
import org.example.movieappbackend.entities.Movie;
import org.example.movieappbackend.entities.User;
import org.example.movieappbackend.entities.WatchLater;
import org.example.movieappbackend.exceptions.ApiException;
import org.example.movieappbackend.exceptions.ResourceNotFoundException;
import org.example.movieappbackend.payloads.FavoriteDto;
import org.example.movieappbackend.payloads.WatchLaterDto;
import org.example.movieappbackend.repositories.FavoriteRepo;
import org.example.movieappbackend.repositories.MovieRepo;
import org.example.movieappbackend.repositories.UserRepo;
import org.example.movieappbackend.repositories.WatchLaterRepo;
import org.example.movieappbackend.services.WatchlistService;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class WatchlistServiceImpl implements WatchlistService {

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private MovieRepo movieRepo;

    @Autowired
    private FavoriteRepo favoriteRepo;

    @Autowired
    private WatchLaterRepo watchLaterRepo;

    @Autowired
    private ModelMapper modelMapper;

    @Override
    public FavoriteDto addMovieToFavorites(Long userId, Long movieId) {
        User user = this.userRepo.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User", "Id", userId));
        Movie movie = this.movieRepo.findById(movieId).orElseThrow(() -> new ResourceNotFoundException("Movie", "Id", movieId));

        Optional<Favorite> existingFavorite = this.favoriteRepo.findByUserIdAndMovieId(userId, movieId);
        if (existingFavorite.isPresent()) {
            throw new ApiException("Movie already in favorites");
        }

        Favorite favorite = new Favorite();
        favorite.setUser(user);
        favorite.setMovieId(movieId);
        Favorite savedFavorite = this.favoriteRepo.save(favorite);
        return this.modelMapper.map(savedFavorite, FavoriteDto.class);
    }

    @Override
    public void removeMovieFromFavorites(Long userId, Long movieId) {
        Favorite favorite = this.favoriteRepo.findByUserIdAndMovieId(userId, movieId)
                .orElseThrow(() -> new ResourceNotFoundException("Favorite", "userId and movieId", 0L));
        this.favoriteRepo.delete(favorite);
    }

    @Override
    public List<FavoriteDto> getMyFavorites() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();

        User user = this.userRepo.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("User", "email " + email, 0));
        List<Favorite> favorites = this.favoriteRepo.findByUserId(user.getId());
        return favorites.stream().map(favorite -> this.modelMapper.map(favorite, FavoriteDto.class)).toList();
    }

    @Override
    public WatchLaterDto addMovieToWatchLater(Long userId, Long movieId) {
        User user = this.userRepo.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User", "Id", userId));
        Movie movie = this.movieRepo.findById(movieId).orElseThrow(() -> new ResourceNotFoundException("Movie", "Id", movieId));

        Optional<WatchLater> existingWatchLater = this.watchLaterRepo.findByUserIdAndMovieId(userId, movieId);
        if (existingWatchLater.isPresent()) {
            throw new ApiException("Movie already in watch later");
        }

        WatchLater watchLater = new WatchLater();
        watchLater.setUser(user);
        watchLater.setMovieId(movieId);
        WatchLater savedWatchLater = this.watchLaterRepo.save(watchLater);
        return this.modelMapper.map(savedWatchLater, WatchLaterDto.class);
    }

    @Override
    public void removeMovieFromWatchLater(Long userId, Long movieId) {
        WatchLater watchLater = this.watchLaterRepo.findByUserIdAndMovieId(userId, movieId)
                .orElseThrow(() -> new ResourceNotFoundException("WatchLater", "userId and movieId", 0L));
        this.watchLaterRepo.delete(watchLater);
    }

    @Override
    public List<WatchLaterDto> getMyWatchLater() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();

        User user = this.userRepo.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("User", "email " + email, 0));
        List<WatchLater> watchLaterList = this.watchLaterRepo.findByUserId(user.getId());
        return watchLaterList.stream().map(watchLater -> this.modelMapper.map(watchLater, WatchLaterDto.class)).toList();
    }
}
