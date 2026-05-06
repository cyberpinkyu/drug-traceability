package com.example.drug.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
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
import com.example.drug.service.UserService;
import com.example.drug.service.UsageRecordService;
import com.example.drug.utils.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
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

    @Autowired
    private UserService userService;

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
        ProductionBatch batch = findBatchByCode(code);
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
            data.put("approvalNumber", drug.getApprovalNumber());
            data.put("category", drug.getCategory());
        }
        data.put("traceSteps", buildTraceSteps(batch, drug));
        data.put("procurementRecords", procurementRecordService.getRecordsByBatchId(batch.getId()).stream()
            .map(this::toProcurementView)
            .collect(java.util.stream.Collectors.toList()));
        data.put("saleRecords", saleRecordService.getRecordsByBatchId(batch.getId()).stream()
            .map(this::toSaleView)
            .collect(java.util.stream.Collectors.toList()));
        data.put("inventoryRecords", inventoryService.getInventoriesByBatchId(batch.getId()).stream()
            .map(this::toInventoryView)
            .collect(java.util.stream.Collectors.toList()));

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
        List<Map<String, Object>> rows = procurementRecordService.list().stream()
            .map(this::toProcurementView)
            .collect(java.util.stream.Collectors.toList());
        return MapUtils.of("code", 200, "data", rows);
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
        List<Map<String, Object>> rows = saleRecordService.list().stream()
            .map(this::toSaleView)
            .collect(java.util.stream.Collectors.toList());
        return MapUtils.of("code", 200, "data", rows);
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
        List<Map<String, Object>> rows = inventoryService.list().stream()
            .map(this::toInventoryView)
            .collect(java.util.stream.Collectors.toList());
        return MapUtils.of("code", 200, "data", rows);
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
        List<Map<String, Object>> rows = usageRecordService.list().stream()
            .map(this::toUsageRecordView)
            .collect(java.util.stream.Collectors.toList());
        return MapUtils.of("code", 200, "data", rows);
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
    private Map<String, Object> toInventoryView(Inventory inventory) {
        Map<String, Object> row = new LinkedHashMap<String, Object>();
        row.put("id", inventory.getId());
        row.put("batchId", inventory.getBatchId());
        row.put("organizationId", inventory.getOrganizationId());
        row.put("quantity", inventory.getQuantity());
        row.put("lastUpdateDate", inventory.getLastUpdateDate());
        row.put("status", inventory.getStatus());

        ProductionBatch batch = productionBatchService.getById(inventory.getBatchId());
        if (batch != null) {
            row.put("batchNumber", batch.getBatchNumber());
            row.put("productionDate", batch.getProductionDate());
            row.put("expiryDate", batch.getExpiryDate());
            row.put("drugId", batch.getDrugId());

            DrugInfo drug = drugInfoService.getById(batch.getDrugId());
            if (drug != null) {
                row.put("drugCode", drug.getDrugCode());
                row.put("drugName", drug.getName());
                row.put("specification", drug.getSpecification());
                row.put("manufacturer", drug.getManufacturer());
                row.put("category", drug.getCategory());
                row.put("unit", drug.getUnit());
            }
        }

        com.example.drug.entity.User org = userService.getById(inventory.getOrganizationId());
        if (org != null) {
            row.put("organizationName", org.getName());
            row.put("organization", org.getOrganization());
        }
        return row;
    }

    private Map<String, Object> toUsageRecordView(UsageRecord record) {
        Map<String, Object> row = new LinkedHashMap<String, Object>();
        row.put("id", record.getId());
        row.put("drugId", record.getDrugId());
        row.put("patientName", record.getPatientName());
        row.put("dosage", record.getDosage());
        row.put("frequency", record.getFrequency());
        row.put("usageDate", record.getUsageDate());
        row.put("doctorId", record.getDoctorId());
        row.put("hospital", record.getHospital());
        row.put("status", record.getStatus());
        row.put("createdAt", record.getCreatedAt());
        row.put("recordType", "用药记录");

        DrugInfo drug = drugInfoService.getById(record.getDrugId());
        if (drug != null) {
            row.put("drugCode", drug.getDrugCode());
            row.put("drugName", drug.getName());
            row.put("manufacturer", drug.getManufacturer());
            row.put("category", drug.getCategory());
            row.put("specification", drug.getSpecification());
        }
        return row;
    }

    private Map<String, Object> toProcurementView(ProcurementRecord record) {
        Map<String, Object> row = new LinkedHashMap<String, Object>();
        row.put("id", record.getId());
        row.put("batchId", record.getBatchId());
        row.put("buyerId", record.getBuyerId());
        row.put("supplierId", record.getSupplierId());
        row.put("quantity", record.getQuantity());
        row.put("purchaseDate", record.getPurchaseDate());
        row.put("purchasePrice", record.getPurchasePrice());
        row.put("status", record.getStatus());

        ProductionBatch batch = productionBatchService.getById(record.getBatchId());
        if (batch != null) {
            row.put("batchNumber", batch.getBatchNumber());
            DrugInfo drug = drugInfoService.getById(batch.getDrugId());
            if (drug != null) {
                row.put("drugCode", drug.getDrugCode());
                row.put("drugName", drug.getName());
            }
        }

        com.example.drug.entity.User buyer = userService.getById(record.getBuyerId());
        if (buyer != null) {
            row.put("buyerName", buyer.getName());
            row.put("buyerOrganization", buyer.getOrganization());
        }
        com.example.drug.entity.User supplier = userService.getById(record.getSupplierId());
        if (supplier != null) {
            row.put("supplierName", supplier.getName());
            row.put("supplierOrganization", supplier.getOrganization());
        }
        return row;
    }

    private Map<String, Object> toSaleView(SaleRecord record) {
        Map<String, Object> row = new LinkedHashMap<String, Object>();
        row.put("id", record.getId());
        row.put("batchId", record.getBatchId());
        row.put("sellerId", record.getSellerId());
        row.put("buyerId", record.getBuyerId());
        row.put("quantity", record.getQuantity());
        row.put("saleDate", record.getSaleDate());
        row.put("salePrice", record.getSalePrice());
        row.put("status", record.getStatus());

        ProductionBatch batch = productionBatchService.getById(record.getBatchId());
        if (batch != null) {
            row.put("batchNumber", batch.getBatchNumber());
            DrugInfo drug = drugInfoService.getById(batch.getDrugId());
            if (drug != null) {
                row.put("drugCode", drug.getDrugCode());
                row.put("drugName", drug.getName());
            }
        }

        com.example.drug.entity.User seller = userService.getById(record.getSellerId());
        if (seller != null) {
            row.put("sellerName", seller.getName());
            row.put("sellerOrganization", seller.getOrganization());
        }
        com.example.drug.entity.User buyer = userService.getById(record.getBuyerId());
        if (buyer != null) {
            row.put("buyerName", buyer.getName());
            row.put("buyerOrganization", buyer.getOrganization());
        }
        return row;
    }

    private ProductionBatch findBatchByCode(String code) {
        ProductionBatch batch = productionBatchService.getBatchByNumber(code);
        if (batch != null) {
            return batch;
        }
        try {
            batch = productionBatchService.getById(Long.valueOf(code));
            if (batch != null) {
                return batch;
            }
        } catch (NumberFormatException ignored) {
        }

        DrugInfo drug = drugInfoService.getOne(new QueryWrapper<DrugInfo>().eq("drug_code", code));
        if (drug == null) {
            return null;
        }
        return productionBatchService.getOne(new QueryWrapper<ProductionBatch>()
            .eq("drug_id", drug.getId())
            .orderByDesc("production_date")
            .last("LIMIT 1"));
    }

    private List<Map<String, Object>> buildTraceSteps(ProductionBatch batch, DrugInfo drug) {
        List<Map<String, Object>> steps = new ArrayList<Map<String, Object>>();
        com.example.drug.entity.User producer = userService.getById(batch.getProducerId());
        String producerName = producer == null ? "生产企业" : producer.getOrganization();

        addStep(steps, "原料入厂", batch.getProductionDate().atTime(8, 30), producerName, "原辅料到货并完成供应商资质核验");
        addStep(steps, "生产投料", batch.getProductionDate().atTime(13, 20), producerName, "按生产指令完成投料，批号：" + batch.getBatchNumber());
        addStep(steps, "成品检验", batch.getProductionDate().plusDays(1).atTime(10, 10), producerName, "含量、微生物限度、包装完整性检验合格");
        addStep(steps, "成品入库", batch.getProductionDate().plusDays(2).atTime(9, 40), producerName, "入成品库，数量：" + batch.getProductionQuantity());

        for (ProcurementRecord record : procurementRecordService.getRecordsByBatchId(batch.getId())) {
            com.example.drug.entity.User supplier = userService.getById(record.getSupplierId());
            com.example.drug.entity.User buyer = userService.getById(record.getBuyerId());
            String supplierName = supplier == null ? "供应方" : supplier.getOrganization();
            String buyerName = buyer == null ? "采购方" : buyer.getOrganization();
            addStep(steps, "采购入库", record.getPurchaseDate().atTime(15, 10), buyerName,
                supplierName + "向" + buyerName + "发货 " + record.getQuantity() + displayUnit(drug));
        }

        for (SaleRecord record : saleRecordService.getRecordsByBatchId(batch.getId())) {
            com.example.drug.entity.User seller = userService.getById(record.getSellerId());
            com.example.drug.entity.User buyer = userService.getById(record.getBuyerId());
            String sellerName = seller == null ? "销售方" : seller.getOrganization();
            String buyerName = buyer == null ? "收货方" : buyer.getOrganization();
            addStep(steps, "销售出库", record.getSaleDate().atTime(16, 20), sellerName,
                "向" + buyerName + "配送 " + record.getQuantity() + displayUnit(drug));
            addStep(steps, "终端验收", record.getSaleDate().plusDays(1).atTime(9, 25), buyerName,
                "扫码验收入库，批号与随货同行单一致");
        }

        List<AdverseReaction> reactions = adverseReactionService.list(new QueryWrapper<AdverseReaction>().eq("drug_id", batch.getDrugId()));
        for (AdverseReaction reaction : reactions) {
            LocalDateTime time = reaction.getCreatedAt() == null ? batch.getProductionDate().atTime(LocalTime.NOON) : toLocalDateTime(reaction.getCreatedAt());
            addStep(steps, "不良反应监测", time, reaction.getHospital(), reaction.getSeverity() + "：" + reaction.getReactionDescription());
        }

        steps.sort(Comparator.comparing(o -> (LocalDateTime) o.get("timeValue")));
        for (Map<String, Object> step : steps) {
            step.remove("timeValue");
        }
        return steps;
    }

    private void addStep(List<Map<String, Object>> steps, String stage, LocalDateTime time, String organization, String desc) {
        Map<String, Object> step = new LinkedHashMap<String, Object>();
        step.put("stage", stage);
        step.put("time", time.toString().replace('T', ' '));
        step.put("company", organization);
        step.put("organization", organization);
        step.put("desc", desc);
        step.put("description", desc);
        step.put("timeValue", time);
        steps.add(step);
    }

    private String displayUnit(DrugInfo drug) {
        return drug == null || drug.getUnit() == null ? "" : drug.getUnit();
    }

    private LocalDateTime toLocalDateTime(Date value) {
        return LocalDateTime.ofInstant(value.toInstant(), java.time.ZoneId.systemDefault());
    }
}
