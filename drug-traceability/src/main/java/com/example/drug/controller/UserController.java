package com.example.drug.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.drug.common.RequireRole;
import com.example.drug.common.StatusEnum;
import com.example.drug.common.UserContext;
import com.example.drug.entity.Role;
import com.example.drug.entity.User;
import com.example.drug.security.JwtTokenService;
import com.example.drug.security.TokenPair;
import com.example.drug.service.RoleService;
import com.example.drug.service.UserService;
import com.example.drug.utils.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private RoleService roleService;

    @Autowired
    private JwtTokenService jwtTokenService;

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");

        if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
            return MapUtils.of("code", 400, "message", "username and password required");
        }

        User user = userService.login(username, password);
        if (user == null) {
            return MapUtils.of("code", 401, "message", "invalid username or password");
        }

        Role role = roleService.getById(user.getRoleId());
        if (role != null) {
            user.setRoleCode(role.getCode());
        }

        TokenPair tokenPair = jwtTokenService.issueTokens(user);
        return MapUtils.of("code", 200, "message", "login success", "data", buildLoginData(user, tokenPair));
    }

    @PostMapping("/refresh")
    public Map<String, Object> refresh(@RequestBody Map<String, String> params) {
        String refreshToken = params.get("refreshToken");
        if (!StringUtils.hasText(refreshToken)) {
            return MapUtils.of("code", 400, "message", "refreshToken required");
        }

        TokenPair tokenPair = jwtTokenService.refresh(refreshToken);
        Map<String, Object> data = new HashMap<>();
        data.put("token", tokenPair.getAccessToken());
        data.put("accessToken", tokenPair.getAccessToken());
        data.put("refreshToken", tokenPair.getRefreshToken());
        return MapUtils.of("code", 200, "message", "refresh success", "data", data);
    }

    @PostMapping("/logout")
    public Map<String, Object> logout(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return MapUtils.of("code", 400, "message", "missing Authorization");
        }

        jwtTokenService.revokeAccessToken(authHeader.substring(7));
        return MapUtils.of("code", 200, "message", "logout success");
    }

    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody User user) {
        if (!StringUtils.hasText(user.getUsername()) || !StringUtils.hasText(user.getPassword())) {
            return MapUtils.of("code", 400, "message", "username and password required");
        }

        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("username", user.getUsername());
        if (userService.getOne(wrapper) != null) {
            return MapUtils.of("code", 409, "message", "username exists");
        }

        if (!StringUtils.hasText(user.getName())) {
            user.setName(user.getUsername());
        }

        Role publicRole = roleService.getRoleByCode("public");
        if (publicRole != null) {
            user.setRoleId(publicRole.getId());
        }
        user.setStatus(StatusEnum.ACTIVE.getCode());

        boolean success = userService.createUser(user);
        return success
            ? MapUtils.of("code", 200, "message", "register success")
            : MapUtils.of("code", 500, "message", "register failed");
    }

    @GetMapping("/me")
    public Map<String, Object> me() {
        User current = UserContext.getCurrentUser();
        if (current == null || current.getId() == null) {
            return MapUtils.of("code", 401, "message", "unauthorized");
        }

        User dbUser = userService.getById(current.getId());
        if (dbUser == null) {
            return MapUtils.of("code", 401, "message", "user not found");
        }

        Role role = roleService.getById(dbUser.getRoleId());
        if (role != null) {
            dbUser.setRoleCode(role.getCode());
        }

        Map<String, Object> data = new HashMap<>();
        data.put("id", dbUser.getId());
        data.put("username", dbUser.getUsername());
        data.put("name", dbUser.getName());
        data.put("email", dbUser.getEmail());
        data.put("phone", dbUser.getPhone());
        data.put("roleId", dbUser.getRoleId());
        data.put("roleCode", dbUser.getRoleCode());
        data.put("status", dbUser.getStatus());
        return MapUtils.of("code", 200, "data", data);
    }

    @RequireRole({"admin", "super_admin"})
    @GetMapping("/users")
    public Map<String, Object> getUsers() {
        return MapUtils.of("code", 200, "data", userService.list());
    }

    @RequireRole({"admin", "super_admin"})
    @GetMapping("/users/role/{roleId}")
    public Map<String, Object> getUsersByRole(@PathVariable Long roleId) {
        return MapUtils.of("code", 200, "data", userService.getUsersByRoleId(roleId));
    }

    @RequireRole({"admin", "super_admin"})
    @PostMapping("/users")
    public Map<String, Object> addUser(@RequestBody User user) {
        if (!StringUtils.hasText(user.getUsername()) || !StringUtils.hasText(user.getPassword())) {
            return MapUtils.of("code", 400, "message", "username and password required");
        }

        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("username", user.getUsername());
        if (userService.getOne(wrapper) != null) {
            return MapUtils.of("code", 409, "message", "username exists");
        }

        if (user.getStatus() == null) {
            user.setStatus(StatusEnum.ACTIVE.getCode());
        }

        if (user.getRoleId() == null) {
            Role publicRole = roleService.getRoleByCode("public");
            if (publicRole != null) {
                user.setRoleId(publicRole.getId());
            }
        }

        boolean success = userService.createUser(user);
        return success
            ? MapUtils.of("code", 200, "message", "create success")
            : MapUtils.of("code", 500, "message", "create failed");
    }

    @RequireRole({"admin", "super_admin"})
    @PutMapping("/users/{id}")
    public Map<String, Object> updateUser(@PathVariable Long id, @RequestBody User user) {
        user.setId(id);
        boolean success = userService.updateById(user);
        return success
            ? MapUtils.of("code", 200, "message", "update success")
            : MapUtils.of("code", 500, "message", "update failed");
    }

    @RequireRole({"admin", "super_admin"})
    @DeleteMapping("/users/{id}")
    public Map<String, Object> deleteUser(@PathVariable Long id) {
        boolean success = userService.removeById(id);
        return success
            ? MapUtils.of("code", 200, "message", "delete success")
            : MapUtils.of("code", 500, "message", "delete failed");
    }

    @RequireRole({"admin", "super_admin"})
    @PutMapping("/users/{id}/status")
    public Map<String, Object> updateUserStatus(
        @PathVariable Long id,
        @RequestParam(required = false) Integer status,
        @RequestBody(required = false) Map<String, Object> body
    ) {
        Integer finalStatus = status;
        if (finalStatus == null && body != null && body.get("status") != null) {
            finalStatus = Integer.valueOf(String.valueOf(body.get("status")));
        }

        if (finalStatus == null) {
            return MapUtils.of("code", 400, "message", "status required");
        }

        boolean success = userService.updateUserStatus(id, finalStatus);
        return success
            ? MapUtils.of("code", 200, "message", "status updated")
            : MapUtils.of("code", 500, "message", "status update failed");
    }

    @RequireRole({"admin", "super_admin"})
    @GetMapping("/roles")
    public Map<String, Object> getRoles() {
        return MapUtils.of("code", 200, "data", roleService.getAllRoles());
    }

    private Map<String, Object> buildLoginData(User user, TokenPair tokenPair) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("name", user.getName());
        data.put("email", user.getEmail());
        data.put("phone", user.getPhone());
        data.put("roleId", user.getRoleId());
        data.put("roleCode", user.getRoleCode());
        data.put("status", user.getStatus());
        data.put("token", tokenPair.getAccessToken());
        data.put("accessToken", tokenPair.getAccessToken());
        data.put("refreshToken", tokenPair.getRefreshToken());
        return data;
    }
}