package org.example.movieappbackend.payloads;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NewUserPreferencesDto {
    @JsonProperty("action")
    private Double action = 1.0;

    @JsonProperty("adventure")
    private Double adventure = 1.0;

    @JsonProperty("animation")
    private Double animation = 1.0;

    @JsonProperty("childrens")
    private Double childrens = 1.0;

    @JsonProperty("comedy")
    private Double comedy = 1.0;

    @JsonProperty("crime")
    private Double crime = 1.0;

    @JsonProperty("documentary")
    private Double documentary = 1.0;

    @JsonProperty("drama")
    private Double drama = 1.0;

    @JsonProperty("fantasy")
    private Double fantasy = 1.0;

    @JsonProperty("horror")
    private Double horror = 1.0;

    @JsonProperty("mystery")
    private Double mystery = 1.0;

    @JsonProperty("romance")
    private Double romance = 1.0;

    @JsonProperty("scifi")
    private Double scifi = 1.0;

    @JsonProperty("thriller")
    private Double thriller = 1.0;
}