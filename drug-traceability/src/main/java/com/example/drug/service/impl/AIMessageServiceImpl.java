package com.example.drug.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.AIMessage;
import com.example.drug.mapper.AIMessageMapper;
import com.example.drug.service.AIMessageService;
import org.springframework.stereotype.Service;

@Service
public class AIMessageServiceImpl extends ServiceImpl<AIMessageMapper, AIMessage> implements AIMessageService {
}
