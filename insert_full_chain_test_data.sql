-- 全链路测试数据（生产 -> 采购 -> 销售 -> 使用 -> 不良反应 -> 追溯）
-- 适用数据库：drug_traceability
-- 执行前请确认已完成建表（推荐先执行 create_tables.sql 或 init_db.sql）

USE drug_traceability;

SET FOREIGN_KEY_CHECKS = 0;

-- 1) 清理历史数据（按依赖顺序）
TRUNCATE TABLE `ai_tool_usage_log`;
TRUNCATE TABLE `ai_message`;
TRUNCATE TABLE `ai_conversation`;
TRUNCATE TABLE `trace_record`;
TRUNCATE TABLE `adverse_reaction`;
TRUNCATE TABLE `usage_record`;
TRUNCATE TABLE `sale_record`;
TRUNCATE TABLE `procurement_record`;
TRUNCATE TABLE `inventory`;
TRUNCATE TABLE `production_batch`;
TRUNCATE TABLE `drug_info`;
TRUNCATE TABLE `user`;
TRUNCATE TABLE `role`;

-- 某些建表脚本可能不含该表，做动态兼容清理
SET @has_reg_table := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = DATABASE()
    AND table_name = 'regulatory_enforcement'
);
SET @sql := IF(@has_reg_table > 0, 'TRUNCATE TABLE `regulatory_enforcement`', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS = 1;

-- 2) 基础字典数据
INSERT INTO `role` (`id`, `name`, `code`, `description`) VALUES
(1, '系统管理员', 'admin', '系统管理员'),
(2, '监管人员', 'regulator', '药监监管角色'),
(3, '生产企业', 'producer', '药品生产角色'),
(4, '经营企业', 'distributor', '药品流通角色'),
(5, '医疗机构', 'hospital', '医院/诊所角色'),
(6, '公众用户', 'public', '公众查询角色');

-- 密码先使用 123456（后端已支持首登自动升级为 bcrypt）
INSERT INTO `user` (`id`, `username`, `password`, `name`, `role_id`, `organization`, `phone`, `email`, `status`) VALUES
(1, 'admin',       '123456', '平台管理员', 1, '系统中心',            '13800000001', 'admin@test.local',       1),
(2, 'regulator',   '123456', '市监专员',   2, '市药监局',            '13800000002', 'regulator@test.local',   1),
(3, 'producer',    '123456', '生产负责人', 3, '华康制药有限公司',    '13800000003', 'producer@test.local',    1),
(4, 'distributor', '123456', '流通负责人', 4, '安平医药配送中心',    '13800000004', 'distributor@test.local', 1),
(5, 'hospital',    '123456', '医院药师',   5, '第一人民医院',        '13800000005', 'hospital@test.local',    1),
(6, 'public',      '123456', '公众用户',   6, '个人',                '13800000006', 'public@test.local',      1);

-- 3) 药品与批次（3条链路）
INSERT INTO `drug_info` (`id`, `drug_code`, `name`, `specification`, `manufacturer`, `approval_number`, `category`, `unit`, `price`, `status`) VALUES
(101, 'D1001', '阿莫西林胶囊',     '0.25g*24粒', '华康制药有限公司', '国药准字H13023371', '抗感染',   '盒', 22.50, 1),
(102, 'D1002', '布洛芬缓释胶囊',   '0.3g*20粒',  '华康制药有限公司', '国药准字H10900089', '解热镇痛', '盒', 28.00, 1),
(103, 'D1003', '盐酸二甲双胍片',   '0.5g*60片',  '华康制药有限公司', '国药准字H20023367', '内分泌',   '瓶', 18.80, 1);

INSERT INTO `production_batch` (`id`, `batch_number`, `drug_id`, `production_date`, `expiry_date`, `production_quantity`, `producer_id`, `status`) VALUES
(1001, 'B260301', 101, '2026-02-01', '2028-01-31', 10000, 3, 1),
(1002, 'B260302', 102, '2026-02-05', '2028-02-04',  8000, 3, 1),
(1003, 'B260303', 103, '2026-02-10', '2028-02-09',  6000, 3, 1);

-- 4) 流通记录
-- 链路A：生产企业(3) -> 经营企业(4) -> 医疗机构(5)
INSERT INTO `procurement_record` (`id`, `batch_id`, `buyer_id`, `supplier_id`, `quantity`, `purchase_date`, `purchase_price`, `status`) VALUES
(2001, 1001, 4, 3, 6000, '2026-02-12', 16.20, 1);
INSERT INTO `sale_record` (`id`, `batch_id`, `seller_id`, `buyer_id`, `quantity`, `sale_date`, `sale_price`, `status`) VALUES
(3001, 1001, 4, 5, 4200, '2026-02-14', 20.80, 1);

-- 链路B：生产企业(3) -> 经营企业(4) -> 医疗机构(5)
INSERT INTO `procurement_record` (`id`, `batch_id`, `buyer_id`, `supplier_id`, `quantity`, `purchase_date`, `purchase_price`, `status`) VALUES
(2002, 1002, 4, 3, 5000, '2026-02-15', 20.50, 1);
INSERT INTO `sale_record` (`id`, `batch_id`, `seller_id`, `buyer_id`, `quantity`, `sale_date`, `sale_price`, `status`) VALUES
(3002, 1002, 4, 5, 2500, '2026-02-18', 25.60, 1);

-- 链路C：生产企业(3) -> 医疗机构(5)
INSERT INTO `procurement_record` (`id`, `batch_id`, `buyer_id`, `supplier_id`, `quantity`, `purchase_date`, `purchase_price`, `status`) VALUES
(2003, 1003, 5, 3, 3000, '2026-02-16', 11.20, 1);

-- 5) 库存快照（与流转数量严格对账）
-- B260301: 10000 - 6000 = 4000(生产), 6000 - 4200 = 1800(经营), 4200(医院)
-- B260302:  8000 - 5000 = 3000(生产), 5000 - 2500 = 2500(经营), 2500(医院)
-- B260303:  6000 - 3000 = 3000(生产), 3000(医院)
INSERT INTO `inventory` (`id`, `batch_id`, `organization_id`, `quantity`, `last_update_date`, `status`) VALUES
(4001, 1001, 3, 4000, '2026-02-14', 1),
(4002, 1001, 4, 1800, '2026-02-14', 1),
(4003, 1001, 5, 4200, '2026-02-14', 1),
(4004, 1002, 3, 3000, '2026-02-18', 1),
(4005, 1002, 4, 2500, '2026-02-18', 1),
(4006, 1002, 5, 2500, '2026-02-18', 1),
(4007, 1003, 3, 3000, '2026-02-16', 1),
(4008, 1003, 5, 3000, '2026-02-16', 1);

-- 6) 医疗使用记录 + 不良反应（闭环）
INSERT INTO `usage_record` (`id`, `drug_id`, `patient_name`, `dosage`, `frequency`, `usage_date`, `doctor_id`, `hospital`, `status`) VALUES
(5001, 101, '张某', '0.5g', '每日3次', '2026-02-20', 5, '第一人民医院', 1),
(5002, 102, '李某', '0.3g', '每日2次', '2026-02-21', 5, '第一人民医院', 1),
(5003, 103, '王某', '0.5g', '每日2次', '2026-02-22', 5, '第一人民医院', 1);

INSERT INTO `adverse_reaction` (`id`, `drug_id`, `patient_name`, `reaction_description`, `severity`, `hospital`, `doctor_name`, `reporter_id`, `status`, `created_at`) VALUES
(6001, 101, '张某', '服用后出现轻度皮疹与瘙痒，停药后缓解', '轻度', '第一人民医院', '赵医生', 5, 1, '2026-02-21 10:30:00');

-- 7) 追溯节点（可被前端追溯页直接展示）
INSERT INTO `trace_record` (`id`, `drug_code`, `batch_number`, `trace_step`, `step_time`, `organization`, `description`, `status`) VALUES
(7001, 'D1001', 'B260301', '原料采购', '2026-02-01 08:10:00', '华康制药有限公司', '原料入厂并完成检验', 1),
(7002, 'D1001', 'B260301', '生产加工', '2026-02-01 14:20:00', '华康制药有限公司', '完成制粒与装胶囊', 1),
(7003, 'D1001', 'B260301', '质量放行', '2026-02-02 10:00:00', '华康制药有限公司', '批次检验合格，准予放行', 1),
(7004, 'D1001', 'B260301', '采购入库', '2026-02-12 15:00:00', '安平医药配送中心', '经营企业完成采购入库', 1),
(7005, 'D1001', 'B260301', '销售出库', '2026-02-14 09:30:00', '安平医药配送中心', '销售至第一人民医院', 1),
(7006, 'D1001', 'B260301', '临床使用', '2026-02-20 11:00:00', '第一人民医院', '用于门诊感染治疗', 1),
(7007, 'D1001', 'B260301', '不良反应上报', '2026-02-21 10:30:00', '第一人民医院', '已完成不良反应在线上报', 1),

(7101, 'D1002', 'B260302', '原料采购', '2026-02-05 08:00:00', '华康制药有限公司', '原料入厂检验合格', 1),
(7102, 'D1002', 'B260302', '生产加工', '2026-02-05 13:30:00', '华康制药有限公司', '完成缓释工艺生产', 1),
(7103, 'D1002', 'B260302', '采购入库', '2026-02-15 16:20:00', '安平医药配送中心', '经营企业采购入库', 1),
(7104, 'D1002', 'B260302', '销售出库', '2026-02-18 10:15:00', '安平医药配送中心', '销售至第一人民医院', 1),

(7201, 'D1003', 'B260303', '生产加工', '2026-02-10 15:00:00', '华康制药有限公司', '完成压片与包装', 1),
(7202, 'D1003', 'B260303', '采购入库', '2026-02-16 11:40:00', '第一人民医院', '医院直接采购入库', 1),
(7203, 'D1003', 'B260303', '临床使用', '2026-02-22 09:10:00', '第一人民医院', '用于门诊糖代谢管理', 1);

-- 8) 监管抽检（若表存在则插入）
SET @sql := IF(
  @has_reg_table > 0,
  'INSERT INTO `regulatory_enforcement` (`id`, `inspector_id`, `organization_id`, `inspection_type`, `inspection_result`, `description`, `inspection_date`, `status`) VALUES (8001, 2, 4, ''专项飞检'', ''合格'', ''冷链温控与票据留存完整'', ''2026-02-25'', 1)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 9) 快速核对查询（可选执行）
-- SELECT batch_number, production_quantity FROM production_batch ORDER BY id;
-- SELECT * FROM procurement_record ORDER BY id;
-- SELECT * FROM sale_record ORDER BY id;
-- SELECT batch_id, organization_id, quantity FROM inventory ORDER BY batch_id, organization_id;
-- SELECT drug_code, batch_number, trace_step, step_time FROM trace_record ORDER BY batch_number, step_time;
-- SELECT * FROM adverse_reaction;
