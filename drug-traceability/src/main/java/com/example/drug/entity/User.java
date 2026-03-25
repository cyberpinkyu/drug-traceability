package com.example.drug.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {
    private Long id;
    private String username;
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;
    private String name;
    private Long roleId;
    private String organization;
    private String phone;
    private String email;
    private Integer status;
    @TableField(exist = false)
    private String roleCode;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}