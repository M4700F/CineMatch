package org.example.movieappbackend.repositories;

import org.example.movieappbackend.entities.User;
import org.example.movieappbackend.entities.UserPreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserPreferenceRepo extends JpaRepository<UserPreference, Integer> {
    Optional<UserPreference> findByUserId(Long user_id);
}
