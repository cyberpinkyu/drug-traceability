package com.example.drug.ai.tools;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class KnowledgeSearchTool {

    public List<Map<String, Object>> search_internal_knowledge(String query) {
        List<Map<String, Object>> results = new ArrayList<>();

        Map<String, Object> result1 = new HashMap<>();
        result1.put("id", 1);
        result1.put("title", "药品追溯管理规范");
        result1.put("content", "药品追溯应覆盖生产、流通、使用和不良反应全链路。");
        result1.put("score", 0.95);
        results.add(result1);

        Map<String, Object> result2 = new HashMap<>();
        result2.put("id", 2);
        result2.put("title", "库存与批次管理要求");
        result2.put("content", "库存管理应与批次绑定，保证来源可查和去向可追。");
        result2.put("score", 0.87);
        results.add(result2);

        return results;
    }
}
