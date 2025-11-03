package org.example.movieappbackend.repositories;

import org.example.movieappbackend.entities.Recommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface RecommendationRepo extends JpaRepository<Recommendation, Long> {
    @Query("SELECT r from Recommendation r JOIN FETCH r.movie WHERE r.user.id = :userId ORDER BY r.predictedScore DESC")
    List<Recommendation> findByUserIdOrderByPredictedScoreDesc(Long userId);

    // Efficient delete
    @Modifying
    @Transactional
    @Query("DELETE FROM Recommendation r where r.user.id = :userId")
    void deleteAllByUserId(Long userId);

    // I don't need movies for cache checks
    @Query("SELECT r FROM Recommendation r WHERE r.user.id = :userId")
    List<Recommendation> findByUserId(Long userId);
}
