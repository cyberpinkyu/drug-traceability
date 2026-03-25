package com.example.drug.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.drug.config.AIConfig;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;

@Service
public class VectorDbService {

    private final String collectionName;

    @Autowired
    public VectorDbService(AIConfig aiConfig) {
        this.collectionName = aiConfig.getMilvusCollectionName();
        System.out.println("VectorDbService initialized with collection: " + collectionName);
    }

    public boolean insertVector(List<Float> vector, Map<String, Object> metadata) {
        // 妯℃嫙鎻掑叆鎿嶄綔
        System.out.println("Inserting vector with metadata: " + metadata);
        return true;
    }

    public List<Map<String, Object>> searchVectors(List<Float> queryVector, int topK) {
        // 妯℃嫙鎼滅储缁撴灉
        List<Map<String, Object>> results = new ArrayList<>();
        for (int i = 0; i < topK; i++) {
            Map<String, Object> result = new HashMap<>();
            result.put("id", i + 1);
            result.put("score", 1.0f - (i * 0.1f));
            result.put("content", "杩欐槸妯℃嫙鎼滅储缁撴灉 " + (i + 1));
            results.add(result);
        }
        return results;
    }

    public void close() {
        // 妯℃嫙鍏抽棴鎿嶄綔
        System.out.println("VectorDbService closed");
    }
}