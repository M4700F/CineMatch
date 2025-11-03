package org.example.movieappbackend.payloads;

import java.util.List;

public class MoodDiscoveryResponse {
    private String mood;
    private List<MovieRecommendation> movies;
    private String description;

    public static class MovieRecommendation {
        private String title;
        private Integer year;
        private String description;
        private String reason;
        private String posterUrl; // Optional: can be added later
        private Double rating; // Optional: can be fetched from TMDB

        public MovieRecommendation() {
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public Integer getYear() {
            return year;
        }

        public void setYear(Integer year) {
            this.year = year;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public String getReason() {
            return reason;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }

        public String getPosterUrl() {
            return posterUrl;
        }

        public void setPosterUrl(String posterUrl) {
            this.posterUrl = posterUrl;
        }

        public Double getRating() {
            return rating;
        }

        public void setRating(Double rating) {
            this.rating = rating;
        }
    }

    public MoodDiscoveryResponse() {
    }

    public String getMood() {
        return mood;
    }

    public void setMood(String mood) {
        this.mood = mood;
    }

    public List<MovieRecommendation> getMovies() {
        return movies;
    }

    public void setMovies(List<MovieRecommendation> movies) {
        this.movies = movies;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}