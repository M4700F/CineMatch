package org.example.movieappbackend.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_preferences")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserPreference {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", unique = true)
    private User user;

    @Column(name = "action_preference")
    private Double action = 1.0;

    @Column(name = "adventure_preference")
    private Double adventure = 1.0;

    @Column(name = "animation_preference")
    private Double animation = 1.0;

    @Column(name = "childrens_preference")
    private Double childrens = 1.0;

    @Column(name = "comedy_preference")
    private Double comedy = 1.0;

    @Column(name = "crime_preference")
    private Double crime = 1.0;

    @Column(name = "documentary_preference")
    private Double documentary = 1.0;

    @Column(name = "drama_preference")
    private Double drama = 1.0;

    @Column(name = "fantasy_preference")
    private Double fantasy = 1.0;

    @Column(name = "horror_preference")
    private Double horror = 1.0;

    @Column(name = "mystery_preference")
    private Double mystery = 1.0;

    @Column(name = "romance_preference")
    private Double romance = 1.0;

    @Column(name = "scifi_preference")
    private Double scifi = 1.0;

    @Column(name = "thriller_preference")
    private Double thriller = 1.0;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
