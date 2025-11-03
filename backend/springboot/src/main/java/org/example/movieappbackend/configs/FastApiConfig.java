package org.example.movieappbackend.configs;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

@Configuration
public class FastApiConfig {
    @Value("${fastapi.base-url}")
    private String fastApiBaseUrl;

    @Bean
    public RestTemplate restTemplate() {
        RestTemplate restTemplate = new RestTemplate();

        // Use SimpleClientHttpRequestFactory instead of HttpComponentsClientHttpRequestFactory
        // This doesn't require additional dependencies
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(10000); // 10 seconds
        factory.setReadTimeout(30000);    // 30 seconds for ML inference

        restTemplate.setRequestFactory(factory);
        return restTemplate;
    }
}