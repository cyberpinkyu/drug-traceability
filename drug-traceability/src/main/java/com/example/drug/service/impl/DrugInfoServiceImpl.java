package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.DrugInfo;
import com.example.drug.mapper.DrugInfoMapper;
import com.example.drug.service.DrugInfoService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DrugInfoServiceImpl extends ServiceImpl<DrugInfoMapper, DrugInfo> implements DrugInfoService {

    @Override
    public DrugInfo getDrugByCode(String drugCode) {
        QueryWrapper<DrugInfo> wrapper = new QueryWrapper<>();
        wrapper.eq("drug_code", drugCode);
        return baseMapper.selectOne(wrapper);
    }

    @Override
    public List<DrugInfo> getDrugsByCategory(String category) {
        QueryWrapper<DrugInfo> wrapper = new QueryWrapper<>();
        wrapper.eq("category", category);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<DrugInfo> searchDrugs(String keyword) {
        QueryWrapper<DrugInfo> wrapper = new QueryWrapper<>();
        wrapper.like("name", keyword)
               .or().like("drug_code", keyword)
               .or().like("manufacturer", keyword)
               .or().like("approval_number", keyword);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public boolean updateDrugStatus(Long id, Integer status) {
        DrugInfo drugInfo = new DrugInfo();
        drugInfo.setId(id);
        drugInfo.setStatus(status);
        return updateById(drugInfo);
    }
}