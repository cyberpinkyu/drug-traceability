package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.ProcurementRecord;

import java.util.List;

public interface ProcurementRecordService extends IService<ProcurementRecord> {
    List<ProcurementRecord> getRecordsByBatchId(Long batchId);
    List<ProcurementRecord> getRecordsByBuyerId(Long buyerId);
    List<ProcurementRecord> getRecordsBySupplierId(Long supplierId);
    boolean updateRecordStatus(Long id, Integer status);
}