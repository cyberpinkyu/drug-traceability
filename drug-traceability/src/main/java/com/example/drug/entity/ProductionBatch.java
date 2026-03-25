package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("production_batch")
public class ProductionBatch {
    private Long id;
    @NotBlank(message = "batchNumber不能为空")
    private String batchNumber;
    @NotNull(message = "drugId不能为空")
    private Long drugId;
    @NotNull(message = "productionDate不能为空")
    private LocalDate productionDate;
    @NotNull(message = "expiryDate不能为空")
    private LocalDate expiryDate;
    @Min(value = 1, message = "productionQuantity必须大于0")
    private Integer productionQuantity;
    @NotNull(message = "producerId不能为空")
    private Long producerId;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
