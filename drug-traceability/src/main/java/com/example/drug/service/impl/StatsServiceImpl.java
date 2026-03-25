package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.drug.entity.AdverseReaction;
import com.example.drug.entity.Inventory;
import com.example.drug.entity.ProductionBatch;
import com.example.drug.service.AdverseReactionService;
import com.example.drug.service.InventoryService;
import com.example.drug.service.ProductionBatchService;
import com.example.drug.service.ProcurementRecordService;
import com.example.drug.service.SaleRecordService;
import com.example.drug.service.StatsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StatsServiceImpl implements StatsService {

    @Autowired
    private ProductionBatchService productionBatchService;

    @Autowired
    private ProcurementRecordService procurementRecordService;

    @Autowired
    private SaleRecordService saleRecordService;

    @Autowired
    private InventoryService inventoryService;

    @Autowired
    private AdverseReactionService adverseReactionService;

    @Override
    public Map<String, Object> getCirculationStats(String timeRange, String region) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("timeRange", timeRange);
        stats.put("region", region);
        stats.put("totalProcurement", procurementRecordService.count());
        stats.put("totalSale", saleRecordService.count());
        return stats;
    }

    @Override
    public Map<String, Object> getInventoryStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalInventory", inventoryService.count());
        List<Map<String, Object>> sumResult = inventoryService.listMaps(
            new QueryWrapper<Inventory>().select("COALESCE(SUM(quantity), 0) as totalQuantity")
        );
        long totalQuantity = 0L;
        if (!sumResult.isEmpty() && sumResult.get(0).get("totalQuantity") != null) {
            totalQuantity = ((Number) sumResult.get(0).get("totalQuantity")).longValue();
        }
        stats.put("totalQuantity", totalQuantity);
        return stats;
    }

    @Override
    public Map<String, Object> getProductionStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalBatches", productionBatchService.count());
        List<Map<String, Object>> sumResult = productionBatchService.listMaps(
            new QueryWrapper<ProductionBatch>().select("COALESCE(SUM(production_quantity), 0) as totalQuantity")
        );
        long totalQuantity = 0L;
        if (!sumResult.isEmpty() && sumResult.get(0).get("totalQuantity") != null) {
            totalQuantity = ((Number) sumResult.get(0).get("totalQuantity")).longValue();
        }
        stats.put("totalQuantity", totalQuantity);
        return stats;
    }

    @Override
    public Map<String, Object> getRiskStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("highRiskCount", adverseReactionService.count(new QueryWrapper<AdverseReaction>().eq("severity", "high")));
        stats.put("mediumRiskCount", adverseReactionService.count(new QueryWrapper<AdverseReaction>().eq("severity", "medium")));
        stats.put("lowRiskCount", adverseReactionService.count(new QueryWrapper<AdverseReaction>().eq("severity", "low")));
        return stats;
    }
}
