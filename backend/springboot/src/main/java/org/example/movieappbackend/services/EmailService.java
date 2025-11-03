package org.example.movieappbackend.services;

public interface EmailService {
    void sendVerificationEmail(String toEmail, String token);
}
