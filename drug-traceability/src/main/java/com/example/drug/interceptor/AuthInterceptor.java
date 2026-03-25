package com.example.drug.interceptor;

import com.example.drug.common.RequireRole;
import com.example.drug.common.UserContext;
import com.example.drug.entity.User;
import com.example.drug.security.AuthPrincipal;
import com.example.drug.security.JwtTokenService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtTokenService jwtTokenService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            writeErrorResponse(response, 401, "未授权，请先登录");
            return false;
        }

        String token = authHeader.substring(7);
        AuthPrincipal principal;
        try {
            principal = jwtTokenService.parseAccessToken(token);
        } catch (Exception e) {
            writeErrorResponse(response, 401, e.getMessage());
            return false;
        }

        User user = new User();
        user.setId(principal.getUserId());
        user.setUsername(principal.getUsername());
        user.setRoleCode(principal.getRoleCode());
        UserContext.setCurrentUser(user);

        if (handler instanceof HandlerMethod) {
            HandlerMethod handlerMethod = (HandlerMethod) handler;
            RequireRole requireRole = handlerMethod.getMethodAnnotation(RequireRole.class);
            if (requireRole != null) {
                boolean hasRole = Arrays.asList(requireRole.value()).contains(user.getRoleCode());
                if (!hasRole) {
                    writeErrorResponse(response, 403, "权限不足");
                    return false;
                }
            }
        }

        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        UserContext.clear();
    }

    private void writeErrorResponse(HttpServletResponse response, int code, String message) throws Exception {
        response.setStatus(code);
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();
        result.put("code", code);
        result.put("message", message);
        response.getWriter().write(objectMapper.writeValueAsString(result));
    }
}
