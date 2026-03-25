package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.ProductionBatch;

import java.util.List;

public interface ProductionBatchService extends IService<ProductionBatch> {
    ProductionBatch getBatchByNumber(String batchNumber);
    List<ProductionBatch> getBatchesByDrugId(Long drugId);
    List<ProductionBatch> getBatchesByProducerId(Long producerId);
    boolean updateBatchStatus(Long id, Integer status);
}