package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("usage_record")
public class UsageRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long drugId;
    private String patientName;
    private String dosage;
    private String frequency;
    private Date usageDate;
    private Long doctorId;
    private String hospital;
    private Integer status;
    private Date createdAt;
}
