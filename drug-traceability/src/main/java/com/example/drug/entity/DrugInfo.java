package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotBlank;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("drug_info")
public class DrugInfo {
    private Long id;
    @NotBlank(message = "drugCode不能为空")
    private String drugCode;
    @NotBlank(message = "name不能为空")
    private String name;
    private String specification;
    @NotBlank(message = "manufacturer不能为空")
    private String manufacturer;
    private String approvalNumber;
    private String category;
    private String unit;
    @DecimalMin(value = "0", message = "price不能小于0")
    private BigDecimal price;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
