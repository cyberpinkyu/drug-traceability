package com.example.drug.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.ScanLog;
import com.example.drug.mapper.ScanLogMapper;
import com.example.drug.service.ScanLogService;
import org.springframework.stereotype.Service;

@Service
public class ScanLogServiceImpl extends ServiceImpl<ScanLogMapper, ScanLog> implements ScanLogService {
}
