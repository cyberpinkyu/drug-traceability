package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.common.BusinessException;
import com.example.drug.common.UserContext;
import com.example.drug.entity.AdverseReaction;
import com.example.drug.entity.RegulatoryEnforcement;
import com.example.drug.entity.RegulatoryTask;
import com.example.drug.mapper.RegulatoryTaskMapper;
import com.example.drug.service.AdverseReactionService;
import com.example.drug.service.RegulatoryEnforcementService;
import com.example.drug.service.RegulatoryTaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class RegulatoryTaskServiceImpl extends ServiceImpl<RegulatoryTaskMapper, RegulatoryTask> implements RegulatoryTaskService {

    @Autowired
    private AdverseReactionService adverseReactionService;

    @Autowired
    private RegulatoryEnforcementService regulatoryEnforcementService;

    @Override
    @Transactional
    public RegulatoryTask dispatchTask(Map<String, Object> payload) {
        Long reportId = requiredLong(payload, "reportId");
        Long assigneeId = requiredLong(payload, "assigneeId");

        AdverseReaction report = adverseReactionService.getById(reportId);
        if (report == null) {
            throw new BusinessException(404, "上报记录不存在");
        }
        if (report.getStatus() != null && report.getStatus() != 1) {
            throw new BusinessException(400, "该上报已进入处理流程，不能重复派单");
        }

        long activeCount = count(new QueryWrapper<RegulatoryTask>()
            .eq("report_id", reportId)
            .in("status", 1, 2));
        if (activeCount > 0) {
            throw new BusinessException(409, "该上报已有处理中任务");
        }

        RegulatoryTask task = new RegulatoryTask();
        task.setReportId(reportId);
        task.setAssigneeId(assigneeId);
        task.setSuspectedSource(stringOf(payload.get("suspectedSource")));
        task.setSuspectedOrgId(optionalLong(payload.get("suspectedOrgId")));
        task.setStatus(1);
        task.setDispatchedAt(LocalDateTime.now());
        save(task);

        report.setStatus(2);
        adverseReactionService.updateById(report);
        return task;
    }

    @Override
    public List<RegulatoryTask> listByAssignee(Long assigneeId) {
        QueryWrapper<RegulatoryTask> wrapper = new QueryWrapper<>();
        wrapper.eq("assignee_id", assigneeId).orderByDesc("created_at");
        return list(wrapper);
    }

    @Override
    @Transactional
    public RegulatoryTask investigateTask(Long taskId, Map<String, Object> payload) {
        RegulatoryTask task = getById(taskId);
        if (task == null) {
            throw new BusinessException(404, "任务不存在");
        }
        if (task.getStatus() == null || task.getStatus() != 1) {
            throw new BusinessException(400, "仅允许对已派发任务提交调查结论");
        }

        task.setConclusionSource(stringOf(payload.get("conclusionSource")));
        task.setConclusionOrgId(optionalLong(payload.get("conclusionOrgId")));
        task.setVerified(optionalInt(payload.get("verified"), 0));
        task.setInvestigationResult(stringOf(payload.get("investigationResult")));
        task.setStatus(2);
        task.setInvestigatedAt(LocalDateTime.now());
        updateById(task);

        AdverseReaction report = adverseReactionService.getById(task.getReportId());
        if (report != null) {
            report.setStatus(task.getVerified() == 1 ? 3 : 5);
            adverseReactionService.updateById(report);
        }

        return task;
    }

    @Override
    @Transactional
    public RegulatoryTask enforceTask(Long taskId, Map<String, Object> payload) {
        RegulatoryTask task = getById(taskId);
        if (task == null) {
            throw new BusinessException(404, "任务不存在");
        }
        if (task.getStatus() == null || task.getStatus() != 2) {
            throw new BusinessException(400, "仅允许对已调查任务执行处置");
        }
        if (task.getVerified() == null || task.getVerified() != 1) {
            throw new BusinessException(400, "仅支持对属实问题执行处置");
        }

        RegulatoryEnforcement enforcement = new RegulatoryEnforcement();
        enforcement.setInspectorId(UserContext.getCurrentUserId());
        enforcement.setOrganizationId(task.getConclusionOrgId());
        enforcement.setInspectionType(stringOf(payload.get("actionType")));
        enforcement.setInspectionResult(stringOf(payload.get("inspectionResult")));
        enforcement.setDescription(stringOf(payload.get("description")));
        enforcement.setInspectionDate(LocalDateTime.now());
        enforcement.setStatus(1);
        regulatoryEnforcementService.save(enforcement);

        task.setStatus(3);
        task.setEnforcedAt(LocalDateTime.now());
        updateById(task);

        AdverseReaction report = adverseReactionService.getById(task.getReportId());
        if (report != null) {
            report.setStatus(4);
            adverseReactionService.updateById(report);
        }

        return task;
    }

    private Long requiredLong(Map<String, Object> payload, String key) {
        Object value = payload.get(key);
        if (value == null) {
            throw new BusinessException(400, key + "不能为空");
        }
        return Long.valueOf(String.valueOf(value));
    }

    private Long optionalLong(Object value) {
        if (value == null || String.valueOf(value).trim().isEmpty()) {
            return null;
        }
        return Long.valueOf(String.valueOf(value));
    }

    private Integer optionalInt(Object value, Integer defaultValue) {
        if (value == null || String.valueOf(value).trim().isEmpty()) {
            return defaultValue;
        }
        return Integer.valueOf(String.valueOf(value));
    }

    private String stringOf(Object value) {
        return value == null ? null : String.valueOf(value);
    }
}
