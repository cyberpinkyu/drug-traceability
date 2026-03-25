package com.example.drug.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.drug.common.BusinessException;
import com.example.drug.entity.Inventory;
import com.example.drug.mapper.InventoryMapper;
import com.example.drug.service.InventoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class InventoryServiceImpl extends ServiceImpl<InventoryMapper, Inventory> implements InventoryService {

    @Override
    public Inventory getInventoryByBatchAndOrg(Long batchId, Long organizationId) {
        QueryWrapper<Inventory> wrapper = new QueryWrapper<>();
        wrapper.eq("batch_id", batchId)
               .eq("organization_id", organizationId);
        return baseMapper.selectOne(wrapper);
    }

    @Override
    public List<Inventory> getInventoriesByOrganizationId(Long organizationId) {
        QueryWrapper<Inventory> wrapper = new QueryWrapper<>();
        wrapper.eq("organization_id", organizationId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    public List<Inventory> getInventoriesByBatchId(Long batchId) {
        QueryWrapper<Inventory> wrapper = new QueryWrapper<>();
        wrapper.eq("batch_id", batchId);
        return baseMapper.selectList(wrapper);
    }

    @Override
    @Transactional
    public boolean updateInventoryQuantity(Long id, Integer newQuantity) {
        Inventory current = getById(id);
        if (current == null) {
            throw new BusinessException(404, "库存记录不存在");
        }
        int delta = newQuantity - current.getQuantity();
        return adjustInventoryQuantity(id, delta);
    }

    @Override
    @Transactional
    public boolean adjustInventoryQuantity(Long id, Integer delta) {
        int updated = baseMapper.adjustQuantityAtomically(id, delta, LocalDate.now());
        if (updated == 0) {
            if (delta < 0) {
                throw new BusinessException(400, "库存不足，无法执行操作");
            }
            throw new BusinessException(404, "库存记录不存在");
        }
        return true;
    }
}
