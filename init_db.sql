CREATE DATABASE IF NOT EXISTS drug_traceability CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE drug_traceability;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL,
  `password` VARCHAR(100) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `role_id` BIGINT(20) NOT NULL,
  `organization` VARCHAR(100),
  `phone` VARCHAR(20),
  `email` VARCHAR(100),
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 角色表
CREATE TABLE IF NOT EXISTS `role` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 药品信息表
CREATE TABLE IF NOT EXISTS `drug_info` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `drug_code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `specification` VARCHAR(100),
  `manufacturer` VARCHAR(100),
  `approval_number` VARCHAR(50),
  `category` VARCHAR(50),
  `unit` VARCHAR(20),
  `price` DECIMAL(10,2),
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_drug_code` (`drug_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 生产批次表
CREATE TABLE IF NOT EXISTS `production_batch` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `batch_number` VARCHAR(50) NOT NULL,
  `drug_id` BIGINT(20) NOT NULL,
  `production_date` DATE NOT NULL,
  `expiry_date` DATE NOT NULL,
  `production_quantity` INT(11) NOT NULL,
  `producer_id` BIGINT(20) NOT NULL,
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_batch_number` (`batch_number`),
  KEY `idx_drug_id` (`drug_id`),
  KEY `idx_producer_id` (`producer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 采购记录表
CREATE TABLE IF NOT EXISTS `procurement_record` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `batch_id` BIGINT(20) NOT NULL,
  `buyer_id` BIGINT(20) NOT NULL,
  `supplier_id` BIGINT(20) NOT NULL,
  `quantity` INT(11) NOT NULL,
  `purchase_date` DATE NOT NULL,
  `purchase_price` DECIMAL(10,2),
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`),
  KEY `idx_buyer_id` (`buyer_id`),
  KEY `idx_supplier_id` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 销售记录表
CREATE TABLE IF NOT EXISTS `sale_record` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `batch_id` BIGINT(20) NOT NULL,
  `seller_id` BIGINT(20) NOT NULL,
  `buyer_id` BIGINT(20) NOT NULL,
  `quantity` INT(11) NOT NULL,
  `sale_date` DATE NOT NULL,
  `sale_price` DECIMAL(10,2),
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_id` (`batch_id`),
  KEY `idx_seller_id` (`seller_id`),
  KEY `idx_buyer_id` (`buyer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 库存表
CREATE TABLE IF NOT EXISTS `inventory` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `batch_id` BIGINT(20) NOT NULL,
  `organization_id` BIGINT(20) NOT NULL,
  `quantity` INT(11) NOT NULL,
  `last_update_date` DATE NOT NULL,
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_batch_org` (`batch_id`, `organization_id`),
  KEY `idx_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI会话记录表
CREATE TABLE IF NOT EXISTS `ai_conversation` (
  `conversation_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT(20) NOT NULL,
  `title` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI消息记录表
CREATE TABLE IF NOT EXISTS `ai_message` (
  `message_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `conversation_id` BIGINT(20) NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `content` TEXT NOT NULL,
  `tool_calls` JSON,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_conversation_id` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI知识文档向量表
CREATE TABLE IF NOT EXISTS `ai_knowledge_doc` (
  `doc_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `content` TEXT NOT NULL,
  `embedding_vector` BLOB,
  `source` VARCHAR(200),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`doc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI工具调用审计表
CREATE TABLE IF NOT EXISTS `ai_tool_usage_log` (
  `log_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `tool_name` VARCHAR(100) NOT NULL,
  `parameters` JSON NOT NULL,
  `result` TEXT,
  `user_id` BIGINT(20) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_tool_name` (`tool_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 监管执法表
CREATE TABLE IF NOT EXISTS `regulatory_enforcement` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `inspector_id` BIGINT(20) NOT NULL,
  `organization_id` BIGINT(20) NOT NULL,
  `inspection_type` VARCHAR(50) NOT NULL,
  `inspection_result` VARCHAR(100) NOT NULL,
  `description` TEXT,
  `inspection_date` DATE NOT NULL,
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_inspector_id` (`inspector_id`),
  KEY `idx_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- 插入初始药品数据
INSERT INTO `drug_info` (`drug_code`, `name`, `specification`, `manufacturer`, `approval_number`, `category`, `unit`, `price`, `status`) VALUES
('D001', '阿莫西林胶囊', '0.25g*24粒', '华北制药', '国药准字H13023371', '抗生素', '盒', 25.50, 1),
('D002', '布洛芬缓释胶囊', '0.3g*10粒', '中美史克', '国药准字H10900089', '解热镇痛', '盒', 32.80, 1),
('D003', '对乙酰氨基酚片', '0.5g*24片', '上海强生', '国药准字H31020539', '解热镇痛', '盒', 18.50, 1);

-- 插入初始生产批次数据
INSERT INTO `production_batch` (`batch_number`, `drug_id`, `production_date`, `expiry_date`, `production_quantity`, `producer_id`, `status`) VALUES
('B001', 1, '2026-01-01', '2028-01-01', 10000, 3, 1),
('B002', 2, '2026-01-02', '2028-01-02', 8000, 3, 1),
('B003', 3, '2026-01-03', '2028-01-03', 12000, 3, 1);

-- 插入初始库存数据
INSERT INTO `inventory` (`batch_id`, `organization_id`, `quantity`, `last_update_date`, `status`) VALUES
(1, 3, 5000, '2026-01-01', 1),
(2, 3, 4000, '2026-01-02', 1),
(3, 3, 6000, '2026-01-03', 1);

-- ============================================
-- 测试数据
-- ============================================

-- 插入更多药品数据
INSERT INTO `drug_info` (`drug_code`, `name`, `specification`, `manufacturer`, `approval_number`, `category`, `unit`, `price`, `status`) VALUES
('D004', '复方氨酚烷胺胶囊', '0.3g*12粒', '吉林华康', '国药准字H22026333', '解热镇痛', '盒', 22.00, 1),
('D005', '咳特灵胶囊', '0.36g*24粒', '广州白云山', '国药准字H44023234', '呼吸系统', '盒', 18.50, 1),
('D006', '维生素B1片', '10mg*100片', '上海信谊', '国药准字H31020823', '维生素', '瓶', 12.80, 1),
('D007', '葡萄糖酸钙口服液', '10ml*10支', '哈药集团', '国药准字H23021789', '补钙剂', '盒', 25.60, 1),
('D008', '乳酸菌素片', '0.4g*48片', '杭州民生', '国药准字H33021567', '消化系统', '瓶', 16.50, 1),
('D009', '健胃消食片', '0.6g*36片', '康恩贝', '国药准字Z33020234', '消化系统', '盒', 20.00, 1),
('D010', '黄连素片', '0.1g*48片', '北京益民', '国药准字H11020056', '消化系统', '瓶', 8.50, 1),
('D011', '三九感冒灵', '10g*10袋', '广州白云山', '国药准字Z44021111', '解表剂', '盒', 24.80, 1),
('D012', '蒲公英颗粒', '15g*10袋', '云南白药', '国药准字Z53020876', '清热解毒', '盒', 19.50, 1),
('D013', '板蓝根颗粒', '10g*10袋', '北京同仁堂', '国药准字Z11020001', '清热解毒', '盒', 15.80, 1);

-- 插入更多生产批次数据
INSERT INTO `production_batch` (`batch_number`, `drug_id`, `production_date`, `expiry_date`, `production_quantity`, `producer_id`, `status`) VALUES
('B004', 4, '2026-01-04', '2028-01-04', 8000, 3, 1),
('B005', 5, '2026-01-05', '2028-01-05', 10000, 3, 1),
('B006', 6, '2026-01-06', '2028-01-06', 15000, 3, 1),
('B007', 7, '2026-01-07', '2028-01-07', 12000, 3, 1),
('B008', 8, '2026-01-08', '2028-01-08', 20000, 3, 1),
('B009', 9, '2026-01-09', '2028-01-09', 15000, 3, 1),
('B010', 10, '2026-01-10', '2028-01-10', 20000, 3, 1),
('B011', 11, '2026-01-11', '2028-01-11', 12000, 3, 1),
('B012', 12, '2026-01-12', '2028-01-12', 10000, 3, 1),
('B013', 13, '2026-01-13', '2028-01-13', 15000, 3, 1);

-- 插入更多库存数据
INSERT INTO `inventory` (`batch_id`, `organization_id`, `quantity`, `last_update_date`, `status`) VALUES
(4, 3, 4000, '2026-01-04', 1),
(5, 3, 5000, '2026-01-05', 1),
(6, 3, 7500, '2026-01-06', 1),
(7, 3, 6000, '2026-01-07', 1),
(8, 3, 10000, '2026-01-08', 1),
(9, 3, 7500, '2026-01-09', 1),
(10, 3, 10000, '2026-01-10', 1),
(11, 3, 6000, '2026-01-11', 1),
(12, 3, 5000, '2026-01-12', 1),
(13, 3, 7500, '2026-01-13', 1);

-- 插入采购记录数据
INSERT INTO `procurement_record` (`batch_id`, `buyer_id`, `supplier_id`, `quantity`, `purchase_date`, `purchase_price`, `status`) VALUES
(4, 4, 3, 600, '2026-01-14', 18.00, 1),
(5, 4, 3, 800, '2026-01-15', 15.00, 1),
(6, 4, 3, 1000, '2026-01-16', 10.00, 1),
(7, 4, 3, 800, '2026-01-17', 20.00, 1),
(8, 4, 3, 1200, '2026-01-18', 12.00, 1),
(9, 4, 3, 900, '2026-01-19', 16.00, 1),
(10, 4, 3, 1500, '2026-01-20', 6.00, 1),
(11, 4, 3, 800, '2026-01-21', 20.00, 1),
(12, 4, 3, 600, '2026-01-22', 15.00, 1),
(13, 4, 3, 1000, '2026-01-23', 12.00, 1);

-- 插入销售记录数据
INSERT INTO `sale_record` (`batch_id`, `seller_id`, `buyer_id`, `quantity`, `sale_date`, `sale_price`, `status`) VALUES
(4, 4, 5, 300, '2026-01-24', 22.00, 1),
(5, 4, 5, 400, '2026-01-25', 18.50, 1),
(6, 4, 5, 500, '2026-01-26', 12.80, 1),
(7, 4, 5, 400, '2026-01-27', 25.60, 1),
(8, 4, 5, 600, '2026-01-28', 16.50, 1),
(9, 4, 5, 450, '2026-01-29', 20.00, 1),
(10, 4, 5, 750, '2026-01-30', 8.50, 1),
(11, 4, 5, 400, '2026-01-31', 24.80, 1),
(12, 4, 5, 300, '2026-02-01', 19.50, 1),
(13, 4, 5, 500, '2026-02-02', 15.80, 1);

-- 插入用药记录数据
INSERT INTO `usage_record` (`drug_id`, `patient_name`, `dosage`, `frequency`, `usage_date`, `doctor_id`, `hospital`, `status`) VALUES
(4, '王明', '2粒', '每日3次', '2026-02-03', 5, '第一人民医院', 1),
(5, '李红', '3粒', '每日2次', '2026-02-04', 5, '第二人民医院', 1),
(6, '张伟', '2片', '每日1次', '2026-02-05', 5, '第三人民医院', 1),
(7, '赵芳', '10ml', '每日2次', '2026-02-06', 5, '第一人民医院', 1),
(8, '刘强', '4片', '每日3次', '2026-02-07', 5, '第二人民医院', 1),
(9, '陈静', '4片', '每日3次', '2026-02-08', 5, '第三人民医院', 1),
(10, '黄勇', '3片', '每日3次', '2026-02-09', 5, '第一人民医院', 1),
(11, '周敏', '2袋', '每日3次', '2026-02-10', 5, '第二人民医院', 1),
(12, '吴刚', '1袋', '每日3次', '2026-02-11', 5, '第三人民医院', 1),
(13, '郑红', '1袋', '每日3次', '2026-02-12', 5, '第一人民医院', 1);

-- 插入不良反应记录数据
INSERT INTO `adverse_reaction` (`drug_id`, `patient_name`, `reaction_description`, `severity`, `hospital`, `doctor_name`, `reporter_id`, `status`, `created_at`) VALUES
(4, '李娜', '服用后出现轻微恶心', '轻度', '第一人民医院', '王医生', 5, 1, '2026-02-13 10:00:00'),
(5, '杨柳', '服用后出现轻微便秘', '轻度', '第二人民医院', '张医生', 5, 1, '2026-02-14 11:00:00'),
(6, '刘洋', '服用后出现轻微皮疹', '轻度', '第三人民医院', '赵医生', 5, 1, '2026-02-15 12:00:00'),
(7, '陈晨', '服用后出现轻微腹泻', '轻度', '第一人民医院', '钱医生', 5, 1, '2026-02-16 13:00:00'),
(8, '赵磊', '服用后出现轻微腹胀', '轻度', '第二人民医院', '孙医生', 5, 1, '2026-02-17 14:00:00'),
(9, '钱军', '服用后出现轻微口干', '轻度', '第三人民医院', '周医生', 5, 1, '2026-02-18 15:00:00'),
(10, '孙丽', '服用后出现轻微头晕', '轻度', '第一人民医院', '吴医生', 5, 1, '2026-02-19 16:00:00'),
(11, '王强', '服用后出现轻微心悸', '中度', '第二人民医院', '郑医生', 5, 1, '2026-02-20 17:00:00'),
(12, '张敏', '服用后出现轻微皮疹', '轻度', '第三人民医院', '王医生', 5, 1, '2026-02-21 18:00:00'),
(13, '李军', '服用后出现轻微腹泻', '轻度', '第一人民医院', '李医生', 5, 1, '2026-02-22 19:00:00');

-- 插入追溯记录数据
INSERT INTO `trace_record` (`drug_code`, `batch_number`, `trace_step`, `step_time`, `organization`, `description`, `status`) VALUES
('D004', 'B004', '原料采购', '2026-01-04 08:00:00', '原料供应商', '原料采购完成', 1),
('D004', 'B004', '生产加工', '2026-01-05 10:30:00', '吉林华康厂', '生产加工完成', 1),
('D004', 'B004', '质量检验', '2026-01-06 14:00:00', '质检部门', '质量检验合格', 1),
('D004', 'B004', '包装入库', '2026-01-07 16:00:00', '仓储部', '包装入库完成', 1),
('D004', 'B004', '物流配送', '2026-01-08 09:00:00', '物流公司', '发货至医药公司', 1),
('D004', 'B004', '药店销售', '2026-02-03 10:00:00', '康健大药房', '销售给患者', 1),
('D005', 'B005', '原料采购', '2026-01-05 08:00:00', '原料供应商', '原料采购完成', 1),
('D005', 'B005', '生产加工', '2026-01-06 10:30:00', '广州白云山厂', '生产加工完成', 1),
('D005', 'B005', '质量检验', '2026-01-07 14:00:00', '质检部门', '质量检验合格', 1),
('D005', 'B005', '包装入库', '2026-01-08 16:00:00', '仓储部', '包装入库完成', 1),
('D005', 'B005', '物流配送', '2026-01-09 09:00:00', '物流公司', '发货至医药公司', 1),
('D005', 'B005', '药店销售', '2026-02-04 11:00:00', '康健大药房', '销售给患者', 1),
('D006', 'B006', '原料采购', '2026-01-06 08:00:00', '原料供应商', '原料采购完成', 1),
('D006', 'B006', '生产加工', '2026-01-07 10:30:00', '上海信谊厂', '生产加工完成', 1),
('D006', 'B006', '质量检验', '2026-01-08 14:00:00', '质检部门', '质量检验合格', 1),
('D006', 'B006', '包装入库', '2026-01-09 16:00:00', '仓储部', '包装入库完成', 1),
('D006', 'B006', '物流配送', '2026-01-10 09:00:00', '物流公司', '发货至医药公司', 1),
('D006', 'B006', '药店销售', '2026-02-05 12:00:00', '康健大药房', '销售给患者', 1),
('D007', 'B007', '原料采购', '2026-01-07 08:00:00', '原料供应商', '原料采购完成', 1),
('D007', 'B007', '生产加工', '2026-01-08 10:30:00', '哈药集团厂', '生产加工完成', 1),
('D007', 'B007', '质量检验', '2026-01-09 14:00:00', '质检部门', '质量检验合格', 1),
('D007', 'B007', '包装入库', '2026-01-10 16:00:00', '仓储部', '包装入库完成', 1),
('D007', 'B007', '物流配送', '2026-01-11 09:00:00', '物流公司', '发货至医药公司', 1),
('D007', 'B007', '药店销售', '2026-02-06 13:00:00', '康健大药房', '销售给患者', 1),
('D008', 'B008', '原料采购', '2026-01-08 08:00:00', '原料供应商', '原料采购完成', 1),
('D008', 'B008', '生产加工', '2026-01-09 10:30:00', '杭州民生厂', '生产加工完成', 1),
('D008', 'B008', '质量检验', '2026-01-10 14:00:00', '质检部门', '质量检验合格', 1),
('D008', 'B008', '包装入库', '2026-01-11 16:00:00', '仓储部', '包装入库完成', 1),
('D008', 'B008', '物流配送', '2026-01-12 09:00:00', '物流公司', '发货至医药公司', 1),
('D008', 'B008', '药店销售', '2026-02-07 14:00:00', '康健大药房', '销售给患者', 1),
('D009', 'B009', '原料采购', '2026-01-09 08:00:00', '原料供应商', '原料采购完成', 1),
('D009', 'B009', '生产加工', '2026-01-10 10:30:00', '康恩贝厂', '生产加工完成', 1),
('D009', 'B009', '质量检验', '2026-01-11 14:00:00', '质检部门', '质量检验合格', 1),
('D009', 'B009', '包装入库', '2026-01-12 16:00:00', '仓储部', '包装入库完成', 1),
('D009', 'B009', '物流配送', '2026-01-13 09:00:00', '物流公司', '发货至医药公司', 1),
('D009', 'B009', '药店销售', '2026-02-08 15:00:00', '康健大药房', '销售给患者', 1),
('D010', 'B010', '原料采购', '2026-01-10 08:00:00', '原料供应商', '原料采购完成', 1),
('D010', 'B010', '生产加工', '2026-01-11 10:30:00', '北京益民厂', '生产加工完成', 1),
('D010', 'B010', '质量检验', '2026-01-12 14:00:00', '质检部门', '质量检验合格', 1),
('D010', 'B010', '包装入库', '2026-01-13 16:00:00', '仓储部', '包装入库完成', 1),
('D010', 'B010', '物流配送', '2026-01-14 09:00:00', '物流公司', '发货至医药公司', 1),
('D010', 'B010', '药店销售', '2026-02-09 16:00:00', '康健大药房', '销售给患者', 1),
('D011', 'B011', '原料采购', '2026-01-11 08:00:00', '原料供应商', '原料采购完成', 1),
('D011', 'B011', '生产加工', '2026-01-12 10:30:00', '广州白云山厂', '生产加工完成', 1),
('D011', 'B011', '质量检验', '2026-01-13 14:00:00', '质检部门', '质量检验合格', 1),
('D011', 'B011', '包装入库', '2026-01-14 16:00:00', '仓储部', '包装入库完成', 1),
('D011', 'B011', '物流配送', '2026-01-15 09:00:00', '物流公司', '发货至医药公司', 1),
('D011', 'B011', '药店销售', '2026-02-10 17:00:00', '康健大药房', '销售给患者', 1),
('D012', 'B012', '原料采购', '2026-01-12 08:00:00', '原料供应商', '原料采购完成', 1),
('D012', 'B012', '生产加工', '2026-01-13 10:30:00', '云南白药厂', '生产加工完成', 1),
('D012', 'B012', '质量检验', '2026-01-14 14:00:00', '质检部门', '质量检验合格', 1),
('D012', 'B012', '包装入库', '2026-01-15 16:00:00', '仓储部', '包装入库完成', 1),
('D012', 'B012', '物流配送', '2026-01-16 09:00:00', '物流公司', '发货至医药公司', 1),
('D012', 'B012', '药店销售', '2026-02-11 18:00:00', '康健大药房', '销售给患者', 1),
('D013', 'B013', '原料采购', '2026-01-13 08:00:00', '原料供应商', '原料采购完成', 1),
('D013', 'B013', '生产加工', '2026-01-14 10:30:00', '北京同仁堂厂', '生产加工完成', 1),
('D013', 'B013', '质量检验', '2026-01-15 14:00:00', '质检部门', '质量检验合格', 1),
('D013', 'B013', '包装入库', '2026-01-16 16:00:00', '仓储部', '包装入库完成', 1),
('D013', 'B013', '物流配送', '2026-01-17 09:00:00', '物流公司', '发货至医药公司', 1),
('D013', 'B013', '药店销售', '2026-02-12 19:00:00', '康健大药房', '销售给患者', 1);

-- 插入AI会话记录数据
INSERT INTO `ai_conversation` (`user_id`, `title`, `created_at`, `updated_at`) VALUES
(1, '药品相互作用咨询', '2026-01-20 10:00:00', '2026-01-20 10:30:00'),
(2, '不良反应处理建议', '2026-01-21 14:00:00', '2026-01-21 14:20:00'),
(3, '用药剂量调整', '2026-01-22 09:00:00', '2026-01-22 09:15:00'),
(4, '药品储存方法', '2026-01-23 11:00:00', '2026-01-23 11:10:00'),
(5, '药品副作用咨询', '2026-01-24 16:00:00', '2026-01-24 16:25:00'),
(6, '儿童用药咨询', '2026-03-01 10:00:00', '2026-03-01 10:20:00'),
(7, '孕妇用药安全', '2026-03-02 14:00:00', '2026-03-02 14:30:00'),
(8, '慢性病用药', '2026-03-03 09:00:00', '2026-03-03 09:45:00'),
(9, '药品相互作用', '2026-03-04 11:00:00', '2026-03-04 11:15:00'),
(10, '中药使用咨询', '2026-03-05 16:00:00', '2026-03-05 16:25:00');

-- 插入AI消息记录数据
INSERT INTO `ai_message` (`conversation_id`, `role`, `content`, `created_at`) VALUES
(1, 'user', '阿莫西林和布洛芬可以一起吃吗', '2026-01-20 10:00:00'),
(1, 'assistant', '阿莫西林和布洛芬一般可以一起服用，但建议间隔30分钟以上。阿莫西林是抗生素，布洛芬是解热镇痛药，两者没有明显相互作用。', '2026-01-20 10:05:00'),
(1, 'user', '那饭前还是饭后吃比较好', '2026-01-20 10:10:00'),
(1, 'assistant', '阿莫西林建议饭后服用以减少胃部不适，布洛芬也建议饭后服用以避免刺激胃黏膜。', '2026-01-20 10:15:00'),
(2, 'user', '服用阿莫西林后出现皮疹怎么办', '2026-01-21 14:00:00'),
(2, 'assistant', '出现皮疹可能是过敏反应，建议立即停药并咨询医生。轻度过敏可服用抗组胺药，严重时需就医。', '2026-01-21 14:10:00'),
(2, 'user', '那可以换用头孢类吗', '2026-01-21 14:15:00'),
(2, 'assistant', '青霉素类和头孢类可能存在交叉过敏，使用前需告知医生过敏史。', '2026-01-21 14:20:00'),
(3, 'user', '高血压患者可以服用感冒药吗', '2026-01-22 09:00:00'),
(3, 'assistant', '高血压患者应避免服用含有麻黄碱、伪麻黄碱的感冒药，这些成分可能升高血压。建议选择不含这些成分的感冒药。', '2026-01-22 09:15:00'),
(4, 'user', '阿司匹林和他汀类可以一起吃吗', '2026-01-23 11:00:00'),
(4, 'assistant', '阿司匹林和他汀类药物可以一起服用，这是心血管疾病患者的常用联合用药方案。', '2026-01-23 11:05:00'),
(4, 'user', '需要间隔多久', '2026-01-23 11:10:00'),
(4, 'assistant', '一般不需要特别间隔，但为了减少胃部不适，建议两者都饭后服用。', '2026-01-23 11:15:00'),
(5, 'user', '复方氨酚烷胺和布洛芬可以一起吃吗', '2026-01-24 16:00:00'),
(5, 'assistant', '不建议同时服用，两者都含有解热镇痛成分，同时服用可能导致药物过量。', '2026-01-24 16:10:00'),
(5, 'user', '那应该选择哪个', '2026-01-24 16:15:00'),
(5, 'assistant', '如果症状较重，可以选择布洛芬；如果症状较轻，可以选择复方氨酚烷胺。', '2026-01-24 16:25:00'),
(6, 'user', '儿童可以服用阿莫西林吗', '2026-03-01 10:00:00'),
(6, 'assistant', '儿童可以服用阿莫西林，但需要根据体重计算剂量。一般剂量为每日20-40mg/kg，分3次服用。', '2026-03-01 10:05:00'),
(6, 'user', '那需要服用多久', '2026-03-01 10:10:00'),
(6, 'assistant', '通常疗程为7-10天，具体时间需要根据病情和医生建议确定。', '2026-03-01 10:20:00'),
(7, 'user', '孕妇可以服用布洛芬吗', '2026-03-02 14:00:00'),
(7, 'assistant', '孕妇在孕早期和孕晚期应避免服用布洛芬，孕中期也需谨慎使用。如需止痛，建议咨询医生。', '2026-03-02 14:15:00'),
(7, 'user', '那对乙酰氨基酚呢', '2026-03-02 14:20:00'),
(7, 'assistant', '对乙酰氨基酚是孕期相对安全的解热镇痛药，但仍需在医生指导下使用，避免长期大量服用。', '2026-03-02 14:30:00'),
(8, 'user', '高血压患者可以服用感冒药吗', '2026-03-03 09:00:00'),
(8, 'assistant', '高血压患者应避免服用含有麻黄碱、伪麻黄碱的感冒药，这些成分可能升高血压。建议选择不含这些成分的感冒药。', '2026-03-03 09:20:00'),
(8, 'user', '那可以服用复方氨酚烷胺吗', '2026-03-03 09:25:00'),
(8, 'assistant', '复方氨酚烷胺含有对乙酰氨基酚等成分，高血压患者应慎用，最好在医生指导下使用。', '2026-03-03 09:45:00'),
(9, 'user', '阿司匹林和他汀类可以一起吃吗', '2026-03-04 11:00:00'),
(9, 'assistant', '阿司匹林和他汀类药物可以一起服用，这是心血管疾病患者的常用联合用药方案。', '2026-03-04 11:05:00'),
(9, 'user', '需要间隔多久', '2026-03-04 11:10:00'),
(9, 'assistant', '一般不需要特别间隔，但为了减少胃部不适，建议两者都饭后服用。', '2026-03-04 11:15:00'),
(10, 'user', '中成药和西药可以一起吃吗', '2026-03-05 16:00:00'),
(10, 'assistant', '中成药和西药可以一起吃，但建议间隔30分钟以上，以减少药物相互作用的风险。', '2026-03-05 16:10:00'),
(10, 'user', '有哪些需要注意的', '2026-03-05 16:15:00'),
(10, 'assistant', '注意查看药品说明书中的禁忌和注意事项，避免重复用药。如有疑问，建议咨询医生或药师。', '2026-03-05 16:25:00');

-- 插入AI知识文档数据
INSERT INTO `ai_knowledge_doc` (`content`, `source`, `created_at`) VALUES
('阿莫西林胶囊是一种广谱抗生素，用于治疗细菌感染。常见副作用包括腹泻、恶心、皮疹等。', '药品说明书', '2026-01-20 08:00:00'),
('布洛芬缓释胶囊是一种非甾体抗炎药，用于缓解疼痛和发热。常见副作用包括胃部不适、恶心等。', '药品说明书', '2026-01-20 08:05:00'),
('对乙酰氨基酚片是一种解热镇痛药，用于缓解轻度至中度疼痛。过量服用可能导致肝损伤。', '药品说明书', '2026-01-20 08:10:00'),
('复方氨酚烷胺胶囊用于缓解感冒症状，包括发热、头痛、鼻塞等。避免与其他解热镇痛药同服。', '药品说明书', '2026-01-20 08:15:00'),
('咳特灵胶囊具有清热解毒、止咳化痰的功效，用于支气管炎、咽喉炎等。', '药品说明书', '2026-01-20 08:20:00'),
('维生素B1片用于预防和治疗维生素B1缺乏症，如脚气病、神经炎等。', '药品说明书', '2026-01-20 08:25:00'),
('葡萄糖酸钙口服液用于预防和治疗钙缺乏症，如骨质疏松、手足抽搐症等。', '药品说明书', '2026-01-20 08:30:00'),
('乳酸菌素片具有调理肠道菌群、促进消化的作用，用于消化不良、腹泻等。', '药品说明书', '2026-01-20 08:35:00'),
('健胃消食片具有健胃消食的功效，用于食欲不振、消化不良等。', '药品说明书', '2026-01-20 08:40:00'),
('黄连素片具有清热解毒、燥湿止痢的功效，用于细菌性痢疾、肠炎等。', '药品说明书', '2026-01-20 08:45:00'),
('三九感冒灵具有辛凉解表、清热解毒的功效，用于风热感冒引起的发热、头痛、咳嗽等。', '药品说明书', '2026-01-20 08:50:00'),
('蒲公英颗粒具有清热解毒、消肿散结的功效，用于热毒壅盛引起的疮疖、咽喉肿痛等。', '药品说明书', '2026-01-20 08:55:00'),
('板蓝根颗粒具有清热解毒、凉血利咽的功效，用于肺胃热盛所致的咽喉肿痛、痄腮等。', '药品说明书', '2026-01-20 09:00:00');

-- 插入AI工具调用审计日志数据
INSERT INTO `ai_tool_usage_log` (`tool_name`, `parameters`, `result`, `user_id`, `created_at`) VALUES
('search_drug', '{"drug_name": "阿莫西林"}', '{"code": 200, "data": {"name": "阿莫西林", "category": "抗生素"}}', 1, '2026-01-20 10:02:00'),
('check_interaction', '{"drug1": "阿莫西林", "drug2": "布洛芬"}', '{"code": 200, "data": {"interaction": "无明显相互作用"}}', 1, '2026-01-20 10:08:00'),
('search_drug', '{"drug_name": "布洛芬"}', '{"code": 200, "data": {"name": "布洛芬", "category": "解热镇痛"}}', 2, '2026-01-21 14:05:00'),
('check_contraindication', '{"drug_name": "布洛芬", "condition": "孕妇"}', '{"code": 200, "data": {"contraindication": "孕早期和孕晚期禁用"}}', 2, '2026-01-21 14:10:00'),
('search_drug', '{"drug_name": "对乙酰氨基酚"}', '{"code": 200, "data": {"name": "对乙酰氨基酚", "category": "解热镇痛"}}', 2, '2026-01-21 14:18:00'),
('search_drug', '{"drug_name": "阿司匹林"}', '{"code": 200, "data": {"name": "阿司匹林", "category": "解热镇痛"}}', 3, '2026-01-22 09:05:00'),
('search_drug', '{"drug_name": "阿托伐他汀"}', '{"code": 200, "data": {"name": "阿托伐他汀", "category": "降脂药"}}', 3, '2026-01-22 09:10:00'),
('check_interaction', '{"drug1": "阿司匹林", "drug2": "阿托伐他汀"}', '{"code": 200, "data": {"interaction": "可联合使用"}}', 3, '2026-01-22 09:15:00'),
('search_drug', '{"drug_name": "复方氨酚烷胺"}', '{"code": 200, "data": {"name": "复方氨酚烷胺", "category": "解热镇痛"}}', 4, '2026-01-23 11:02:00'),
('search_drug', '{"drug_name": "阿托伐他汀"}', '{"code": 200, "data": {"name": "阿托伐他汀", "category": "降脂药"}}', 4, '2026-01-23 11:08:00'),
('check_interaction', '{"drug1": "复方氨酚烷胺", "drug2": "阿托伐他汀"}', '{"code": 200, "data": {"interaction": "无明显相互作用"}}', 4, '2026-01-23 11:12:00'),
('search_drug', '{"drug_name": "板蓝根颗粒"}', '{"code": 200, "data": {"name": "板蓝根颗粒", "category": "清热解毒"}}', 5, '2026-01-24 16:05:00'),
('search_drug', '{"drug_name": "蒲公英颗粒"}', '{"code": 200, "data": {"name": "蒲公英颗粒", "category": "清热解毒"}}', 5, '2026-01-24 16:08:00'),
('search_drug', '{"drug_name": "复方氨酚烷胺"}', '{"code": 200, "data": {"name": "复方氨酚烷胺", "category": "解热镇痛"}}', 6, '2026-03-01 10:02:00'),
('check_interaction', '{"drug1": "复方氨酚烷胺", "drug2": "布洛芬"}', '{"code": 200, "data": {"interaction": "不建议同时服用"}}', 6, '2026-03-01 10:08:00'),
('search_drug', '{"drug_name": "布洛芬"}', '{"code": 200, "data": {"name": "布洛芬", "category": "解热镇痛"}}', 7, '2026-03-02 14:05:00'),
('check_contraindication', '{"drug_name": "布洛芬", "condition": "孕妇"}', '{"code": 200, "data": {"contraindication": "孕早期和孕晚期禁用"}}', 7, '2026-03-02 14:10:00'),
('search_drug', '{"drug_name": "对乙酰氨基酚"}', '{"code": 200, "data": {"name": "对乙酰氨基酚", "category": "解热镇痛"}}', 7, '2026-03-02 14:18:00'),
('search_drug', '{"drug_name": "阿司匹林"}', '{"code": 200, "data": {"name": "阿司匹林", "category": "解热镇痛"}}', 8, '2026-03-03 09:05:00'),
('search_drug', '{"drug_name": "阿托伐他汀"}', '{"code": 200, "data": {"name": "阿托伐他汀", "category": "降脂药"}}', 8, '2026-03-03 09:10:00'),
('check_interaction', '{"drug1": "阿司匹林", "drug2": "阿托伐他汀"}', '{"code": 200, "data": {"interaction": "可联合使用"}}', 8, '2026-03-03 09:15:00'),
('search_drug', '{"drug_name": "复方氨酚烷胺"}', '{"code": 200, "data": {"name": "复方氨酚烷胺", "category": "解热镇痛"}}', 8, '2026-03-03 09:22:00'),
('search_drug', '{"drug_name": "板蓝根颗粒"}', '{"code": 200, "data": {"name": "板蓝根颗粒", "category": "清热解毒"}}', 10, '2026-03-05 16:05:00'),
('search_drug', '{"drug_name": "蒲公英颗粒"}', '{"code": 200, "data": {"name": "蒲公英颗粒", "category": "清热解毒"}}', 10, '2026-03-05 16:08:00');