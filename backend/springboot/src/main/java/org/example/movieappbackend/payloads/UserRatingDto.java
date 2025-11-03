package org.example.movieappbackend.payloads;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRatingDto {
    @JsonProperty("movie_id")
    private Integer movieId;
    @JsonProperty("rating")
    private Double rating;
}
