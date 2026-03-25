package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_message")
public class AIMessage {

    @TableId(type = IdType.AUTO)
    private Long messageId;

    private Long conversationId;

    private String role;

    private String content;

    private String toolCalls;

    @TableField("created_at")
    private LocalDateTime createTime;
}
