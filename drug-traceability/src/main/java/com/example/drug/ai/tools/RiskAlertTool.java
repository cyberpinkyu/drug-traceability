package com.example.drug.ai.tools;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class RiskAlertTool {

    public List<Map<String, Object>> list_risk_alerts() {
        List<Map<String, Object>> alerts = new ArrayList<>();

        Map<String, Object> alert1 = new HashMap<>();
        alert1.put("id", 1);
        alert1.put("type", "库存风险");
        alert1.put("message", "部分批次库存接近预警阈值");
        alert1.put("level", "medium");
        alerts.add(alert1);

        Map<String, Object> alert2 = new HashMap<>();
        alert2.put("id", 2);
        alert2.put("type", "不良反应风险");
        alert2.put("message", "某批次不良反应报告数量上升");
        alert2.put("level", "high");
        alerts.add(alert2);

        return alerts;
    }
}
