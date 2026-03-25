package com.example.drug.controller;

import com.example.drug.common.BusinessException;
import com.example.drug.common.RequireRole;
import com.example.drug.entity.AdverseReaction;
import com.example.drug.entity.DrugInfo;
import com.example.drug.entity.Inventory;
import com.example.drug.entity.ProcurementRecord;
import com.example.drug.entity.ProductionBatch;
import com.example.drug.entity.SaleRecord;
import com.example.drug.entity.UsageRecord;
import com.example.drug.service.AdverseReactionService;
import com.example.drug.service.DrugInfoService;
import com.example.drug.service.InventoryService;
import com.example.drug.service.ProcurementRecordService;
import com.example.drug.service.ProductionBatchService;
import com.example.drug.service.SaleRecordService;
import com.example.drug.service.UsageRecordService;
import com.example.drug.utils.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/trace")
public class TraceController {

    @Autowired
    private ProductionBatchService productionBatchService;

    @Autowired
    private ProcurementRecordService procurementRecordService;

    @Autowired
    private SaleRecordService saleRecordService;

    @Autowired
    private InventoryService inventoryService;

    @Autowired
    private DrugInfoService drugInfoService;

    @Autowired
    private UsageRecordService usageRecordService;

    @Autowired
    private AdverseReactionService adverseReactionService;

    @GetMapping("/batch")
    public Map<String, Object> getBatches() {
        return MapUtils.of("code", 200, "data", productionBatchService.list());
    }

    @GetMapping("/batch/{id}")
    public Map<String, Object> getBatchById(@PathVariable Long id) {
        return MapUtils.of("code", 200, "data", productionBatchService.getById(id));
    }

    @GetMapping("/batch/number/{number}")
    public Map<String, Object> getBatchByNumber(@PathVariable String number) {
        return MapUtils.of("code", 200, "data", productionBatchService.getBatchByNumber(number));
    }

    @GetMapping("/public/{code}")
    public Map<String, Object> getPublicTrace(@PathVariable String code) {
        ProductionBatch batch = productionBatchService.getBatchByNumber(code);
        if (batch == null) {
            try {
                batch = productionBatchService.getById(Long.valueOf(code));
            } catch (NumberFormatException ignored) {
            }
        }

        if (batch == null) {
            return MapUtils.of("code", 404, "message", "未找到追溯记录");
        }

        DrugInfo drug = drugInfoService.getById(batch.getDrugId());
        Map<String, Object> data = new HashMap<>();
        data.put("batchId", batch.getId());
        data.put("batchNumber", batch.getBatchNumber());
        data.put("productionDate", batch.getProductionDate());
        data.put("expiryDate", batch.getExpiryDate());
        data.put("traceCode", code);
        if (drug != null) {
            data.put("drugId", drug.getId());
            data.put("drugCode", drug.getDrugCode());
            data.put("drugName", drug.getName());
            data.put("specification", drug.getSpecification());
            data.put("manufacturer", drug.getManufacturer());
        }

        return MapUtils.of("code", 200, "data", data);
    }

    @RequireRole({"admin", "producer"})
    @PostMapping("/batch")
    @Transactional
    public Map<String, Object> addBatch(@Valid @RequestBody ProductionBatch batch) {
        boolean success = productionBatchService.save(batch);
        if (!success) {
            return MapUtils.of("code", 500, "message", "添加失败");
        }

        Inventory inventory = new Inventory();
        inventory.setBatchId(batch.getId());
        inventory.setOrganizationId(batch.getProducerId());
        inventory.setQuantity(batch.getProductionQuantity());
        inventory.setLastUpdateDate(batch.getProductionDate());
        inventory.setStatus(1);
        inventoryService.save(inventory);
        return MapUtils.of("code", 200, "message", "添加成功");
    }

    @RequireRole({"admin", "producer"})
    @PutMapping("/batch/{id}")
    public Map<String, Object> updateBatch(@PathVariable Long id, @RequestBody ProductionBatch batch) {
        batch.setId(id);
        boolean success = productionBatchService.updateById(batch);
        return success
            ? MapUtils.of("code", 200, "message", "更新成功")
            : MapUtils.of("code", 500, "message", "更新失败");
    }

    @GetMapping("/procurement")
    public Map<String, Object> getProcurementRecords() {
        return MapUtils.of("code", 200, "data", procurementRecordService.list());
    }

    @RequireRole({"admin", "producer", "enterprise", "institution"})
    @PostMapping("/procurement")
    @Transactional
    public Map<String, Object> addProcurementRecord(@Valid @RequestBody ProcurementRecord record) {
        boolean success = procurementRecordService.save(record);
        if (!success) {
            return MapUtils.of("code", 500, "message", "添加失败");
        }

        updateInventoryAfterProcurement(record);
        return MapUtils.of("code", 200, "message", "添加成功");
    }

    @GetMapping("/sale")
    public Map<String, Object> getSaleRecords() {
        return MapUtils.of("code", 200, "data", saleRecordService.list());
    }

    @RequireRole({"admin", "producer", "enterprise", "institution"})
    @PostMapping("/sale")
    @Transactional
    public Map<String, Object> addSaleRecord(@Valid @RequestBody SaleRecord record) {
        boolean success = saleRecordService.save(record);
        if (!success) {
            return MapUtils.of("code", 500, "message", "添加失败");
        }

        updateInventoryAfterSale(record);
        return MapUtils.of("code", 200, "message", "添加成功");
    }

    @GetMapping("/inventory")
    public Map<String, Object> getInventories() {
        return MapUtils.of("code", 200, "data", inventoryService.list());
    }

    @GetMapping("/inventory/org/{orgId}")
    public Map<String, Object> getInventoriesByOrg(@PathVariable Long orgId) {
        return MapUtils.of("code", 200, "data", inventoryService.getInventoriesByOrganizationId(orgId));
    }

    @GetMapping("/batch/{id}/full")
    public Map<String, Object> getFullTrace(@PathVariable Long id) {
        Map<String, Object> result = new HashMap<>();
        ProductionBatch batch = productionBatchService.getById(id);
        result.put("production", batch);
        if (batch != null) {
            result.put("drug", drugInfoService.getById(batch.getDrugId()));
        }
        result.put("procurement", procurementRecordService.getRecordsByBatchId(id));
        result.put("sale", saleRecordService.getRecordsByBatchId(id));
        result.put("inventory", inventoryService.getInventoriesByBatchId(id));
        return MapUtils.of("code", 200, "data", result);
    }

    private void updateInventoryAfterProcurement(ProcurementRecord record) {
        Inventory supplierInventory = inventoryService.getInventoryByBatchAndOrg(record.getBatchId(), record.getSupplierId());
        if (supplierInventory == null) {
            throw new BusinessException(400, "供应方库存不存在");
        }
        inventoryService.adjustInventoryQuantity(supplierInventory.getId(), -record.getQuantity());

        Inventory buyerInventory = inventoryService.getInventoryByBatchAndOrg(record.getBatchId(), record.getBuyerId());
        if (buyerInventory != null) {
            inventoryService.adjustInventoryQuantity(buyerInventory.getId(), record.getQuantity());
        } else {
            Inventory newInventory = new Inventory();
            newInventory.setBatchId(record.getBatchId());
            newInventory.setOrganizationId(record.getBuyerId());
            newInventory.setQuantity(record.getQuantity());
            newInventory.setLastUpdateDate(record.getPurchaseDate());
            newInventory.setStatus(1);
            inventoryService.save(newInventory);
        }
    }

    private void updateInventoryAfterSale(SaleRecord record) {
        Inventory sellerInventory = inventoryService.getInventoryByBatchAndOrg(record.getBatchId(), record.getSellerId());
        if (sellerInventory == null) {
            throw new BusinessException(400, "销售方库存不存在");
        }
        inventoryService.adjustInventoryQuantity(sellerInventory.getId(), -record.getQuantity());

        Inventory buyerInventory = inventoryService.getInventoryByBatchAndOrg(record.getBatchId(), record.getBuyerId());
        if (buyerInventory != null) {
            inventoryService.adjustInventoryQuantity(buyerInventory.getId(), record.getQuantity());
        } else {
            Inventory newInventory = new Inventory();
            newInventory.setBatchId(record.getBatchId());
            newInventory.setOrganizationId(record.getBuyerId());
            newInventory.setQuantity(record.getQuantity());
            newInventory.setLastUpdateDate(record.getSaleDate());
            newInventory.setStatus(1);
            inventoryService.save(newInventory);
        }
    }

    @GetMapping("/usage/records")
    public Map<String, Object> getUsageRecords() {
        return MapUtils.of("code", 200, "data", usageRecordService.list());
    }

    @RequireRole({"admin", "institution", "public"})
    @PostMapping("/usage/record")
    public Map<String, Object> addUsageRecord(@RequestBody UsageRecord record) {
        boolean success = usageRecordService.save(record);
        return success
            ? MapUtils.of("code", 200, "message", "记录成功")
            : MapUtils.of("code", 500, "message", "记录失败");
    }

    @GetMapping("/adverse/records")
    public Map<String, Object> getAdverseRecords() {
        return MapUtils.of("code", 200, "data", adverseReactionService.list());
    }

    @RequireRole({"admin", "institution", "public", "regulator"})
    @PostMapping("/adverse/submit")
    public Map<String, Object> submitAdverseReaction(@Valid @RequestBody AdverseReaction reaction) {
        if (reaction.getStatus() == null) {
            reaction.setStatus(1);
        }
        boolean success = adverseReactionService.save(reaction);
        return success
            ? MapUtils.of("code", 200, "message", "上报成功")
            : MapUtils.of("code", 500, "message", "上报失败");
    }
}