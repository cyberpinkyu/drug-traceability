package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.drug.entity.RegulatoryTask;

import java.util.List;
import java.util.Map;

public interface RegulatoryTaskService extends IService<RegulatoryTask> {
    RegulatoryTask dispatchTask(Map<String, Object> payload);
    RegulatoryTask investigateTask(Long taskId, Map<String, Object> payload);
    RegulatoryTask enforceTask(Long taskId, Map<String, Object> payload);
    List<RegulatoryTask> listByAssignee(Long assigneeId);
}