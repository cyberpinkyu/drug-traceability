package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.User;
import com.example.drug.mapper.UserMapper;
import com.example.drug.service.UserService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public User login(String username, String password) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("username", username)
               .eq("status", 1)
               .last("LIMIT 1");

        User user = baseMapper.selectOne(wrapper);
        if (user == null || user.getPassword() == null) {
            return null;
        }

        String storedPassword = user.getPassword();
        boolean matched;
        if (isBcryptHash(storedPassword)) {
            matched = passwordEncoder.matches(password, storedPassword);
        } else {
            matched = password.equals(storedPassword);
            if (matched) {
                user.setPassword(passwordEncoder.encode(password));
                baseMapper.updateById(user);
            }
        }

        return matched ? user : null;
    }

    @Override
    public boolean createUser(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return save(user);
    }

    @Override
    public List<User> getUsersByRoleId(Long roleId) {
        QueryWrapper<User> wrapper = new QueryWrapper<>();
        wrapper.eq("role_id", roleId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public boolean updateUserStatus(Long id, Integer status) {
        User user = new User();
        user.setId(id);
        user.setStatus(status);
        return updateById(user);
    }

    private boolean isBcryptHash(String password) {
        return password.startsWith("$2a$") || password.startsWith("$2b$") || password.startsWith("$2y$");
    }
}
