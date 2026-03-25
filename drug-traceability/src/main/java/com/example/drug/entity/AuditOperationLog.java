package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("audit_operation_log")
public class AuditOperationLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long actorId;
    private String actorUsername;
    private String actorRole;
    private String method;
    private String path;
    private String queryString;
    private Integer statusCode;
    private String clientIp;
    private String userAgent;

    private String targetType;
    private Long targetId;
    private String requestBody;
    private String beforeJson;
    private String afterJson;
    private String diffJson;

    private LocalDateTime occurredAt;
}