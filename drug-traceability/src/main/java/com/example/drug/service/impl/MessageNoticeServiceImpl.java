package com.example.drug.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.MessageNotice;
import com.example.drug.mapper.MessageNoticeMapper;
import com.example.drug.service.MessageNoticeService;
import org.springframework.stereotype.Service;

@Service
public class MessageNoticeServiceImpl extends ServiceImpl<MessageNoticeMapper, MessageNotice> implements MessageNoticeService {
}
