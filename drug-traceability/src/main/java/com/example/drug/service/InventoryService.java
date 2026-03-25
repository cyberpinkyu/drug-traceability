package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.Inventory;

import java.util.List;

public interface InventoryService extends IService<Inventory> {
    Inventory getInventoryByBatchAndOrg(Long batchId, Long organizationId);
    List<Inventory> getInventoriesByOrganizationId(Long organizationId);
    List<Inventory> getInventoriesByBatchId(Long batchId);
    boolean updateInventoryQuantity(Long id, Integer quantity);
    boolean adjustInventoryQuantity(Long id, Integer delta);
}
