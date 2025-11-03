package org.example.movieappbackend.controllers;

import org.example.movieappbackend.payloads.FavoriteDto;
import org.example.movieappbackend.payloads.WatchLaterDto;
import org.example.movieappbackend.services.WatchlistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/watchlist")
public class WatchlistController {

    @Autowired
    private WatchlistService watchlistService;

    // Add movie to favorites
    // POST /api/watchlist/favorites/{userId}/{movieId}
    @PostMapping("/favorites/{userId}/{movieId}")
    public ResponseEntity<FavoriteDto> addMovieToFavorites(
            @PathVariable Long userId,
            @PathVariable Long movieId
    ) {
        FavoriteDto favoriteDto = this.watchlistService.addMovieToFavorites(userId, movieId);
        return new ResponseEntity<>(favoriteDto, HttpStatus.CREATED);
    }

    // Remove movie from favorites
    // DELETE /api/watchlist/favorites/{userId}/{movieId}
    @DeleteMapping("/favorites/{userId}/{movieId}")
    public ResponseEntity<Void> removeMovieFromFavorites(
            @PathVariable Long userId,
            @PathVariable Long movieId
    ) {
        this.watchlistService.removeMovieFromFavorites(userId, movieId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    // Get current user's favorites
    // GET /api/watchlist/my-favorites
    @GetMapping("/my-favorites")
    public ResponseEntity<List<FavoriteDto>> getMyFavorites() {
        List<FavoriteDto> favorites = this.watchlistService.getMyFavorites();
        return new ResponseEntity<>(favorites, HttpStatus.OK);
    }

    // Add movie to watch later
    // POST /api/watchlist/watch-later/{userId}/{movieId}
    @PostMapping("/watch-later/{userId}/{movieId}")
    public ResponseEntity<WatchLaterDto> addMovieToWatchLater(
            @PathVariable Long userId,
            @PathVariable Long movieId
    ) {
        WatchLaterDto watchLaterDto = this.watchlistService.addMovieToWatchLater(userId, movieId);
        return new ResponseEntity<>(watchLaterDto, HttpStatus.CREATED);
    }

    // Remove movie from watch later
    // DELETE /api/watchlist/watch-later/{userId}/{movieId}
    @DeleteMapping("/watch-later/{userId}/{movieId}")
    public ResponseEntity<Void> removeMovieFromWatchLater(
            @PathVariable Long userId,
            @PathVariable Long movieId
    ) {
        this.watchlistService.removeMovieFromWatchLater(userId, movieId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    // Get current user's watch later movies
    // GET /api/watchlist/my-watch-later
    @GetMapping("/my-watch-later")
    public ResponseEntity<List<WatchLaterDto>> getMyWatchLater() {
        List<WatchLaterDto> watchLaterList = this.watchlistService.getMyWatchLater();
        return new ResponseEntity<>(watchLaterList, HttpStatus.OK);
    }
}
