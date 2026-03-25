package com.example.drug.service;

import com.example.drug.config.AIConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AIService {

    @Autowired
    public AIService(AIConfig aiConfig) {
        System.out.println("AIService initialized");
    }

    public String generateResponse(String prompt) {
        return "AI response: " + prompt;
    }

    public String runAgent(String prompt) {
        try {
            return "AI agent result: " + prompt;
        } catch (Exception e) {
            return "AI error: " + e.getMessage();
        }
    }
}
