package org.example.movieappbackend.controllers;

import jakarta.validation.Valid;
import org.example.movieappbackend.payloads.ApiResponse;
import org.example.movieappbackend.payloads.UserDto;
import org.example.movieappbackend.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/")
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody UserDto userDto) {
        UserDto user = this.userService.createUser(userDto);
        return new ResponseEntity<>(user, HttpStatus.CREATED);
    }

    @PutMapping("/{userId}")
    public ResponseEntity<UserDto> updateUser(@Valid @RequestBody UserDto userDto, @PathVariable("userId") Long uid) {
        UserDto updatedUser = this.userService.updateUser(userDto, uid);
        return new ResponseEntity<>(updatedUser, HttpStatus.OK);
    }

    @GetMapping("/{userId}")
    public ResponseEntity<UserDto> getUser(@Valid @PathVariable("userId") Long uid) {
        UserDto userById = this.userService.getUserById(uid);
        return new ResponseEntity<>(userById, HttpStatus.OK);
    }

    // Add this to your UserController or AuthController

    @GetMapping("/users/profile")
    public ResponseEntity<UserDto> getCurrentUser(Principal principal) {
        String email = principal.getName(); // Gets the username (email) from JWT
        UserDto user = this.userService.getUserByEmail(email);
        return ResponseEntity.ok(user);
    }

    @GetMapping("/")
    public ResponseEntity<List<UserDto>> getAllUser() {
        List<UserDto> allUsers = this.userService.getAllUsers();
        return new ResponseEntity<>(allUsers, HttpStatus.OK);
    }
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{userId}")
    public ResponseEntity<ApiResponse> deleteUser(@PathVariable("userId") Long uid) {
        this.userService.deleteUserById(uid);
        return new ResponseEntity<>(new ApiResponse("User Deleted Successfully", true), HttpStatus.OK);
    }
}

