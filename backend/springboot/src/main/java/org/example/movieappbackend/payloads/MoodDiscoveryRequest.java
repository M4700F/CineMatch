package org.example.movieappbackend.payloads;

public class MoodDiscoveryRequest {
    private String mood;
    private Integer count; // Optional: number of recommendations (default: 10)

    public MoodDiscoveryRequest() {
    }

    public MoodDiscoveryRequest(String mood, Integer count) {
        this.mood = mood;
        this.count = count;
    }

    public String getMood() {
        return mood;
    }

    public void setMood(String mood) {
        this.mood = mood;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }
}
