package com.example.drug.controller;

import com.example.drug.common.RequireRole;
import com.example.drug.entity.RegulatoryEnforcement;
import com.example.drug.entity.RegulatoryTask;
import com.example.drug.entity.Role;
import com.example.drug.entity.User;
import com.example.drug.service.RegulatoryEnforcementService;
import com.example.drug.service.RegulatoryTaskService;
import com.example.drug.service.RoleService;
import com.example.drug.service.StatsService;
import com.example.drug.service.UserService;
import com.example.drug.utils.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
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
}
