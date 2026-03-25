package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("regulatory_enforcement")
public class RegulatoryEnforcement {
    private Long id;
    private Long inspectorId;
    private Long organizationId;
    private String inspectionType;
    private String inspectionResult;
    private String description;
    private LocalDateTime inspectionDate;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}