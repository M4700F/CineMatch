package org.example.movieappbackend.payloads;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RatingDto {
    private Long id;
    private double score;
    private MovieDto movie;
    private UserDto user;
}
