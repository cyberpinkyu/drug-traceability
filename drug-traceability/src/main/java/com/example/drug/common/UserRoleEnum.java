package com.example.drug.common;

public enum UserRoleEnum {
    ADMIN(1L, "admin", "管理员", "admin@example.com", "13800138000"),
    REGULATOR(2L, "regulator", "监管人员", "regulator@example.com", "13800138001"),
    PRODUCER(3L, "producer", "生产企业", "producer@example.com", "13800138002"),
    DISTRIBUTOR(4L, "distributor", "流通企业", "distributor@example.com", "13800138003"),
    HOSPITAL(5L, "hospital", "医疗机构", "hospital@example.com", "13800138004"),
    PUBLIC(6L, "public", "公众用户", "public@example.com", "13800138005");

    private final Long roleId;
    private final String roleCode;
    private final String roleName;
    private final String email;
    private final String phone;

    UserRoleEnum(Long roleId, String roleCode, String roleName, String email, String phone) {
        this.roleId = roleId;
        this.roleCode = roleCode;
        this.roleName = roleName;
        this.email = email;
        this.phone = phone;
    }

    public Long getRoleId() { return roleId; }
    public String getRoleCode() { return roleCode; }
    public String getRoleName() { return roleName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }

    public static UserRoleEnum fromUsername(String username) {
        for (UserRoleEnum role : values()) {
            if (role.roleCode.equals(username)) {
                return role;
            }
        }
        return PUBLIC;
    }
}
