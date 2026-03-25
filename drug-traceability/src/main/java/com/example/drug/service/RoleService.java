package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.Role;

import java.util.List;

public interface RoleService extends IService<Role> {
    List<Role> getAllRoles();
    Role getRoleByCode(String code);
}