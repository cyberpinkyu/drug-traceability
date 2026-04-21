package com.example.drug.controller;

import com.example.drug.common.RequireRole;
import com.example.drug.entity.AdverseReaction;
import com.example.drug.entity.DrugInfo;
import com.example.drug.entity.RegulatoryEnforcement;
import com.example.drug.entity.RegulatoryTask;
import com.example.drug.entity.Role;
import com.example.drug.entity.User;
import com.example.drug.service.AdverseReactionService;
import com.example.drug.service.DrugInfoService;
import com.example.drug.service.RegulatoryEnforcementService;
import com.example.drug.service.RegulatoryTaskService;
import com.example.drug.service.RoleService;
import com.example.drug.service.StatsService;
import com.example.drug.service.UserService;
import com.example.drug.utils.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/regulatory")
public class RegulatoryController {

    @Autowired
    private RegulatoryEnforcementService regulatoryEnforcementService;

    @Autowired
    private StatsService statsService;

    @Autowired
    private RegulatoryTaskService regulatoryTaskService;

    @Autowired
    private UserService userService;

    @Autowired
    private RoleService roleService;

    @Autowired
    private AdverseReactionService adverseReactionService;

    @Autowired
    private DrugInfoService drugInfoService;

    @RequireRole({"admin", "regulator"})
    @GetMapping("/enforcement")
    public Map<String, Object> getEnforcements() {
        List<RegulatoryEnforcement> enforcements = regulatoryEnforcementService.list();
        return MapUtils.of("code", 200, "data", enforcements);
    }

    @RequireRole({"admin", "regulator"})
    @PostMapping("/enforcement")
    public Map<String, Object> addEnforcement(@RequestBody RegulatoryEnforcement enforcement) {
        boolean success = regulatoryEnforcementService.save(enforcement);
        return success
            ? MapUtils.of("code", 200, "message", "添加成功")
            : MapUtils.of("code", 500, "message", "添加失败");
    }

    @RequireRole({"admin", "regulator"})
    @PutMapping("/enforcement/{id}")
    public Map<String, Object> updateEnforcement(@PathVariable Long id, @RequestBody RegulatoryEnforcement enforcement) {
        enforcement.setId(id);
        boolean success = regulatoryEnforcementService.updateById(enforcement);
        return success
            ? MapUtils.of("code", 200, "message", "更新成功")
            : MapUtils.of("code", 500, "message", "更新失败");
    }

    @RequireRole({"admin", "regulator"})
    @DeleteMapping("/enforcement/{id}")
    public Map<String, Object> deleteEnforcement(@PathVariable Long id) {
        boolean success = regulatoryEnforcementService.removeById(id);
        return success
            ? MapUtils.of("code", 200, "message", "删除成功")
            : MapUtils.of("code", 500, "message", "删除失败");
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/inspectors")
    public Map<String, Object> getInspectors() {
        Role role = roleService.getRoleByCode("regulator");
        if (role == null) {
            return MapUtils.of("code", 200, "data", Collections.emptyList());
        }
        List<User> users = userService.getUsersByRoleId(role.getId());
        return MapUtils.of("code", 200, "data", users);
    }

    @RequireRole({"admin", "regulator"})
    @PostMapping("/tasks/dispatch")
    public Map<String, Object> dispatchTask(@RequestBody Map<String, Object> payload) {
        RegulatoryTask task = regulatoryTaskService.dispatchTask(payload);
        return MapUtils.of("code", 200, "message", "任务派发成功", "data", task);
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/tasks")
    public Map<String, Object> listTasks() {
        return MapUtils.of("code", 200, "data", regulatoryTaskService.list());
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/tasks/assignee/{assigneeId}")
    public Map<String, Object> listTasksByAssignee(@PathVariable Long assigneeId) {
        return MapUtils.of("code", 200, "data", regulatoryTaskService.listByAssignee(assigneeId));
    }

    @RequireRole({"admin", "regulator"})
    @PutMapping("/tasks/{id}/investigation")
    public Map<String, Object> investigateTask(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        RegulatoryTask task = regulatoryTaskService.investigateTask(id, payload);
        return MapUtils.of("code", 200, "message", "调查结果已提交", "data", task);
    }

    @RequireRole({"admin", "regulator"})
    @PostMapping("/tasks/{id}/enforcement")
    public Map<String, Object> enforceTask(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        RegulatoryTask task = regulatoryTaskService.enforceTask(id, payload);
        return MapUtils.of("code", 200, "message", "处罚已执行", "data", task);
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/stats/circulation")
    public Map<String, Object> getCirculationStats(@RequestParam String timeRange, @RequestParam String region) {
        return MapUtils.of("code", 200, "data", statsService.getCirculationStats(timeRange, region));
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/stats/inventory")
    public Map<String, Object> getInventoryStats() {
        return MapUtils.of("code", 200, "data", statsService.getInventoryStats());
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/stats/production")
    public Map<String, Object> getProductionStats() {
        return MapUtils.of("code", 200, "data", statsService.getProductionStats());
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/stats/risk")
    public Map<String, Object> getRiskStats() {
        return MapUtils.of("code", 200, "data", statsService.getRiskStats());
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/stats/risk-map")
    public Map<String, Object> getRiskMap() {
        List<Map<String, Object>> points = new ArrayList<Map<String, Object>>();
        for (AdverseReaction reaction : adverseReactionService.list()) {
            Map<String, Object> point = new HashMap<String, Object>();
            point.put("id", reaction.getId());
            point.put("riskLevel", normalizeSeverity(reaction.getSeverity()));
            point.put("latitude", resolveLatitude(reaction.getHospital()));
            point.put("longitude", resolveLongitude(reaction.getHospital()));

            DrugInfo drug = drugInfoService.getById(reaction.getDrugId());
            String drugName = drug == null ? "药品风险点" : drug.getName();
            String hospital = reaction.getHospital() == null ? "未知机构" : reaction.getHospital();
            point.put("name", hospital + " - " + drugName);
            points.add(point);
        }
        return MapUtils.of("code", 200, "data", points);
    }

    private String normalizeSeverity(String severity) {
        if ("high".equalsIgnoreCase(severity) || "medium".equalsIgnoreCase(severity) || "low".equalsIgnoreCase(severity)) {
            return severity.toLowerCase();
        }
        return "medium";
    }

    private double resolveLatitude(String hospital) {
        if (hospital != null && hospital.contains("第一人民医院")) {
            return 22.5431;
        }
        if (hospital != null && hospital.contains("儿童医院")) {
            return 22.5510;
        }
        return 22.5431;
    }

    private double resolveLongitude(String hospital) {
        if (hospital != null && hospital.contains("第一人民医院")) {
            return 114.0579;
        }
        if (hospital != null && hospital.contains("儿童医院")) {
            return 114.1095;
        }
        return 114.0579;
    }
}
