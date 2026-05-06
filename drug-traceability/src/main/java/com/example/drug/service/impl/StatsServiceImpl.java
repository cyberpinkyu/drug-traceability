package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.drug.entity.AdverseReaction;
import com.example.drug.entity.DrugInfo;
import com.example.drug.entity.Inventory;
import com.example.drug.entity.ProcurementRecord;
import com.example.drug.entity.ProductionBatch;
import com.example.drug.entity.SaleRecord;
import com.example.drug.entity.User;
import com.example.drug.service.AdverseReactionService;
import com.example.drug.service.DrugInfoService;
import com.example.drug.service.InventoryService;
import com.example.drug.service.ProductionBatchService;
import com.example.drug.service.ProcurementRecordService;
import com.example.drug.service.SaleRecordService;
import com.example.drug.service.StatsService;
import com.example.drug.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.LinkedHashMap;
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

    @Autowired
    private UserService userService;

    @Autowired
    private DrugInfoService drugInfoService;

    @Override
    public Map<String, Object> getCirculationStats(String timeRange, String region) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("timeRange", timeRange);
        stats.put("region", region);
        stats.put("totalProcurement", procurementRecordService.count());
        stats.put("totalSale", saleRecordService.count());
        stats.put("totalProcurementQuantity", sumProcurementQuantity());
        stats.put("totalSaleQuantity", sumSaleQuantity());
        stats.put("trend", buildCirculationTrend());
        stats.put("regionStats", buildRegionStats());
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
        stats.put("byOrganization", buildInventoryByOrganization());
        stats.put("byCategory", buildInventoryByCategory());
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
        stats.put("trend", buildProductionTrend());
        return stats;
    }

    @Override
    public Map<String, Object> getRiskStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("highRiskCount", adverseReactionService.count(new QueryWrapper<AdverseReaction>().eq("severity", "high")));
        stats.put("mediumRiskCount", adverseReactionService.count(new QueryWrapper<AdverseReaction>().eq("severity", "medium")));
        stats.put("lowRiskCount", adverseReactionService.count(new QueryWrapper<AdverseReaction>().eq("severity", "low")));
        stats.put("byHospital", buildRiskByHospital());
        stats.put("recentAlerts", buildRecentAlerts());
        return stats;
    }

    private long sumProcurementQuantity() {
        long total = 0L;
        for (ProcurementRecord record : procurementRecordService.list()) {
            total += record.getQuantity() == null ? 0 : record.getQuantity();
        }
        return total;
    }

    private long sumSaleQuantity() {
        long total = 0L;
        for (SaleRecord record : saleRecordService.list()) {
            total += record.getQuantity() == null ? 0 : record.getQuantity();
        }
        return total;
    }

    private List<Map<String, Object>> buildCirculationTrend() {
        Map<YearMonth, Map<String, Long>> months = new LinkedHashMap<YearMonth, Map<String, Long>>();
        YearMonth start = YearMonth.from(LocalDate.now().minusMonths(5));
        for (int i = 0; i < 6; i++) {
            YearMonth ym = start.plusMonths(i);
            Map<String, Long> row = new HashMap<String, Long>();
            row.put("procurement", 0L);
            row.put("sale", 0L);
            row.put("production", 0L);
            months.put(ym, row);
        }

        for (ProcurementRecord record : procurementRecordService.list()) {
            if (record.getPurchaseDate() == null) {
                continue;
            }
            YearMonth ym = YearMonth.from(record.getPurchaseDate());
            Map<String, Long> row = months.get(ym);
            if (row != null) {
                row.put("procurement", row.get("procurement") + safeInt(record.getQuantity()));
            }
        }
        for (SaleRecord record : saleRecordService.list()) {
            if (record.getSaleDate() == null) {
                continue;
            }
            YearMonth ym = YearMonth.from(record.getSaleDate());
            Map<String, Long> row = months.get(ym);
            if (row != null) {
                row.put("sale", row.get("sale") + safeInt(record.getQuantity()));
            }
        }
        for (ProductionBatch batch : productionBatchService.list()) {
            if (batch.getProductionDate() == null) {
                continue;
            }
            YearMonth ym = YearMonth.from(batch.getProductionDate());
            Map<String, Long> row = months.get(ym);
            if (row != null) {
                row.put("production", row.get("production") + safeInt(batch.getProductionQuantity()));
            }
        }

        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Map.Entry<YearMonth, Map<String, Long>> entry : months.entrySet()) {
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("month", entry.getKey().toString());
            row.put("procurement", entry.getValue().get("procurement"));
            row.put("sale", entry.getValue().get("sale"));
            row.put("production", entry.getValue().get("production"));
            rows.add(row);
        }
        return rows;
    }

    private List<Map<String, Object>> buildProductionTrend() {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Map<String, Object> row : buildCirculationTrend()) {
            Map<String, Object> item = new LinkedHashMap<String, Object>();
            item.put("month", row.get("month"));
            item.put("quantity", row.get("production"));
            rows.add(item);
        }
        return rows;
    }

    private List<Map<String, Object>> buildRegionStats() {
        Map<String, Long> buckets = new LinkedHashMap<String, Long>();
        for (SaleRecord record : saleRecordService.list()) {
            User buyer = userService.getById(record.getBuyerId());
            String region = resolveRegion(buyer == null ? null : buyer.getOrganization());
            buckets.put(region, buckets.containsKey(region) ? buckets.get(region) + safeInt(record.getQuantity()) : safeInt(record.getQuantity()));
        }
        return toNameValueRows(buckets);
    }

    private List<Map<String, Object>> buildInventoryByOrganization() {
        Map<String, Long> buckets = new LinkedHashMap<String, Long>();
        for (Inventory inventory : inventoryService.list()) {
            User org = userService.getById(inventory.getOrganizationId());
            String name = org == null ? "未知机构" : org.getOrganization();
            buckets.put(name, buckets.containsKey(name) ? buckets.get(name) + safeInt(inventory.getQuantity()) : safeInt(inventory.getQuantity()));
        }
        return toNameValueRows(buckets);
    }

    private List<Map<String, Object>> buildInventoryByCategory() {
        Map<String, Long> buckets = new LinkedHashMap<String, Long>();
        for (Inventory inventory : inventoryService.list()) {
            ProductionBatch batch = productionBatchService.getById(inventory.getBatchId());
            DrugInfo drug = batch == null ? null : drugInfoService.getById(batch.getDrugId());
            String category = drug == null || drug.getCategory() == null ? "未分类" : drug.getCategory();
            buckets.put(category, buckets.containsKey(category) ? buckets.get(category) + safeInt(inventory.getQuantity()) : safeInt(inventory.getQuantity()));
        }
        return toNameValueRows(buckets);
    }

    private Map<String, Long> buildRiskByHospital() {
        Map<String, Long> buckets = new LinkedHashMap<String, Long>();
        for (AdverseReaction reaction : adverseReactionService.list()) {
            String hospital = reaction.getHospital() == null ? "未知机构" : reaction.getHospital();
            buckets.put(hospital, buckets.containsKey(hospital) ? buckets.get(hospital) + 1 : 1L);
        }
        return buckets;
    }

    private List<Map<String, Object>> buildRecentAlerts() {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (AdverseReaction reaction : adverseReactionService.list(new QueryWrapper<AdverseReaction>().orderByDesc("created_at").last("LIMIT 8"))) {
            DrugInfo drug = drugInfoService.getById(reaction.getDrugId());
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("level", reaction.getSeverity());
            row.put("title", (drug == null ? "药品" : drug.getName()) + "不良反应上报");
            row.put("desc", reaction.getHospital() + "，患者：" + reaction.getPatientName());
            row.put("time", reaction.getCreatedAt());
            rows.add(row);
        }
        return rows;
    }

    private List<Map<String, Object>> toNameValueRows(Map<String, Long> buckets) {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Map.Entry<String, Long> entry : buckets.entrySet()) {
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("name", entry.getKey());
            row.put("value", entry.getValue());
            rows.add(row);
        }
        return rows;
    }

    private long safeInt(Integer value) {
        return value == null ? 0L : value.longValue();
    }

    private String resolveRegion(String organization) {
        if (organization == null) {
            return "未知区域";
        }
        String[] regions = {"广州", "深圳", "佛山", "东莞", "珠海", "惠州", "中山", "江门"};
        for (String item : regions) {
            if (organization.contains(item)) {
                return item;
            }
        }
        return "广东其他";
    }
}
