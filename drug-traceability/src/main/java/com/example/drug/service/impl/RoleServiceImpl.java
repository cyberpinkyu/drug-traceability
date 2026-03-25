package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.Role;
import com.example.drug.mapper.RoleMapper;
import com.example.drug.service.RoleService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RoleServiceImpl extends ServiceImpl<RoleMapper, Role> implements RoleService {

    @Override
    public List<Role> getAllRoles() {
        return baseMapper.selectList(null);
    }

    @Override
    public Role getRoleByCode(String code) {
        QueryWrapper<Role> wrapper = new QueryWrapper<>();
        wrapper.eq("code", code);
        return baseMapper.selectOne(wrapper);
    }
}