package org.example.movieappbackend.repositories;

import org.example.movieappbackend.entities.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RatingRepo extends JpaRepository<Rating, Long> {
    List<Rating> findByUserId(Long userId);

    @Query("SELECT COUNT(r) FROM Rating r WHERE r.user.id = :userId")
    Long countByUserId(Long userId);

    @Query("SELECT AVG(r.score) FROM Rating r WHERE r.user.id = :userId")
    Double averageScoreByUserId(Long userId);

    Optional<Rating> findByUserIdAndMovieId(Long userId, Long movieId);

}
