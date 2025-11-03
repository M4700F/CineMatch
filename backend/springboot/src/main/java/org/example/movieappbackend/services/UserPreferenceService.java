package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.NewUserPreferencesDto;

public interface UserPreferenceService {
    void saveUserPreference(Long userId, NewUserPreferencesDto preferencesDto);
    NewUserPreferencesDto getUserPreferences(Long userId);
}
