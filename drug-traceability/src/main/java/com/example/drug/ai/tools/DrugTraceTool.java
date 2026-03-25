package com.example.drug.ai.tools;

import com.example.drug.entity.Inventory;
import com.example.drug.entity.ProcurementRecord;
import com.example.drug.entity.ProductionBatch;
import com.example.drug.entity.SaleRecord;
import com.example.drug.service.DrugInfoService;
import com.example.drug.service.InventoryService;
import com.example.drug.service.ProcurementRecordService;
import com.example.drug.service.ProductionBatchService;
import com.example.drug.service.SaleRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class DrugTraceTool {

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

    public Map<String, Object> query_drug_trace(Long batchId) {
        Map<String, Object> result = new HashMap<>();

        ProductionBatch batch = productionBatchService.getById(batchId);
        result.put("production", batch);

        if (batch != null) {
            result.put("drug", drugInfoService.getById(batch.getDrugId()));
        }

        List<ProcurementRecord> procurementRecords = procurementRecordService.getRecordsByBatchId(batchId);
        result.put("procurement", procurementRecords);

        List<SaleRecord> saleRecords = saleRecordService.getRecordsByBatchId(batchId);
        result.put("sale", saleRecords);

        List<Inventory> inventories = inventoryService.getInventoriesByBatchId(batchId);
        result.put("inventory", inventories);

        return result;
    }
}
