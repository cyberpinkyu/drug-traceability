package com.example.drug.security;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthPrincipal {
    private Long userId;
    private String username;
    private String roleCode;
    private String sessionId;
    private String tokenId;
}
