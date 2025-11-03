package org.example.movieappbackend.services.impl;

import org.example.movieappbackend.entities.User;
import org.example.movieappbackend.entities.UserPreference;
import org.example.movieappbackend.payloads.NewUserPreferencesDto;
import org.example.movieappbackend.repositories.UserPreferenceRepo;
import org.example.movieappbackend.services.UserPreferenceService;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class UserPreferenceServiceImpl implements UserPreferenceService {
    @Autowired
    private UserPreferenceRepo userPreferenceRepo;

    @Autowired
    private ModelMapper modelMapper;


    @Override
    public void saveUserPreference(Long userId, NewUserPreferencesDto preferencesDto) {
        UserPreference userPreference = userPreferenceRepo.findByUserId(userId).orElse(new UserPreference());

        // Set user if this is a new preference
        if(userPreference.getUser() ==  null){
            User user = new User();
            user.setId(userId);
            userPreference.setUser(user);
        }

        // Update preferences
        userPreference.setAction(preferencesDto.getAction());
        userPreference.setAdventure(preferencesDto.getAdventure());
        userPreference.setAnimation(preferencesDto.getAnimation());
        userPreference.setChildrens(preferencesDto.getChildrens());
        userPreference.setComedy(preferencesDto.getComedy());
        userPreference.setCrime(preferencesDto.getCrime());
        userPreference.setDocumentary(preferencesDto.getDocumentary());
        userPreference.setDrama(preferencesDto.getDrama());
        userPreference.setFantasy(preferencesDto.getFantasy());
        userPreference.setHorror(preferencesDto.getHorror());
        userPreference.setMystery(preferencesDto.getMystery());
        userPreference.setRomance(preferencesDto.getRomance());
        userPreference.setScifi(preferencesDto.getScifi());
        userPreference.setThriller(preferencesDto.getThriller());
        userPreference.setUpdatedAt(LocalDateTime.now());

        this.userPreferenceRepo.save(userPreference);
    }

    @Override
    public NewUserPreferencesDto getUserPreferences(Long userId) {
        return this.userPreferenceRepo.findByUserId(userId).map(this::convertToDto).orElse(new NewUserPreferencesDto());
    }

    private NewUserPreferencesDto convertToDto(UserPreference userPreference) {
        NewUserPreferencesDto dto = new NewUserPreferencesDto();
        dto.setAction(userPreference.getAction());
        dto.setAdventure(userPreference.getAdventure());
        dto.setAnimation(userPreference.getAnimation());
        dto.setChildrens(userPreference.getChildrens());
        dto.setComedy(userPreference.getComedy());
        dto.setCrime(userPreference.getCrime());
        dto.setDocumentary(userPreference.getDocumentary());
        dto.setDrama(userPreference.getDrama());
        dto.setFantasy(userPreference.getFantasy());
        dto.setHorror(userPreference.getHorror());
        dto.setMystery(userPreference.getMystery());
        dto.setRomance(userPreference.getRomance());
        dto.setScifi(userPreference.getScifi());
        dto.setThriller(userPreference.getThriller());
        return dto;
    }
}
