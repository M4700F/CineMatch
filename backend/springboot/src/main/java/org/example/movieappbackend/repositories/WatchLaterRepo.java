package org.example.movieappbackend.repositories;

import org.example.movieappbackend.entities.WatchLater;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WatchLaterRepo extends JpaRepository<WatchLater, Long> {
    Optional<WatchLater> findByUserIdAndMovieId(Long userId, Long movieId);
    List<WatchLater> findByUserId(Long userId);
}
