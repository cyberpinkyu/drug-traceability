package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.RegulatoryEnforcement;

import java.util.List;

public interface RegulatoryEnforcementService extends IService<RegulatoryEnforcement> {
    List<RegulatoryEnforcement> getEnforcementsByInspectorId(Long inspectorId);
    List<RegulatoryEnforcement> getEnforcementsByOrganizationId(Long organizationId);
    List<RegulatoryEnforcement> getEnforcementsByType(String inspectionType);
    boolean updateEnforcementStatus(Long id, Integer status);
}