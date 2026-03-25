USE drug_traceability;

-- 插入初始角色数据
INSERT INTO `role` (`name`, `code`, `description`) VALUES
('超级管理员', 'super_admin', '系统最高权限'),
('监管人员', 'regulator', '药品监管人员'),
('生产企业', 'producer', '药品生产企业'),
('经营企业', 'distributor', '药品经营企业'),
('医疗机构', 'hospital', '医疗机构'),
('公众', 'public', '普通公众');

-- 插入初始用户数据
INSERT INTO `user` (`username`, `password`, `name`, `role_id`, `organization`, `phone`, `email`, `status`) VALUES
('admin', '123456', '超级管理员', 1, '系统管理', '13800138000', 'admin@example.com', 1),
('regulator', '123456', '监管人员', 2, '药监局', '13800138001', 'regulator@example.com', 1),
('producer', '123456', '生产企业', 3, '制药公司', '13800138002', 'producer@example.com', 1),
('distributor', '123456', '经营企业', 4, '医药公司', '13800138003', 'distributor@example.com', 1),
('hospital', '123456', '医疗机构', 5, '医院', '13800138004', 'hospital@example.com', 1),
('public', '123456', '公众', 6, '个人', '13800138005', 'public@example.com', 1);
