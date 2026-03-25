-- 鍒涘缓鏁版嵁搴?CREATE DATABASE IF NOT EXISTS drug_traceability CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE drug_traceability;

-- 鐢ㄦ埛琛?CREATE TABLE IF NOT EXISTS `user` (
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

-- 瑙掕壊琛?CREATE TABLE IF NOT EXISTS `role` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 鑽搧淇℃伅琛?CREATE TABLE IF NOT EXISTS `drug_info` (
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

-- 鐢熶骇鎵规琛?CREATE TABLE IF NOT EXISTS `production_batch` (
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

-- 閲囪喘璁板綍琛?CREATE TABLE IF NOT EXISTS `procurement_record` (
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

-- 閿€鍞褰曡〃
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

-- 搴撳瓨琛?CREATE TABLE IF NOT EXISTS `inventory` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `batch_id` BIGINT(20) NOT NULL,
  `organization_id` BIGINT(20) NOT NULL,
  `quantity` INT(11) NOT NULL,
  `last_update_date` DATE NOT NULL,
  `status` INT(11) NOT NULL DEFAULT 1,
  `version` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_batch_org` (`batch_id`, `organization_id`),
  KEY `idx_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI浼氳瘽璁板綍琛?CREATE TABLE IF NOT EXISTS `ai_conversation` (
  `conversation_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT(20) NOT NULL,
  `title` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI娑堟伅璁板綍琛?CREATE TABLE IF NOT EXISTS `ai_message` (
  `message_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `conversation_id` BIGINT(20) NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `content` TEXT NOT NULL,
  `tool_calls` JSON,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_conversation_id` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI鐭ヨ瘑鏂囨。鍚戦噺琛?CREATE TABLE IF NOT EXISTS `ai_knowledge_doc` (
  `doc_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `content` TEXT NOT NULL,
  `embedding_vector` BLOB,
  `source` VARCHAR(200),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`doc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI宸ュ叿璋冪敤瀹¤琛?CREATE TABLE IF NOT EXISTS `ai_tool_usage_log` (
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

-- 涓嶈壇鍙嶅簲璁板綍琛?CREATE TABLE IF NOT EXISTS `adverse_reaction` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `drug_id` BIGINT(20) NOT NULL,
  `patient_name` VARCHAR(50) NOT NULL,
  `reaction_description` TEXT NOT NULL,
  `severity` VARCHAR(20) NOT NULL,
  `hospital` VARCHAR(100),
  `doctor_name` VARCHAR(50),
  `reporter_id` BIGINT(20) NOT NULL,
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_drug_id` (`drug_id`),
  KEY `idx_reporter_id` (`reporter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 鐢ㄨ嵂璁板綍琛?CREATE TABLE IF NOT EXISTS `usage_record` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `drug_id` BIGINT(20) NOT NULL,
  `patient_name` VARCHAR(50) NOT NULL,
  `dosage` VARCHAR(50) NOT NULL,
  `frequency` VARCHAR(50) NOT NULL,
  `usage_date` DATE NOT NULL,
  `doctor_id` BIGINT(20),
  `hospital` VARCHAR(100),
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_drug_id` (`drug_id`),
  KEY `idx_doctor_id` (`doctor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 杩芥函璁板綍琛?CREATE TABLE IF NOT EXISTS `trace_record` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `drug_code` VARCHAR(50) NOT NULL,
  `batch_number` VARCHAR(50) NOT NULL,
  `trace_step` VARCHAR(50) NOT NULL,
  `step_time` TIMESTAMP NOT NULL,
  `organization` VARCHAR(100),
  `description` VARCHAR(200),
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_drug_code` (`drug_code`),
  KEY `idx_batch_number` (`batch_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 鎻掑叆鍒濆瑙掕壊鏁版嵁
INSERT INTO `role` (`name`, `code`, `description`) VALUES
('瓒呯骇绠＄悊鍛?, 'super_admin', '绯荤粺鏈€楂樻潈闄?),
('鐩戠浜哄憳', 'regulator', '鑽搧鐩戠浜哄憳'),
('鐢熶骇浼佷笟', 'producer', '鑽搧鐢熶骇浼佷笟'),
('缁忚惀浼佷笟', 'distributor', '鑽搧缁忚惀浼佷笟'),
('鍖荤枟鏈烘瀯', 'hospital', '鍖荤枟鏈烘瀯'),
('鍏紬', 'public', '鏅€氬叕浼?);

-- 鎻掑叆鍒濆鐢ㄦ埛鏁版嵁
INSERT INTO `user` (`username`, `password`, `name`, `role_id`, `organization`, `phone`, `email`, `status`) VALUES
('admin', '123456', '瓒呯骇绠＄悊鍛?, 1, '绯荤粺绠＄悊', '13800138000', 'admin@example.com', 1),
('regulator', '123456', '鐩戠浜哄憳', 2, '鑽洃灞€', '13800138001', 'regulator@example.com', 1),
('producer', '123456', '鐢熶骇浼佷笟', 3, '鍒惰嵂鍏徃', '13800138002', 'producer@example.com', 1),
('distributor', '123456', '缁忚惀浼佷笟', 4, '鍖昏嵂鍏徃', '13800138003', 'distributor@example.com', 1),
('hospital', '123456', '鍖荤枟鏈烘瀯', 5, '鍖婚櫌', '13800138004', 'hospital@example.com', 1),
('public', '123456', '鍏紬', 6, '涓汉', '13800138005', 'public@example.com', 1);

-- 鎻掑叆鍒濆鑽搧鏁版嵁
INSERT INTO `drug_info` (`drug_code`, `name`, `specification`, `manufacturer`, `approval_number`, `category`, `unit`, `price`, `status`) VALUES
('D001', '闃胯帿瑗挎灄鑳跺泭', '0.25g*24绮?, '鍗庡寳鍒惰嵂', '鍥借嵂鍑嗗瓧H13023371', '鎶楃敓绱?, '鐩?, 25.50, 1),
('D002', '甯冩礇鑺紦閲婅兌鍥?, '0.3g*10绮?, '涓編鍙插厠', '鍥借嵂鍑嗗瓧H10900089', '瑙ｇ儹闀囩棝', '鐩?, 32.80, 1),
('D003', '瀵逛箼閰版皑鍩洪厷鐗?, '0.5g*24鐗?, '涓婃捣寮虹敓', '鍥借嵂鍑嗗瓧H31020539', '瑙ｇ儹闀囩棝', '鐩?, 18.50, 1),
('D004', '纭濊嫰鍦板钩鐗?, '10mg*20鐗?, '鎷滆€冲埗鑽?, '鍥借嵂鍑嗗瓧H10930007', '蹇冭绠?, '鐩?, 45.20, 1),
('D005', '濂ョ編鎷夊攽鑲犳憾鑳跺泭', '20mg*14绮?, '闃挎柉鍒╁悍', '鍥借嵂鍑嗗瓧H10960297', '娑堝寲绯荤粺', '鐩?, 68.50, 1),
('D006', '浜岀敳鍙岃儘鐗?, '0.5g*30鐗?, '榛樺厠鍒惰嵂', '鍥借嵂鍑嗗瓧H20023367', '鍐呭垎娉?, '鐩?, 35.80, 1),
('D007', '娌欑編鐗圭綏鏇垮崱鏉惧惛鍏ュ墏', '50渭g/500渭g*60鍚?, '钁涘叞绱犲彶鍏?, '鍥借嵂鍑嗗瓧H20050917', '鍛煎惛绯荤粺', '鐩?, 180.00, 1),
('D008', '闃垮徃鍖规灄鑲犳憾鐗?, '100mg*30鐗?, '鎷滆€冲埗鑽?, '鍥借嵂鍑嗗瓧H11020001', '瑙ｇ儹闀囩棝', '鐩?, 15.60, 1),
('D009', '缁寸敓绱燙鐗?, '100mg*100鐗?, '鎷滆€冲埗鑽?, '鍥借嵂鍑嗗瓧H42021837', '缁寸敓绱?, '鐡?, 22.80, 1),
('D010', '鎰熷啋娓呯儹棰楃矑', '12g*10琚?, '鍖椾含鍚屼粊鍫?, '鍥借嵂鍑嗗瓧Z11020617', '瑙ｈ〃鍓?, '鐩?, 28.50, 1);

-- 鎻掑叆鍒濆鐢熶骇鎵规鏁版嵁
INSERT INTO `production_batch` (`batch_number`, `drug_id`, `production_date`, `expiry_date`, `production_quantity`, `producer_id`, `status`) VALUES
('B001', 1, '2026-01-01', '2028-01-01', 10000, 3, 1),
('B002', 2, '2026-01-02', '2028-01-02', 8000, 3, 1),
('B003', 3, '2026-01-03', '2028-01-03', 12000, 3, 1),
('B004', 4, '2026-01-04', '2028-01-04', 6000, 3, 1),
('B005', 5, '2026-01-05', '2028-01-05', 5000, 3, 1),
('B006', 6, '2026-01-06', '2028-01-06', 8000, 3, 1),
('B007', 7, '2026-01-07', '2028-01-07', 3000, 3, 1),
('B008', 8, '2026-01-08', '2028-01-08', 15000, 3, 1),
('B009', 9, '2026-01-09', '2028-01-09', 20000, 3, 1),
('B010', 10, '2026-01-10', '2028-01-10', 10000, 3, 1);

-- 鎻掑叆鍒濆搴撳瓨鏁版嵁
INSERT INTO `inventory` (`batch_id`, `organization_id`, `quantity`, `last_update_date`, `status`) VALUES
(1, 3, 5000, '2026-01-01', 1),
(2, 3, 4000, '2026-01-02', 1),
(3, 3, 6000, '2026-01-03', 1),
(4, 3, 3000, '2026-01-04', 1),
(5, 3, 2500, '2026-01-05', 1),
(6, 3, 4000, '2026-01-06', 1),
(7, 3, 1500, '2026-01-07', 1),
(8, 3, 7500, '2026-01-08', 1),
(9, 3, 10000, '2026-01-09', 1),
(10, 3, 5000, '2026-01-10', 1);

-- 鎻掑叆閲囪喘璁板綍鏁版嵁
INSERT INTO `procurement_record` (`batch_id`, `buyer_id`, `supplier_id`, `quantity`, `purchase_date`, `purchase_price`, `status`) VALUES
(1, 4, 3, 1000, '2026-01-15', 20.00, 1),
(2, 4, 3, 800, '2026-01-16', 28.00, 1),
(3, 5, 3, 1200, '2026-01-17', 15.00, 1),
(4, 4, 3, 600, '2026-01-18', 40.00, 1),
(5, 5, 3, 500, '2026-01-19', 60.00, 1);

-- 鎻掑叆閿€鍞褰曟暟鎹?INSERT INTO `sale_record` (`batch_id`, `seller_id`, `buyer_id`, `quantity`, `sale_date`, `sale_price`, `status`) VALUES
(1, 4, 5, 200, '2026-01-20', 25.50, 1),
(2, 4, 5, 150, '2026-01-21', 32.80, 1),
(3, 5, 6, 300, '2026-01-22', 18.50, 1),
(4, 4, 5, 100, '2026-01-23', 45.20, 1),
(5, 5, 6, 200, '2026-01-24', 68.50, 1);

-- 鎻掑叆涓嶈壇鍙嶅簲璁板綍鏁版嵁
INSERT INTO `adverse_reaction` (`drug_id`, `patient_name`, `reaction_description`, `severity`, `hospital`, `doctor_name`, `reporter_id`, `status`, `created_at`) VALUES
(1, '寮犱笁', '鏈嶇敤鍚庡嚭鐜扮毊鐤广€佺槞鐥掔棁鐘?, '杞诲害', '绗竴浜烘皯鍖婚櫌', '鏉庡尰鐢?, 5, 1, '2026-01-25 10:30:00'),
(2, '鏉庡洓', '鏈嶇敤鍚庡嚭鐜拌儍閮ㄤ笉閫傘€佹伓蹇?, '涓害', '绗簩浜烘皯鍖婚櫌', '鐜嬪尰鐢?, 5, 1, '2026-01-26 14:20:00'),
(3, '鐜嬩簲', '鏈嶇敤鍚庡嚭鐜板ご鏅曘€佷箯鍔?, '杞诲害', '绗笁浜烘皯鍖婚櫌', '璧靛尰鐢?, 5, 1, '2026-01-27 09:15:00');

-- 鎻掑叆鐢ㄨ嵂璁板綍鏁版嵁
INSERT INTO `usage_record` (`drug_id`, `patient_name`, `dosage`, `frequency`, `usage_date`, `doctor_id`, `hospital`, `status`) VALUES
(1, '寮犱笁', '0.5g', '姣忔棩3娆?, '2026-01-20', 5, '绗竴浜烘皯鍖婚櫌', 1),
(2, '鏉庡洓', '0.3g', '姣忔棩2娆?, '2026-01-21', 5, '绗簩浜烘皯鍖婚櫌', 1),
(3, '鐜嬩簲', '0.5g', '姣忔棩2娆?, '2026-01-22', 5, '绗笁浜烘皯鍖婚櫌', 1),
(4, '璧靛叚', '10mg', '姣忔棩1娆?, '2026-01-23', 5, '绗竴浜烘皯鍖婚櫌', 1),
(5, '閽变竷', '20mg', '姣忔棩1娆?, '2026-01-24', 5, '绗簩浜烘皯鍖婚櫌', 1),
(6, '瀛欏叓', '0.5g', '姣忔棩2娆?, '2026-01-25', 5, '绗笁浜烘皯鍖婚櫌', 1),
(7, '鍛ㄤ節', '2鍚?, '姣忔棩2娆?, '2026-01-26', 5, '绗竴浜烘皯鍖婚櫌', 1),
(8, '鍚村崄', '0.1g', '姣忔棩3娆?, '2026-01-27', 5, '绗簩浜烘皯鍖婚櫌', 1),
(9, '閮戝崄涓€', '1鐗?, '姣忔棩3娆?, '2026-01-28', 5, '绗笁浜烘皯鍖婚櫌', 1),
(10, '鐜嬪崄浜?, '1琚?, '姣忔棩2娆?, '2026-01-29', 5, '绗竴浜烘皯鍖婚櫌', 1);

-- 鎻掑叆杩芥函璁板綍鏁版嵁
INSERT INTO `trace_record` (`drug_code`, `batch_number`, `trace_step`, `step_time`, `organization`, `description`, `status`) VALUES
('D001', 'B001', '鍘熸枡閲囪喘', '2026-01-01 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D001', 'B001', '鐢熶骇鍔犲伐', '2026-01-02 10:30:00', '鍗庡寳鍒惰嵂鍘?, '鐢熶骇鍔犲伐瀹屾垚', 1),
('D001', 'B001', '璐ㄩ噺妫€楠?, '2026-01-03 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D001', 'B001', '鍖呰鍏ュ簱', '2026-01-04 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D001', 'B001', '鐗╂祦閰嶉€?, '2026-01-05 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D001', 'B001', '鑽簵閿€鍞?, '2026-01-20 15:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D002', 'B002', '鍘熸枡閲囪喘', '2026-01-02 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D002', 'B002', '鐢熶骇鍔犲伐', '2026-01-03 10:30:00', '涓編鍙插厠鍘?, '鐢熶骇鍔犲伐瀹屾垚', 1),
('D002', 'B002', '璐ㄩ噺妫€楠?, '2026-01-04 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D002', 'B002', '鍖呰鍏ュ簱', '2026-01-05 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D002', 'B002', '鐗╂祦閰嶉€?, '2026-01-06 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D002', 'B002', '鑽簵閿€鍞?, '2026-01-21 10:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D003', 'B003', '鍘熸枡閲囪喘', '2026-01-03 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D003', 'B003', '鐢熶骇鍔犲伐', '2026-01-04 10:30:00', '涓婃捣寮虹敓鍘?, '鐢熶骇鍔犲伐瀹屾垚', 1),
('D003', 'B003', '璐ㄩ噺妫€楠?, '2026-01-05 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D003', 'B003', '鍖呰鍏ュ簱', '2026-01-06 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D003', 'B003', '鐗╂祦閰嶉€?, '2026-01-07 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D003', 'B003', '鑽簵閿€鍞?, '2026-01-22 11:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D004', 'B004', '鍘熸枡閲囪喘', '2026-01-04 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D004', 'B004', '鐢熶骇鍔犲伐', '2026-01-05 10:30:00', '鎷滆€冲埗鑽巶', '鐢熶骇鍔犲伐瀹屾垚', 1),
('D004', 'B004', '璐ㄩ噺妫€楠?, '2026-01-06 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D004', 'B004', '鍖呰鍏ュ簱', '2026-01-07 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D004', 'B004', '鐗╂祦閰嶉€?, '2026-01-08 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D004', 'B004', '鑽簵閿€鍞?, '2026-01-23 12:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D005', 'B005', '鍘熸枡閲囪喘', '2026-01-05 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D005', 'B005', '鐢熶骇鍔犲伐', '2026-01-06 10:30:00', '闃挎柉鍒╁悍鍘?, '鐢熶骇鍔犲伐瀹屾垚', 1),
('D005', 'B005', '璐ㄩ噺妫€楠?, '2026-01-07 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D005', 'B005', '鍖呰鍏ュ簱', '2026-01-08 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D005', 'B005', '鐗╂祦閰嶉€?, '2026-01-09 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D005', 'B005', '鑽簵閿€鍞?, '2026-01-24 13:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1);

-- 鎻掑叆鏇村涓嶈壇鍙嶅簲璁板綍
INSERT INTO `adverse_reaction` (`drug_id`, `patient_name`, `reaction_description`, `severity`, `hospital`, `doctor_name`, `reporter_id`, `status`, `created_at`) VALUES
(4, '鍒樺尰鐢?, '鏈嶇敤鍚庡嚭鐜板績鎮搞€佸ご鐥?, '涓害', '绗竴浜烘皯鍖婚櫌', '寮犲尰鐢?, 5, 1, '2026-01-28 10:00:00'),
(5, '闄堝尰鐢?, '鏈嶇敤鍚庡嚭鐜拌儍閮ㄧ伡鐑劅', '杞诲害', '绗簩浜烘皯鍖婚櫌', '鏉庡尰鐢?, 5, 1, '2026-01-29 11:00:00'),
(6, '鏉ㄥ尰鐢?, '鏈嶇敤鍚庡嚭鐜拌交搴﹁吂娉?, '杞诲害', '绗笁浜烘皯鍖婚櫌', '鐜嬪尰鐢?, 5, 1, '2026-01-30 12:00:00'),
(7, '榛勫尰鐢?, '鍚稿叆鍚庡嚭鐜板彛骞?, '杞诲害', '绗竴浜烘皯鍖婚櫌', '璧靛尰鐢?, 5, 1, '2026-01-31 13:00:00'),
(8, '鏈卞尰鐢?, '鏈嶇敤鍚庡嚭鐜拌交寰毊鐤?, '杞诲害', '绗簩浜烘皯鍖婚櫌', '閽卞尰鐢?, 5, 1, '2026-02-01 14:00:00'),
(9, '浣曞尰鐢?, '鏈嶇敤鍚庡嚭鐜拌交寰伓蹇?, '杞诲害', '绗笁浜烘皯鍖婚櫌', '瀛欏尰鐢?, 5, 1, '2026-02-02 15:00:00'),
(10, '鏋楀尰鐢?, '鏈嶇敤鍚庡嚭鐜拌交寰彛娓?, '杞诲害', '绗竴浜烘皯鍖婚櫌', '鍛ㄥ尰鐢?, 5, 1, '2026-02-03 16:00:00');

-- 鎻掑叆鏇村閲囪喘璁板綍
INSERT INTO `procurement_record` (`batch_id`, `buyer_id`, `supplier_id`, `quantity`, `purchase_date`, `purchase_price`, `status`) VALUES
(6, 4, 3, 800, '2026-01-20', 30.00, 1),
(7, 4, 3, 500, '2026-01-21', 150.00, 1),
(8, 4, 3, 1200, '2026-01-22', 12.00, 1),
(9, 4, 3, 1500, '2026-01-23', 18.00, 1),
(10, 4, 3, 1000, '2026-01-24', 22.00, 1),
(1, 5, 4, 500, '2026-01-25', 22.00, 1),
(2, 5, 4, 400, '2026-01-26', 30.00, 1),
(3, 5, 4, 600, '2026-01-27', 16.00, 1),
(4, 5, 4, 300, '2026-01-28', 42.00, 1),
(5, 5, 4, 250, '2026-01-29', 65.00, 1);

-- 鎻掑叆鏇村閿€鍞褰?INSERT INTO `sale_record` (`batch_id`, `seller_id`, `buyer_id`, `quantity`, `sale_date`, `sale_price`, `status`) VALUES
(6, 4, 5, 400, '2026-01-30', 35.80, 1),
(7, 4, 5, 250, '2026-01-31', 180.00, 1),
(8, 4, 5, 600, '2026-02-01', 15.60, 1),
(9, 4, 5, 750, '2026-02-02', 22.80, 1),
(10, 4, 5, 500, '2026-02-03', 28.50, 1),
(1, 5, 6, 100, '2026-02-04', 25.50, 1),
(2, 5, 6, 80, '2026-02-05', 32.80, 1),
(3, 5, 6, 150, '2026-02-06', 18.50, 1),
(4, 5, 6, 50, '2026-02-07', 45.20, 1),
(5, 5, 6, 100, '2026-02-08', 68.50, 1);

-- 鎻掑叆鏇村搴撳瓨鏁版嵁
INSERT INTO `inventory` (`batch_id`, `organization_id`, `quantity`, `last_update_date`, `status`) VALUES
(6, 4, 2000, '2026-01-20', 1),
(7, 4, 1000, '2026-01-21', 1),
(8, 4, 3500, '2026-01-22', 1),
(9, 4, 5000, '2026-01-23', 1),
(10, 4, 2500, '2026-01-24', 1),
(1, 5, 4800, '2026-01-25', 1),
(2, 5, 3520, '2026-01-26', 1),
(3, 5, 5400, '2026-01-27', 1),
(4, 5, 2700, '2026-01-28', 1),
(5, 5, 2250, '2026-01-29', 1),
(6, 5, 1600, '2026-01-30', 1),
(7, 5, 750, '2026-01-31', 1),
(8, 5, 2900, '2026-02-01', 1),
(9, 5, 4250, '2026-02-02', 1),
(10, 5, 2000, '2026-02-03', 1);

-- 鎻掑叆鏇村杩芥函璁板綍
INSERT INTO `trace_record` (`drug_code`, `batch_number`, `trace_step`, `step_time`, `organization`, `description`, `status`) VALUES
('D006', 'B006', '鍘熸枡閲囪喘', '2026-01-06 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D006', 'B006', '鐢熶骇鍔犲伐', '2026-01-07 10:30:00', '榛樺厠鍒惰嵂鍘?, '鐢熶骇鍔犲伐瀹屾垚', 1),
('D006', 'B006', '璐ㄩ噺妫€楠?, '2026-01-08 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D006', 'B006', '鍖呰鍏ュ簱', '2026-01-09 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D006', 'B006', '鐗╂祦閰嶉€?, '2026-01-10 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D006', 'B006', '鑽簵閿€鍞?, '2026-01-25 14:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D007', 'B007', '鍘熸枡閲囪喘', '2026-01-07 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D007', 'B007', '鐢熶骇鍔犲伐', '2026-01-08 10:30:00', '钁涘叞绱犲彶鍏嬪巶', '鐢熶骇鍔犲伐瀹屾垚', 1),
('D007', 'B007', '璐ㄩ噺妫€楠?, '2026-01-09 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D007', 'B007', '鍖呰鍏ュ簱', '2026-01-10 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D007', 'B007', '鐗╂祦閰嶉€?, '2026-01-11 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D007', 'B007', '鑽簵閿€鍞?, '2026-01-26 15:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D008', 'B008', '鍘熸枡閲囪喘', '2026-01-08 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D008', 'B008', '鐢熶骇鍔犲伐', '2026-01-09 10:30:00', '鎷滆€冲埗鑽巶', '鐢熶骇鍔犲伐瀹屾垚', 1),
('D008', 'B008', '璐ㄩ噺妫€楠?, '2026-01-10 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D008', 'B008', '鍖呰鍏ュ簱', '2026-01-11 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D008', 'B008', '鐗╂祦閰嶉€?, '2026-01-12 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D008', 'B008', '鑽簵閿€鍞?, '2026-01-27 16:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D009', 'B009', '鍘熸枡閲囪喘', '2026-01-09 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D009', 'B009', '鐢熶骇鍔犲伐', '2026-01-10 10:30:00', '鎷滆€冲埗鑽巶', '鐢熶骇鍔犲伐瀹屾垚', 1),
('D009', 'B009', '璐ㄩ噺妫€楠?, '2026-01-11 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D009', 'B009', '鍖呰鍏ュ簱', '2026-01-12 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D009', 'B009', '鐗╂祦閰嶉€?, '2026-01-13 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D009', 'B009', '鑽簵閿€鍞?, '2026-01-28 17:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1),
('D010', 'B010', '鍘熸枡閲囪喘', '2026-01-10 08:00:00', '鍘熸枡渚涘簲鍟?, '鍘熸枡閲囪喘瀹屾垚', 1),
('D010', 'B010', '鐢熶骇鍔犲伐', '2026-01-11 10:30:00', '鍖椾含鍚屼粊鍫傚巶', '鐢熶骇鍔犲伐瀹屾垚', 1),
('D010', 'B010', '璐ㄩ噺妫€楠?, '2026-01-12 14:00:00', '璐ㄦ閮ㄩ棬', '璐ㄩ噺妫€楠屽悎鏍?, 1),
('D010', 'B010', '鍖呰鍏ュ簱', '2026-01-13 16:00:00', '浠撳偍閮?, '鍖呰鍏ュ簱瀹屾垚', 1),
('D010', 'B010', '鐗╂祦閰嶉€?, '2026-01-14 09:00:00', '鐗╂祦鍏徃', '鍙戣揣鑷冲尰鑽叕鍙?, 1),
('D010', 'B010', '鑽簵閿€鍞?, '2026-01-29 18:00:00', '搴峰仴澶ц嵂鎴?, '閿€鍞粰鎮ｈ€?, 1);

-- 鎻掑叆AI浼氳瘽璁板綍鏁版嵁
INSERT INTO `ai_conversation` (`user_id`, `title`, `created_at`, `updated_at`) VALUES
(1, '鑽搧鐩镐簰浣滅敤鍜ㄨ', '2026-01-20 10:00:00', '2026-01-20 10:30:00'),
(2, '涓嶈壇鍙嶅簲澶勭悊寤鸿', '2026-01-21 14:00:00', '2026-01-21 14:20:00'),
(3, '鐢ㄨ嵂鍓傞噺璋冩暣', '2026-01-22 09:00:00', '2026-01-22 09:15:00'),
(4, '鑽搧鍌ㄥ瓨鏂规硶', '2026-01-23 11:00:00', '2026-01-23 11:10:00'),
(5, '鑽搧鍓綔鐢ㄥ挩璇?, '2026-01-24 16:00:00', '2026-01-24 16:25:00');

-- 鎻掑叆AI娑堟伅璁板綍鏁版嵁
INSERT INTO `ai_message` (`conversation_id`, `role`, `content`, `created_at`) VALUES
(1, 'user', '闃胯帿瑗挎灄鍜屽竷娲涜姮鍙互涓€璧峰悆鍚?, '2026-01-20 10:00:00'),
(1, 'assistant', '闃胯帿瑗挎灄鍜屽竷娲涜姮涓€鑸彲浠ヤ竴璧锋湇鐢紝浣嗗缓璁棿闅?0鍒嗛挓浠ヤ笂銆傞樋鑾タ鏋楁槸鎶楃敓绱狅紝甯冩礇鑺槸瑙ｇ儹闀囩棝鑽紝涓よ€呮病鏈夋槑鏄剧浉浜掍綔鐢ㄣ€?, '2026-01-20 10:05:00'),
(1, 'user', '閭ｉキ鍓嶈繕鏄キ鍚庡悆姣旇緝濂?, '2026-01-20 10:10:00'),
(1, 'assistant', '闃胯帿瑗挎灄寤鸿楗悗鏈嶇敤浠ュ噺灏戣儍閮ㄤ笉閫傦紝甯冩礇鑺篃寤鸿楗悗鏈嶇敤浠ラ伩鍏嶅埡婵€鑳冮粡鑶溿€?, '2026-01-20 10:15:00'),
(2, 'user', '鏈嶇敤闃垮徃鍖规灄鍚庡嚭鐜扮毊鐤规€庝箞鍔?, '2026-01-21 14:00:00'),
(2, 'assistant', '鍑虹幇鐨柟鍙兘鏄繃鏁忓弽搴旓紝寤鸿绔嬪嵆鍋滆嵂骞跺氨鍖汇€傚鏋滅棁鐘朵弗閲嶏紝濡傚懠鍚稿洶闅炬垨闈㈤儴鑲胯儉锛屽簲绔嬪嵆鎷ㄦ墦鎬ユ晳鐢佃瘽銆?, '2026-01-21 14:10:00'),
(2, 'user', '璋㈣阿鍖荤敓', '2026-01-21 14:15:00'),
(2, 'assistant', '涓嶅姘旓紝绁濇偍鏃╂棩搴峰锛?, '2026-01-21 14:20:00'),
(3, 'user', '鑰佸勾浜虹敤鑽墏閲忛渶瑕佽皟鏁村悧', '2026-01-22 09:00:00'),
(3, 'assistant', '鑰佸勾浜虹敱浜庤倽鑲惧姛鑳藉彲鑳戒笅闄嶏紝閫氬父闇€瑕佽皟鏁寸敤鑽墏閲忋€傚缓璁挩璇㈠尰鐢熸垨鑽笀锛屾牴鎹叿浣撴儏鍐佃繘琛屼釜浣撳寲鐢ㄨ嵂銆?, '2026-01-22 09:10:00'),
(3, 'user', '鏄庣櫧浜嗭紝璋㈣阿', '2026-01-22 09:15:00'),
(4, 'user', '鑽搧搴旇濡備綍鍌ㄥ瓨', '2026-01-23 11:00:00'),
(4, 'assistant', '鑽搧搴斿瓨鏀惧湪闃村噳骞茬嚗澶勶紝閬垮厤闃冲厜鐩村皠銆傚ぇ澶氭暟鑽搧鍌ㄥ瓨娓╁害涓嶈秴杩?5鈩冿紝閮ㄥ垎鑽搧闇€瑕佸喎钘忥紙2-8鈩冿級銆傝浠旂粏闃呰鑽搧璇存槑涔︺€?, '2026-01-23 11:05:00'),
(4, 'user', '鍙ｆ湇娑查渶瑕佸喎钘忓悧', '2026-01-23 11:08:00'),
(4, 'assistant', '涓€鑸彛鏈嶆恫涓嶉渶瑕佸喎钘忥紝浣嗗瀛ｉ珮娓╂椂鍙斁鍏ュ啺绠卞喎钘忥紝浣跨敤鍓嶆仮澶嶈嚦瀹ゆ俯鍗冲彲銆傚叿浣撹鍙傝€冭嵂鍝佽鏄庝功銆?, '2026-01-23 11:10:00'),
(5, 'user', '鏈嶇敤闄嶅帇鑽悗澶存檿鎬庝箞鍔?, '2026-01-24 16:00:00'),
(5, 'assistant', '澶存檿鍙兘鏄檷鍘嬭嵂鐨勫壇浣滅敤锛屽缓璁厛娴嬮噺琛€鍘嬨€傚鏋滆鍘嬭繃浣庢垨澶存檿涓ラ噸锛屽簲鍙婃椂灏卞尰銆備笉瑕佽嚜琛屽仠鑽垨璋冩暣鍓傞噺銆?, '2026-01-24 16:15:00'),
(5, 'user', '濂界殑锛屾垜浼氭敞鎰忕殑', '2026-01-24 16:20:00'),
(5, 'assistant', '绁濇偍鍋ュ悍锛佸鏈夊叾浠栭棶棰橀殢鏃跺挩璇€?, '2026-01-24 16:25:00');

-- 鎻掑叆AI鐭ヨ瘑鏂囨。鏁版嵁
INSERT INTO `ai_knowledge_doc` (`content`, `source`, `created_at`) VALUES
('闃胯帿瑗挎灄鏄竴绉嶅箍璋辨姉鐢熺礌锛屽睘浜庨潚闇夌礌绫伙紝鐢ㄤ簬娌荤枟鏁忔劅鑿屽紩璧风殑鎰熸煋锛屽鍛煎惛閬撴劅鏌撱€佹硨灏块亾鎰熸煋绛夈€傚父瑙佸壇浣滅敤鍖呮嫭鐨柟銆佽吂娉汇€佹伓蹇冪瓑銆?, '鑽搧璇存槑涔?, '2026-01-20 08:00:00'),
('甯冩礇鑺槸闈炵斁浣撴姉鐐庤嵂锛屽叿鏈夎В鐑€侀晣鐥涖€佹姉鐐庝綔鐢紝鐢ㄤ簬缂撹В鐤肩棝銆佸彂鐑拰鐐庣棁銆傚父瑙佸壇浣滅敤鍖呮嫭鑳冮儴涓嶉€傘€佹伓蹇冦€佸ご鏅曠瓑銆?, '鑽搧璇存槑涔?, '2026-01-20 08:05:00'),
('瀵逛箼閰版皑鍩洪厷鏄В鐑晣鐥涜嵂锛岀敤浜庣紦瑙ｈ交搴﹁嚦涓害鐤肩棝鍜屽彂鐑€傝倽鍔熻兘涓嶅叏鑰呮厧鐢紝閬垮厤闀挎湡澶ч噺浣跨敤銆?, '鑽搧璇存槑涔?, '2026-01-20 08:10:00'),
('纭濊嫰鍦板钩鏄挋閫氶亾闃绘粸鍓傦紝鐢ㄤ簬娌荤枟楂樿鍘嬪拰蹇冪粸鐥涖€傚父瑙佸壇浣滅敤鍖呮嫭澶寸棝銆侀潰閮ㄦ疆绾€佸績鎮哥瓑銆?, '鑽搧璇存槑涔?, '2026-01-20 08:15:00'),
('濂ョ編鎷夊攽鏄川瀛愭车鎶戝埗鍓傦紝鐢ㄤ簬娌荤枟鑳冮吀杩囧寮曡捣鐨勭柧鐥咃紝濡傝儍婧冪枴銆佸弽娴佹€ч绠＄値绛夈€傞暱鏈熶娇鐢ㄩ渶娉ㄦ剰楠ㄨ川鐤忔澗椋庨櫓銆?, '鑽搧璇存槑涔?, '2026-01-20 08:20:00'),
('浜岀敳鍙岃儘鏄彛鏈嶉檷绯栬嵂锛岀敤浜庢不鐤?鍨嬬硸灏跨梾銆傚父瑙佸壇浣滅敤鍖呮嫭鑳冭偁閬撳弽搴旓紝濡傛伓蹇冦€佽吂娉荤瓑銆?, '鑽搧璇存槑涔?, '2026-01-20 08:25:00'),
('娌欑編鐗圭綏鏇垮崱鏉炬槸澶嶆柟鍒跺墏锛岀敤浜庢不鐤楀摦鍠樺拰鎱㈡€ч樆濉炴€ц偤鐥呫€傚簲瀹氭湡浣跨敤锛屼笉瑕佺敤浜庢€ユ€у彂浣溿€?, '鑽搧璇存槑涔?, '2026-01-20 08:30:00'),
('闃垮徃鍖规灄鏄В鐑晣鐥涙姉鐐庤嵂锛屽皬鍓傞噺鐢ㄤ簬棰勯槻琛€鏍擄紝澶у墏閲忕敤浜庢鐥涢€€鐑€傞暱鏈熶娇鐢ㄩ渶娉ㄦ剰鑳冭偁閬撳嚭琛€椋庨櫓銆?, '鑽搧璇存槑涔?, '2026-01-20 08:35:00'),
('缁寸敓绱燙鏄姉姘у寲鍓傦紝鐢ㄤ簬棰勯槻鍜屾不鐤楃淮鐢熺礌C缂轰箯鐥囷紝澧炲己鍏嶇柅鍔涖€傝繃閲忔湇鐢ㄥ彲鑳藉鑷磋吂娉汇€?, '鑽搧璇存槑涔?, '2026-01-20 08:40:00'),
('鎰熷啋娓呯儹棰楃矑鏄腑鎴愯嵂锛岀敤浜庨瀵掓劅鍐掞紝鍏锋湁瑙ｈ〃娓呯儹銆佸鑲烘鍜冲姛鏁堛€傞鐑劅鍐掕€呬笉瀹滀娇鐢ㄣ€?, '鑽搧璇存槑涔?, '2026-01-20 08:45:00');

-- 鎻掑叆AI宸ュ叿璋冪敤瀹¤鏃ュ織鏁版嵁
INSERT INTO `ai_tool_usage_log` (`tool_name`, `parameters`, `result`, `user_id`, `created_at`) VALUES
('search_drug', '{"drug_name": "闃胯帿瑗挎灄"}', '{"code": 200, "data": {"name": "闃胯帿瑗挎灄", "category": "鎶楃敓绱?}}', 1, '2026-01-20 10:02:00'),
('check_interaction', '{"drug1": "闃胯帿瑗挎灄", "drug2": "甯冩礇鑺?}', '{"code": 200, "data": {"interaction": "鏃犳槑鏄剧浉浜掍綔鐢?}}', 1, '2026-01-20 10:08:00'),
('search_drug', '{"drug_name": "闃垮徃鍖规灄"}', '{"code": 200, "data": {"name": "闃垮徃鍖规灄", "category": "瑙ｇ儹闀囩棝"}}', 2, '2026-01-21 14:05:00'),
('check_adverse_reaction', '{"drug_name": "闃垮徃鍖规灄", "symptom": "鐨柟"}', '{"code": 200, "data": {"severity": "涓害", "advice": "绔嬪嵆鍋滆嵂骞跺氨鍖?}}', 2, '2026-01-21 14:08:00'),
('search_drug', '{"drug_name": "浜岀敳鍙岃儘"}', '{"code": 200, "data": {"name": "浜岀敳鍙岃儘", "category": "鍐呭垎娉?}}', 3, '2026-01-22 09:05:00'),
('search_drug', '{"drug_name": "纭濊嫰鍦板钩"}', '{"code": 200, "data": {"name": "纭濊嫰鍦板钩", "category": "蹇冭绠?}}', 4, '2026-01-23 11:02:00'),
('search_drug', '{"drug_name": "濂ョ編鎷夊攽"}', '{"code": 200, "data": {"name": "濂ョ編鎷夊攽", "category": "娑堝寲绯荤粺"}}', 5, '2026-01-24 16:10:00');
CREATE TABLE IF NOT EXISTS `audit_operation_log` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `actor_id` BIGINT(20),
  `actor_username` VARCHAR(100),
  `actor_role` VARCHAR(50),
  `method` VARCHAR(10) NOT NULL,
  `path` VARCHAR(300) NOT NULL,
  `query_string` VARCHAR(500),
  `status_code` INT(11),
  `client_ip` VARCHAR(64),
  `user_agent` VARCHAR(255),
  `target_type` VARCHAR(64),
  `target_id` BIGINT(20),
  `request_body` TEXT,
  `before_json` LONGTEXT,
  `after_json` LONGTEXT,
  `diff_json` LONGTEXT,
  `occurred_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_actor_id` (`actor_id`),
  KEY `idx_occurred_at` (`occurred_at`),
  KEY `idx_method_path` (`method`, `path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
