package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.SaleRecord;

import java.util.List;

public interface SaleRecordService extends IService<SaleRecord> {
    List<SaleRecord> getRecordsByBatchId(Long batchId);
    List<SaleRecord> getRecordsBySellerId(Long sellerId);
    List<SaleRecord> getRecordsByBuyerId(Long buyerId);
    boolean updateRecordStatus(Long id, Integer status);
}