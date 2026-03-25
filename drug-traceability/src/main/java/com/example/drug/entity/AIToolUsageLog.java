package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AIToolUsageLog {
    @TableId(type = IdType.ASSIGN_ID)
    private Long logId;
    
    private String conversationId;
    
    private String toolName;
    
    private String parameters;
    
    private String result;
    
    private String status;
    
    private Long userId;
    
    private Integer costTime;
    
    private LocalDateTime invokeTime;
}
