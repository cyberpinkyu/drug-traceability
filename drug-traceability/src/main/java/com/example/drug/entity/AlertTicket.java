package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("alert_ticket")
public class AlertTicket {
    private Long id;
    private String title;
    private String sourceType;
    private Long sourceId;
    private String severity;
    private Integer status;
    private Long assigneeId;
    private String description;
    private String closedResult;
    private LocalDateTime closedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
