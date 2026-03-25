package com.example.drug.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.drug.entity.AdverseReaction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface AdverseReactionMapper extends BaseMapper<AdverseReaction> {
    @Select("SELECT ar.*, di.name AS drugName FROM adverse_reaction ar " +
            "JOIN drug_info di ON ar.drug_id = di.id " +
            "WHERE ar.hospital = (SELECT organization FROM user WHERE id = #{orgId}) " +
            "ORDER BY ar.created_at DESC")
    List<AdverseReaction> getRecordsByOrganizationId(@Param("orgId") Long orgId);
}
