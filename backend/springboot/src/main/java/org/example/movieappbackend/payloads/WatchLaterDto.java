package org.example.movieappbackend.payloads;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class WatchLaterDto {
    private Long id;
    private Long userId;
    private Long movieId;
    private LocalDateTime createdAt;
}
