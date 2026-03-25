package com.example.drug.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
public class AuthSessionService {

    private static final String SESSION_PREFIX = "auth:session:";
    private static final String BLACKLIST_PREFIX = "auth:blacklist:";

    @Autowired
    private StringRedisTemplate redisTemplate;

    public void saveSession(Long userId, String sessionId, long ttlSeconds) {
        redisTemplate.opsForValue().set(sessionKey(userId), sessionId, Duration.ofSeconds(ttlSeconds));
    }

    public String getSession(Long userId) {
        return redisTemplate.opsForValue().get(sessionKey(userId));
    }

    public void removeSession(Long userId) {
        redisTemplate.delete(sessionKey(userId));
    }

    public void blacklistToken(String tokenId, long ttlSeconds) {
        if (tokenId == null || tokenId.trim().isEmpty() || ttlSeconds <= 0) {
            return;
        }
        redisTemplate.opsForValue().set(blacklistKey(tokenId), "1", Duration.ofSeconds(ttlSeconds));
    }

    public boolean isBlacklisted(String tokenId) {
        if (tokenId == null || tokenId.trim().isEmpty()) {
            return false;
        }
        return Boolean.TRUE.equals(redisTemplate.hasKey(blacklistKey(tokenId)));
    }

    private String sessionKey(Long userId) {
        return SESSION_PREFIX + userId;
    }

    private String blacklistKey(String tokenId) {
        return BLACKLIST_PREFIX + tokenId;
    }
}
