package com.example.drug.service;

import java.util.Map;

public interface StatsService {
    Map<String, Object> getCirculationStats(String timeRange, String region);
    Map<String, Object> getInventoryStats();
    Map<String, Object> getProductionStats();
    Map<String, Object> getRiskStats();
}