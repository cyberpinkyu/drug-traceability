package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.RegulatoryEnforcement;
import com.example.drug.mapper.RegulatoryEnforcementMapper;
import com.example.drug.service.RegulatoryEnforcementService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RegulatoryEnforcementServiceImpl extends ServiceImpl<RegulatoryEnforcementMapper, RegulatoryEnforcement> implements RegulatoryEnforcementService {

    @Override
    public List<RegulatoryEnforcement> getEnforcementsByInspectorId(Long inspectorId) {
        QueryWrapper<RegulatoryEnforcement> wrapper = new QueryWrapper<>();
        wrapper.eq("inspector_id", inspectorId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<RegulatoryEnforcement> getEnforcementsByOrganizationId(Long organizationId) {
        QueryWrapper<RegulatoryEnforcement> wrapper = new QueryWrapper<>();
        wrapper.eq("organization_id", organizationId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<RegulatoryEnforcement> getEnforcementsByType(String inspectionType) {
        QueryWrapper<RegulatoryEnforcement> wrapper = new QueryWrapper<>();
        wrapper.eq("inspection_type", inspectionType);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public boolean updateEnforcementStatus(Long id, Integer status) {
        RegulatoryEnforcement enforcement = new RegulatoryEnforcement();
        enforcement.setId(id);
        enforcement.setStatus(status);
        return updateById(enforcement);
    }
}