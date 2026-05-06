package com.example.drug.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Set;

@Service
public class AuthSessionService {

    private static final String SESSION_PREFIX = "auth:sessions:";
    private static final String BLACKLIST_PREFIX = "auth:blacklist:";

    @Autowired
    private StringRedisTemplate redisTemplate;

    public void saveSession(Long userId, String sessionId, long ttlSeconds) {
        redisTemplate.opsForSet().add(sessionKey(userId), sessionId);
        redisTemplate.expire(sessionKey(userId), Duration.ofSeconds(ttlSeconds));
    }

    public boolean hasSession(Long userId, String sessionId) {
        if (userId == null || sessionId == null || sessionId.trim().isEmpty()) {
            return false;
        }
        return Boolean.TRUE.equals(redisTemplate.opsForSet().isMember(sessionKey(userId), sessionId));
    }

    public void refreshSessionTtl(Long userId, long ttlSeconds) {
        redisTemplate.expire(sessionKey(userId), Duration.ofSeconds(ttlSeconds));
    }

    public void removeSession(Long userId, String sessionId) {
        if (userId == null || sessionId == null || sessionId.trim().isEmpty()) {
            return;
        }
        redisTemplate.opsForSet().remove(sessionKey(userId), sessionId);
    }

    public void removeAllSessions(Long userId) {
        redisTemplate.delete(sessionKey(userId));
    }

    public Set<String> getSessions(Long userId) {
        return redisTemplate.opsForSet().members(sessionKey(userId));
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
