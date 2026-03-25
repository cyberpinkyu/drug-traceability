package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("inventory")
public class Inventory {
    private Long id;
    private Long batchId;
    private Long organizationId;
    private Integer quantity;
    private LocalDate lastUpdateDate;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
