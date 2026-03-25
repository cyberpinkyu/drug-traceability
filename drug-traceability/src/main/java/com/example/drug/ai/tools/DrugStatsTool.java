package com.example.drug.ai.tools;

import com.example.drug.service.ProcurementRecordService;
import com.example.drug.service.SaleRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class DrugStatsTool {

    @Autowired
    private ProcurementRecordService procurementRecordService;

    @Autowired
    private SaleRecordService saleRecordService;

    public Map<String, Object> get_drug_stats(String timeRange, String region) {
        Map<String, Object> result = new HashMap<>();
        
        // 杩欓噷绠€鍖栧疄鐜帮紝瀹為檯搴旇鏍规嵁鏃堕棿鑼冨洿鍜屽湴鍖鸿繘琛岀粺璁?        result.put("timeRange", timeRange);
        result.put("region", region);
        result.put("totalProcurement", procurementRecordService.count());
        result.put("totalSale", saleRecordService.count());
        
        return result;
    }
}