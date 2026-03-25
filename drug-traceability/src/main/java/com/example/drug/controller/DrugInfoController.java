package com.example.drug.controller;

import com.example.drug.common.RequireRole;
import com.example.drug.entity.DrugInfo;
import com.example.drug.service.DrugInfoService;
import com.example.drug.utils.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/drug")
public class DrugInfoController {

    @Autowired
    private DrugInfoService drugInfoService;

    @GetMapping("/info")
    public Map<String, Object> getDrugs() {
        List<DrugInfo> drugs = drugInfoService.list();
        return MapUtils.of("code", 200, "data", drugs);
    }

    @GetMapping("/info/{id}")
    public Map<String, Object> getDrugById(@PathVariable Long id) {
        DrugInfo drug = drugInfoService.getById(id);
        return MapUtils.of("code", 200, "data", drug);
    }

    @GetMapping("/info/code/{code}")
    public Map<String, Object> getDrugByCode(@PathVariable String code) {
        DrugInfo drug = drugInfoService.getDrugByCode(code);
        return MapUtils.of("code", 200, "data", drug);
    }

    @GetMapping("/info/category/{category}")
    public Map<String, Object> getDrugsByCategory(@PathVariable String category) {
        List<DrugInfo> drugs = drugInfoService.getDrugsByCategory(category);
        return MapUtils.of("code", 200, "data", drugs);
    }

    @GetMapping("/info/search")
    public Map<String, Object> searchDrugs(@RequestParam String keyword) {
        List<DrugInfo> drugs = drugInfoService.searchDrugs(keyword);
        return MapUtils.of("code", 200, "data", drugs);
    }

    @RequireRole({"admin", "producer"})
    @PostMapping("/info")
    public Map<String, Object> addDrug(@Valid @RequestBody DrugInfo drugInfo) {
        boolean success = drugInfoService.save(drugInfo);
        if (success) {
            return MapUtils.of("code", 200, "message", "添加成功");
        }
        return MapUtils.of("code", 500, "message", "添加失败");
    }

    @RequireRole({"admin", "producer"})
    @PutMapping("/info/{id}")
    @PostMapping("/info/{id}")
    public Map<String, Object> updateDrug(@PathVariable Long id, @Valid @RequestBody DrugInfo drugInfo) {
        drugInfo.setId(id);
        boolean success = drugInfoService.updateById(drugInfo);
        if (success) {
            return MapUtils.of("code", 200, "message", "更新成功");
        }
        return MapUtils.of("code", 500, "message", "更新失败");
    }

    @RequireRole({"admin"})
    @DeleteMapping("/info/{id}")
    public Map<String, Object> deleteDrug(@PathVariable Long id) {
        boolean success = drugInfoService.removeById(id);
        if (success) {
            return MapUtils.of("code", 200, "message", "删除成功");
        }
        return MapUtils.of("code", 500, "message", "删除失败");
    }

    @RequireRole({"admin", "producer"})
    @PutMapping("/info/{id}/status")
    public Map<String, Object> updateDrugStatus(
        @PathVariable Long id,
        @RequestParam(required = false) Integer status,
        @RequestBody(required = false) Map<String, Object> body
    ) {
        Integer finalStatus = status;
        if (finalStatus == null && body != null && body.get("status") != null) {
            finalStatus = Integer.valueOf(String.valueOf(body.get("status")));
        }

        if (finalStatus == null) {
            return MapUtils.of("code", 400, "message", "status不能为空");
        }

        boolean success = drugInfoService.updateDrugStatus(id, finalStatus);
        if (success) {
            return MapUtils.of("code", 200, "message", "状态更新成功");
        }
        return MapUtils.of("code", 500, "message", "状态更新失败");
    }
}
