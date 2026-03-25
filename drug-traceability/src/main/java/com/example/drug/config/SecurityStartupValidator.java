package com.example.drug.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.Arrays;

@Component
public class SecurityStartupValidator {

    @Value("${jwt.secret:}")
    private String jwtSecret;

    @Value("${trace.scan.secret:trace-sign-secret}")
    private String scanSecret;

    @Value("${spring.datasource.password:}")
    private String dbPassword;

    private final Environment environment;

    public SecurityStartupValidator(Environment environment) {
        this.environment = environment;
    }

    @PostConstruct
    public void validate() {
        boolean devProfile = Arrays.asList(environment.getActiveProfiles()).contains("dev");
        if (devProfile) {
            return;
        }

        if ("change-me-please-change-me-123456789012".equals(jwtSecret)) {
            throw new IllegalStateException("jwt.secret must be overridden in non-dev profile");
        }
        if ("trace-sign-secret".equals(scanSecret)) {
            throw new IllegalStateException("trace.scan.secret must be overridden in non-dev profile");
        }
        if ("114514".equals(dbPassword)) {
            throw new IllegalStateException("DB password placeholder is not allowed in non-dev profile");
        }
    }
}
