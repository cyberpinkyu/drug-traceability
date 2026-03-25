package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("sale_record")
public class SaleRecord {
    private Long id;
    @NotNull(message = "batchId不能为空")
    private Long batchId;
    @NotNull(message = "sellerId不能为空")
    private Long sellerId;
    @NotNull(message = "buyerId不能为空")
    private Long buyerId;
    @Min(value = 1, message = "quantity必须大于0")
    private Integer quantity;
    @NotNull(message = "saleDate不能为空")
    private LocalDate saleDate;
    private BigDecimal salePrice;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
