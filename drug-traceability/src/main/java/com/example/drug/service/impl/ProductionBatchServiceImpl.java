package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.ProductionBatch;
import com.example.drug.mapper.ProductionBatchMapper;
import com.example.drug.service.ProductionBatchService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductionBatchServiceImpl extends ServiceImpl<ProductionBatchMapper, ProductionBatch> implements ProductionBatchService {

    @Override
    public ProductionBatch getBatchByNumber(String batchNumber) {
        QueryWrapper<ProductionBatch> wrapper = new QueryWrapper<>();
        wrapper.eq("batch_number", batchNumber);
        return baseMapper.selectOne(wrapper);
    }

    @Override
    public List<ProductionBatch> getBatchesByDrugId(Long drugId) {
        QueryWrapper<ProductionBatch> wrapper = new QueryWrapper<>();
        wrapper.eq("drug_id", drugId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<ProductionBatch> getBatchesByProducerId(Long producerId) {
        QueryWrapper<ProductionBatch> wrapper = new QueryWrapper<>();
        wrapper.eq("producer_id", producerId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public boolean updateBatchStatus(Long id, Integer status) {
        ProductionBatch batch = new ProductionBatch();
        batch.setId(id);
        batch.setStatus(status);
        return updateById(batch);
    }
}