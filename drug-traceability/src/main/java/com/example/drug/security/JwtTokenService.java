package com.example.drug.security;

import com.example.drug.common.BusinessException;
import com.example.drug.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtTokenService {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.access-expire-seconds:7200}")
    private long accessExpireSeconds;

    @Value("${jwt.refresh-expire-seconds:604800}")
    private long refreshExpireSeconds;

    @Autowired
    private AuthSessionService authSessionService;

    private Key key;

    @PostConstruct
    public void init() {
        byte[] bytes = jwtSecret.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("jwt.secret must be at least 32 bytes");
        }
        this.key = Keys.hmacShaKeyFor(bytes);
    }

    public TokenPair issueTokens(User user) {
        String sessionId = UUID.randomUUID().toString().replace("-", "");
        authSessionService.saveSession(user.getId(), sessionId, refreshExpireSeconds);
        String accessToken = buildToken(user, sessionId, "access", accessExpireSeconds);
        String refreshToken = buildToken(user, sessionId, "refresh", refreshExpireSeconds);
        return new TokenPair(accessToken, refreshToken);
    }

    public TokenPair refresh(String refreshToken) {
        Claims claims = parseClaims(refreshToken, true);
        validateType(claims, "refresh");
        ensureSessionValid(claims);

        User user = new User();
        user.setId(toLong(claims.get("uid")));
        user.setUsername((String) claims.get("username"));
        user.setRoleCode((String) claims.get("role"));
        return issueTokens(user);
    }

    public AuthPrincipal parseAccessToken(String accessToken) {
        Claims claims = parseClaims(accessToken, false);
        validateType(claims, "access");
        ensureSessionValid(claims);

        return new AuthPrincipal(
            toLong(claims.get("uid")),
            (String) claims.get("username"),
            (String) claims.get("role"),
            (String) claims.get("sid"),
            claims.getId()
        );
    }

    public void revokeAccessToken(String accessToken) {
        Claims claims = parseClaims(accessToken, true);
        Long uid = toLong(claims.get("uid"));
        authSessionService.blacklistToken(claims.getId(), getRemainingSeconds(claims));
        authSessionService.removeSession(uid);
    }

    public long getRefreshExpireSeconds() {
        return refreshExpireSeconds;
    }

    private String buildToken(User user, String sessionId, String type, long expireSeconds) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + expireSeconds * 1000);
        return Jwts.builder()
            .setId(UUID.randomUUID().toString().replace("-", ""))
            .setSubject(String.valueOf(user.getId()))
            .claim("uid", user.getId())
            .claim("username", user.getUsername())
            .claim("role", user.getRoleCode())
            .claim("sid", sessionId)
            .claim("type", type)
            .setIssuedAt(now)
            .setExpiration(expiry)
            .signWith(key, SignatureAlgorithm.HS256)
            .compact();
    }

    private Claims parseClaims(String token, boolean allowExpired) {
        try {
            return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
        } catch (ExpiredJwtException e) {
            if (allowExpired) {
                return e.getClaims();
            }
            throw new BusinessException(401, "Token已过期");
        } catch (Exception e) {
            throw new BusinessException(401, "Token无效");
        }
    }

    private void validateType(Claims claims, String expectedType) {
        String type = (String) claims.get("type");
        if (!expectedType.equals(type)) {
            throw new BusinessException(401, "Token类型无效");
        }
    }

    private void ensureSessionValid(Claims claims) {
        String tokenId = claims.getId();
        if (authSessionService.isBlacklisted(tokenId)) {
            throw new BusinessException(401, "Token已失效");
        }

        Long uid = toLong(claims.get("uid"));
        String sid = (String) claims.get("sid");
        String currentSession = authSessionService.getSession(uid);
        if (currentSession == null || !currentSession.equals(sid)) {
            throw new BusinessException(401, "会话已失效，请重新登录");
        }
    }

    private long getRemainingSeconds(Claims claims) {
        Date exp = claims.getExpiration();
        long remain = (exp.getTime() - System.currentTimeMillis()) / 1000;
        return Math.max(remain, 1);
    }

    private Long toLong(Object value) {
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        return Long.valueOf(String.valueOf(value));
    }
}
