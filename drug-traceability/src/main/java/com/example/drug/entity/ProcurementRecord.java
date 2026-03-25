package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("procurement_record")
public class ProcurementRecord {
    private Long id;
    @NotNull(message = "鎵规ID涓嶈兘涓虹┖")
    private Long batchId;
    @NotNull(message = "閲囪喘鏂笽D涓嶈兘涓虹┖")
    private Long buyerId;
    @NotNull(message = "渚涘簲鍟咺D涓嶈兘涓虹┖")
    private Long supplierId;
    @Min(value = 1, message = "閲囪喘鏁伴噺涓嶈兘灏忎簬1")
    private Integer quantity;
    @NotNull(message = "閲囪喘鏃ユ湡涓嶈兘涓虹┖")
    private LocalDate purchaseDate;
    private BigDecimal purchasePrice;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
