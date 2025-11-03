package org.example.movieappbackend.repositories;

import org.example.movieappbackend.entities.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepo extends JpaRepository<Favorite, Long> {
    Optional<Favorite> findByUserIdAndMovieId(Long userId, Long movieId);
    List<Favorite> findByUserId(Long userId);
}
