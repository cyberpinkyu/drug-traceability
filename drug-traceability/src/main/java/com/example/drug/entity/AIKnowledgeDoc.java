package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AIKnowledgeDoc {
    @TableId(type = IdType.ASSIGN_ID)
    private Long docId;
    
    private String fileName;
    
    private String originalText;
    
    private String chunkText;
    
    private String embeddingVectorId;
    
    private String source;
    
    private LocalDateTime updateTime;
}
