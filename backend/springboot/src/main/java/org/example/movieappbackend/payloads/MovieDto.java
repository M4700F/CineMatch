package org.example.movieappbackend.payloads;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MovieDto {

    private Long id;

    @NotBlank
    private String title;
    @NotBlank
    private Integer releaseYear;
    @NotBlank
    private String genres;
    private String posterUrl; // Added posterUrl field
    private Double predictedScore;
}
