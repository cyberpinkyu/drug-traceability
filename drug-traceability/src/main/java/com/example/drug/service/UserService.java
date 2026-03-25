package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.User;

import java.util.List;

public interface UserService extends IService<User> {
    User login(String username, String password);
    boolean createUser(User user);
    List<User> getUsersByRoleId(Long roleId);
    boolean updateUserStatus(Long id, Integer status);
}
