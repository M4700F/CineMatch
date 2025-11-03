package org.example.movieappbackend.payloads;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RecommendationRequestDto {
    @JsonProperty("user_id")
    private Integer userId;

    @JsonProperty("user_ratings")
    private List<UserRatingDto> userRatings;

    @JsonProperty("new_user_preferences")
    private NewUserPreferencesDto newUserPreferences;

    @JsonProperty("top_n")
    private Integer topN = 10;
}