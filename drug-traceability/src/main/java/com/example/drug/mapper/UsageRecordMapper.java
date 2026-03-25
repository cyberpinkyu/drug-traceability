package com.example.drug.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.drug.entity.UsageRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface UsageRecordMapper extends BaseMapper<UsageRecord> {
    @Select("SELECT ur.*, di.name AS drugName FROM usage_record ur " +
            "JOIN drug_info di ON ur.drug_id = di.id " +
            "WHERE ur.hospital_id = #{orgId} OR ur.doctor_id = #{orgId} " +
            "ORDER BY ur.created_at DESC")
    List<UsageRecord> getRecordsByOrganizationId(@Param("orgId") Long orgId);
}
