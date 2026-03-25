package com.example.drug.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.drug.entity.Inventory;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDate;

public interface InventoryMapper extends BaseMapper<Inventory> {

    @Update("UPDATE inventory SET quantity = quantity + #{delta}, last_update_date = #{lastUpdateDate} " +
        "WHERE id = #{id} AND quantity + #{delta} >= 0")
    int adjustQuantityAtomically(@Param("id") Long id,
                                 @Param("delta") Integer delta,
                                 @Param("lastUpdateDate") LocalDate lastUpdateDate);
}
