package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.ProcurementRecord;
import com.example.drug.mapper.ProcurementRecordMapper;
import com.example.drug.service.ProcurementRecordService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProcurementRecordServiceImpl extends ServiceImpl<ProcurementRecordMapper, ProcurementRecord> implements ProcurementRecordService {

    @Override
    public List<ProcurementRecord> getRecordsByBatchId(Long batchId) {
        QueryWrapper<ProcurementRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("batch_id", batchId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<ProcurementRecord> getRecordsByBuyerId(Long buyerId) {
        QueryWrapper<ProcurementRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("buyer_id", buyerId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<ProcurementRecord> getRecordsBySupplierId(Long supplierId) {
        QueryWrapper<ProcurementRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("supplier_id", supplierId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public boolean updateRecordStatus(Long id, Integer status) {
        ProcurementRecord record = new ProcurementRecord();
        record.setId(id);
        record.setStatus(status);
        return updateById(record);
    }
}