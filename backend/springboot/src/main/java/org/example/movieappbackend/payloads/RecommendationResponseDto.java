package org.example.movieappbackend.payloads;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationResponseDto {
    @JsonProperty("user_id")
    private Integer userId;

    @JsonProperty("recommendations")
    private List<MovieDto> recommendations;
}