package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.SaleRecord;
import com.example.drug.mapper.SaleRecordMapper;
import com.example.drug.service.SaleRecordService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SaleRecordServiceImpl extends ServiceImpl<SaleRecordMapper, SaleRecord> implements SaleRecordService {

    @Override
    public List<SaleRecord> getRecordsByBatchId(Long batchId) {
        QueryWrapper<SaleRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("batch_id", batchId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<SaleRecord> getRecordsBySellerId(Long sellerId) {
        QueryWrapper<SaleRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("seller_id", sellerId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<SaleRecord> getRecordsByBuyerId(Long buyerId) {
        QueryWrapper<SaleRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("buyer_id", buyerId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public boolean updateRecordStatus(Long id, Integer status) {
        SaleRecord record = new SaleRecord();
        record.setId(id);
        record.setStatus(status);
        return updateById(record);
    }
}