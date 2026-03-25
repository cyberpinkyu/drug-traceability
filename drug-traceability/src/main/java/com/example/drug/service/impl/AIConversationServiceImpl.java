package com.example.drug.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.AIConversation;
import com.example.drug.mapper.AIConversationMapper;
import com.example.drug.service.AIConversationService;
import org.springframework.stereotype.Service;

@Service
public class AIConversationServiceImpl extends ServiceImpl<AIConversationMapper, AIConversation> implements AIConversationService {
}
