package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.FavoriteDto;
import org.example.movieappbackend.payloads.WatchLaterDto;

import java.util.List;

public interface WatchlistService {
    FavoriteDto addMovieToFavorites(Long userId, Long movieId);
    void removeMovieFromFavorites(Long userId, Long movieId);
    List<FavoriteDto> getMyFavorites();

    WatchLaterDto addMovieToWatchLater(Long userId, Long movieId);
    void removeMovieFromWatchLater(Long userId, Long movieId);
    List<WatchLaterDto> getMyWatchLater();
}
