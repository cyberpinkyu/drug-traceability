package com.example.drug.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.entity.AdverseReaction;
import com.example.drug.mapper.AdverseReactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdverseReactionService extends ServiceImpl<AdverseReactionMapper, AdverseReaction> {
    @Autowired
    private AdverseReactionMapper adverseReactionMapper;

    public List<AdverseReaction> getRecordsByOrganizationId(Long orgId) {
        return adverseReactionMapper.getRecordsByOrganizationId(orgId);
    }
}
