package org.example.movieappbackend.payloads;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

@NoArgsConstructor
@Data
public class UserDto {
    private Long id;

    @NotBlank
    private String name;

    @Email(message = "Email address is not valid")
    private String email;

    @NotBlank
    @Size(min = 3, max = 10, message = "Password must be minimum of 3 characters and maximum of 10 characters long")
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;

    @NotEmpty
    private String about;

    @NotEmpty
    private Boolean emailVerified;

    // set of roledto
    Set<RoleDto> roles = new HashSet<>();
}
