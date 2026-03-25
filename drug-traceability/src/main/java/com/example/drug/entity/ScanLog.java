package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("scan_log")
public class ScanLog {
    private Long id;
    private String traceCode;
    private String deviceId;
    private String signature;
    private Long requestTs;
    private Integer verifyPassed;
    private Integer offlineFlag;
    private String sourceIp;
    private LocalDateTime createdAt;
}
