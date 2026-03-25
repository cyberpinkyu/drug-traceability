package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("regulatory_task")
public class RegulatoryTask {
    private Long id;
    private Long reportId;
    private Long assigneeId;
    private String suspectedSource;
    private Long suspectedOrgId;
    private String conclusionSource;
    private Long conclusionOrgId;
    private Integer verified;
    private String investigationResult;
    private Integer status;
    private LocalDateTime dispatchedAt;
    private LocalDateTime investigatedAt;
    private LocalDateTime enforcedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}