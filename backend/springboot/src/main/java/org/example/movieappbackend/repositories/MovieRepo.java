package org.example.movieappbackend.repositories;

import org.example.movieappbackend.entities.Movie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MovieRepo extends JpaRepository<Movie, Long> {
    List<Movie> findByTitleContainingIgnoreCase(String keyword);
    @Query("SELECT m FROM Movie m ORDER BY m.id LIMIT 10")
    List<Movie> findTop10Movies();
}
