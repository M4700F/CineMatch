package org.example.movieappbackend.services;

import org.example.movieappbackend.payloads.UserDto;

import java.util.List;

public interface UserService {
    UserDto registerUser(UserDto userDto);

    UserDto createUser(UserDto userDto);

    UserDto updateUser(UserDto userDto, Long userId);

    UserDto getUserById(Long userId);

    UserDto getUserByEmail(String email);

    List<UserDto> getAllUsers();

    void deleteUserById(Long userId);

    boolean verifyEmail(String token);

    void resendVerificationEmail(String email);
}
