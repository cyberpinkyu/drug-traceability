package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.UsageRecord;
import com.example.drug.mapper.UsageRecordMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UsageRecordService extends ServiceImpl<UsageRecordMapper, UsageRecord> {
    @Autowired
    private UsageRecordMapper usageRecordMapper;

    public List<UsageRecord> getRecordsByOrganizationId(Long orgId) {
        return usageRecordMapper.getRecordsByOrganizationId(orgId);
    }
}
