package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("message_notice")
public class MessageNotice {
    private Long id;
    private String title;
    private String content;
    private String channel;
    private Long receiverId;
    private String receiverContact;
    private String bizType;
    private Long bizId;
    private Integer status;
    private LocalDateTime sentAt;
    private LocalDateTime readAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
