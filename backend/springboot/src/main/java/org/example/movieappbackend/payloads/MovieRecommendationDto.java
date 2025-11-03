package org.example.movieappbackend.payloads;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MovieRecommendationDto {
    @JsonProperty("movie_id")
    private Integer movieId;

    @JsonProperty("predicted_score")
    private Double predictedScore;

    @JsonProperty("title")
    private String title;

    @JsonProperty("genres")
    private String genres;
}
