package org.example.movieappbackend.services.impl;

import com.fasterxml.jackson.databind.annotation.JsonAppend;
import org.example.movieappbackend.configs.AppConstants;
import org.example.movieappbackend.entities.Role;
import org.example.movieappbackend.entities.User;
import org.example.movieappbackend.exceptions.DuplicateEmailException;
import org.example.movieappbackend.exceptions.ResourceNotFoundException;
import org.example.movieappbackend.payloads.UserDto;
import org.example.movieappbackend.repositories.RoleRepo;
import org.example.movieappbackend.repositories.UserRepo;
import org.example.movieappbackend.services.EmailService;
import org.example.movieappbackend.services.UserService;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepo userRepo;

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private RoleRepo roleRepo;

    @Autowired
    private EmailService emailService;


    @Override
    public UserDto registerUser(UserDto userDto) {
        User user = this.modelMapper.map(userDto, User.class);

        // Check if user with this email already exists - throw exception if found
        this.userRepo.findByEmail(user.getEmail())
                .ifPresent(existingUser -> {
                    throw new DuplicateEmailException("User", "email", user.getEmail());
                });

        user.setPassword(this.passwordEncoder.encode(user.getPassword()));
        Role role = this.roleRepo.findById(AppConstants.NORMAL_USER).get();
        user.getRoles().add(role);

        // Set email verification fields
        user.setEmailVerified(false);
        user.setVerificationToken(UUID.randomUUID().toString());
        user.setVerificationTokenExpiry(LocalDateTime.now().plusDays(1)); // 24 hours

        User savedUser = this.userRepo.save(user);

        // send verification email
        try {
            this.emailService.sendVerificationEmail(savedUser.getEmail(), savedUser.getVerificationToken());
        } catch (Exception e){
            System.err.println("Failed to send verification email: " + e.getMessage());
        }
        return this.modelMapper.map(savedUser, UserDto.class);
    }

    @Override
    public UserDto createUser(UserDto userDto) {
        User user = this.userRepo.save(this.modelMapper.map(userDto, User.class));
        return this.modelMapper.map(user, UserDto.class);
    }

    @Override
    public UserDto updateUser(UserDto userDto, Long userId) {
        User user = this.userRepo.findById(userId).orElseThrow(()-> new ResourceNotFoundException("User", "Id", userId));
        user.setName(userDto.getName());
        user.setEmail(userDto.getEmail());
        user.setPassword(userDto.getPassword());
        user.setAbout(userDto.getAbout());
        return this.modelMapper.map(user, UserDto.class);
    }

    @Override
    public UserDto getUserById(Long userId) {
        User user = this.userRepo.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User", "Id", userId));
        return this.modelMapper.map(user, UserDto.class);
    }

    @Override
    public List<UserDto> getAllUsers() {
        List<User> users = this.userRepo.findAll();
        return users.stream()
                .map(user -> this.modelMapper.map(user, UserDto.class))
                .toList();
    }

    @Override
    public void deleteUserById(Long userId) {
        User user = this.userRepo.findById(userId).orElseThrow(() -> new ResourceNotFoundException("User", "Id", userId));
        this.userRepo.delete(user);
    }

    @Override
    public boolean verifyEmail(String token) {
        Optional<User> userOptional = this.userRepo.findByVerificationToken(token);

        if(userOptional.isEmpty()){
            return false;
        }

        User user = userOptional.get();

        if(user.getVerificationTokenExpiry().isBefore(LocalDateTime.now())){
            return false;
        }

        // verify email
        user.setEmailVerified(true);
        user.setVerificationToken(null);
        user.setVerificationTokenExpiry(null);
        this.userRepo.save(user);

        return true;
    }

    @Override
    public void resendVerificationEmail(String email) {
        User user = this.userRepo.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("User", "email", 0));
        if(user.getEmailVerified()) {
            throw new RuntimeException("Email is already verified");
        }

        // Generate new token
        user.setVerificationToken(UUID.randomUUID().toString());
        user.setVerificationTokenExpiry(LocalDateTime.now().plusDays(1));
        userRepo.save(user);

        // Send new verification email
        this.emailService.sendVerificationEmail(user.getEmail(), user.getVerificationToken());

    }

    @Override
    public UserDto getUserByEmail(String email) {
        User user = this.userRepo.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", 0));
        return this.modelMapper.map(user, UserDto.class);
    }
}