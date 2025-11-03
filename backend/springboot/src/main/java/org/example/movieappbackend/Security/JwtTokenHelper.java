package org.example.movieappbackend.Security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtTokenHelper {

    // Token validity
    public static final long JWT_TOKEN_VALIDITY = 5 * 60 * 60 * 1000;

    @Value("${jwt.secret}")
    private String secret;

    private SecretKey key;

    @PostConstruct
    public void init() {this.key = Keys.hmacShaKeyFor(secret.getBytes()); }

    // Retrieve username from JWT token
    public String getUsernameFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }

    // Retrieve expiration date from JWT token
    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }

    // Retrieve any claim from token
    public <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = getAllClaimsFromToken(token);
        return claimsResolver.apply(claims);
    }

    // For retrieving any information from token, we will need the secret key
    private Claims getAllClaimsFromToken(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (JwtException e) {
            throw new RuntimeException("Invalid JWT token", e);
        }
    }

    // Check if the token has expired
    public boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }

    // Generate token for user (simple version like ChatGPT's)
    public String generateToken(String username) {
        return Jwts.builder()
                .subject(username)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + JWT_TOKEN_VALIDITY))
                .signWith(key, Jwts.SIG.HS256)
                .compact();
    }

    // Generate token with custom claims
    public String generateToken(String username, Map<String, Object> extraClaims) {
        return createToken(extraClaims, username);
    }

    // Create token with claims and subject
    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
                .claims(claims)  // This adds custom claims
                .subject(subject)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + JWT_TOKEN_VALIDITY))
                .signWith(key, Jwts.SIG.HS256)
                .compact();
    }

    // Validate token
    public boolean validateToken(String token, UserDetails userDetails) {
        try {
            final String tokenUsername = getUsernameFromToken(token);
            return (tokenUsername.equals(userDetails.getUsername()) && !isTokenExpired(token));
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    // Validate token without username check
    public boolean isValidToken(String token) {
        try {
            getAllClaimsFromToken(token);
            return !isTokenExpired(token);
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    // Get all claims as a map
    public Map<String, Object> getAllClaims(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            return new HashMap<>(claims);
        } catch (JwtException | IllegalArgumentException e) {
            return new HashMap<>();
        }
    }

    // Get specific claim by key
    public Object getClaim(String token, String claimKey) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            return claims.get(claimKey);
        } catch (JwtException | IllegalArgumentException e) {
            return null;
        }
    }

    // Refresh token (generate new token with same claims but extended expiry)
    public String refreshToken(String token) {
        try {
            Claims claims = getAllClaimsFromToken(token);
            String username = claims.getSubject();

            // Remove standard claims to avoid duplication
            claims.remove(Claims.SUBJECT);
            claims.remove(Claims.ISSUED_AT);
            claims.remove(Claims.EXPIRATION);

            return createToken(new HashMap<>(claims), username);
        } catch (JwtException | IllegalArgumentException e) {
            throw new RuntimeException("Cannot refresh invalid token", e);
        }
    }

    // Extract token from Authorization header
    public String extractTokenFromHeader(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }

    // Get remaining time until token expiration in minutes
    public long getRemainingExpirationTime(String token) {
        try {
            Date expiration = getExpirationDateFromToken(token);
            long currentTime = System.currentTimeMillis();
            long expirationTime = expiration.getTime();
            return (expirationTime - currentTime) / (1000 * 60); // Return in minutes
        } catch (JwtException | IllegalArgumentException e) {
            return 0;
        }
    }
}
