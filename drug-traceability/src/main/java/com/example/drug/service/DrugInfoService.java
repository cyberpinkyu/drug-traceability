package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.DrugInfo;

import java.util.List;

public interface DrugInfoService extends IService<DrugInfo> {
    DrugInfo getDrugByCode(String drugCode);
    List<DrugInfo> getDrugsByCategory(String category);
    List<DrugInfo> searchDrugs(String keyword);
    boolean updateDrugStatus(Long id, Integer status);
}