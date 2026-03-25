package com.example.drug.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.AlertTicket;
import com.example.drug.mapper.AlertTicketMapper;
import com.example.drug.service.AlertTicketService;
import org.springframework.stereotype.Service;

@Service
public class AlertTicketServiceImpl extends ServiceImpl<AlertTicketMapper, AlertTicket> implements AlertTicketService {
}
