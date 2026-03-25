package com.example.drug.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.drug.entity.AuditOperationLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AuditOperationLogMapper extends BaseMapper<AuditOperationLog> {
}