USE drug_traceability;

SET NAMES utf8mb4;

SET @producer_id := (
  SELECT u.id FROM user u
  LEFT JOIN role r ON r.id = u.role_id
  WHERE u.username = 'producer' OR r.code = 'producer'
  ORDER BY (u.username='producer') DESC, u.id ASC
  LIMIT 1
);

SET @distributor_id := (
  SELECT u.id FROM user u
  LEFT JOIN role r ON r.id = u.role_id
  WHERE u.username = 'distributor' OR r.code IN ('distributor','enterprise')
  ORDER BY (u.username='distributor') DESC, u.id ASC
  LIMIT 1
);

SET @hospital_id := (
  SELECT u.id FROM user u
  LEFT JOIN role r ON r.id = u.role_id
  WHERE u.username = 'hospital' OR r.code IN ('hospital','institution')
  ORDER BY (u.username='hospital') DESC, u.id ASC
  LIMIT 1
);

DROP TEMPORARY TABLE IF EXISTS tmp_flow_10;
CREATE TEMPORARY TABLE tmp_flow_10 (
  seq INT PRIMARY KEY,
  drug_code VARCHAR(50),
  drug_name VARCHAR(100),
  specification VARCHAR(100),
  approval_number VARCHAR(100),
  category VARCHAR(50),
  unit VARCHAR(20),
  price DECIMAL(10,2),
  batch_number VARCHAR(50),
  production_date DATE,
  expiry_date DATE,
  production_qty INT,
  procurement_qty INT,
  sale_qty INT,
  patient_name VARCHAR(50),
  dosage VARCHAR(50),
  frequency VARCHAR(50),
  usage_date DATE,
  hospital_name VARCHAR(100),
  doctor_name VARCHAR(50),
  reaction_desc VARCHAR(500),
  severity VARCHAR(20)
);

INSERT INTO tmp_flow_10 VALUES
(1, 'RX260401', '阿莫西林胶囊', '0.25g*24粒', '国药准字H13023371', '抗感染', '盒', 22.50, 'B260401', '2026-03-01', '2028-02-29', 12000, 7000, 5200, '张海', '0.5g', '每日3次', '2026-03-13', '第一人民医院', '赵医生', NULL, NULL),
(2, 'RX260402', '布洛芬缓释胶囊', '0.3g*20粒', '国药准字H10900089', '解热镇痛', '盒', 28.00, 'B260402', '2026-03-02', '2028-03-01', 10000, 6200, 4300, '李婷', '0.3g', '每日2次', '2026-03-14', '第一人民医院', '王医生', NULL, NULL),
(3, 'RX260403', '盐酸二甲双胍片', '0.5g*60片', '国药准字H20023367', '内分泌', '瓶', 18.80, 'B260403', '2026-03-03', '2028-03-02', 9000, 5800, 4100, '王强', '0.5g', '每日2次', '2026-03-15', '第一人民医院', '陈医生', '患者服药后出现轻度胃部不适，调整餐后服用后缓解', '轻度'),
(4, 'RX260404', '氯雷他定片', '10mg*24片', '国药准字H20000008', '抗过敏', '盒', 16.90, 'B260404', '2026-03-04', '2028-03-03', 8500, 5000, 3600, '刘敏', '10mg', '每日1次', '2026-03-16', '第一人民医院', '周医生', NULL, NULL),
(5, 'RX260405', '奥美拉唑肠溶胶囊', '20mg*28粒', '国药准字H20080614', '消化系统', '盒', 31.20, 'B260405', '2026-03-05', '2028-03-04', 11000, 6800, 4900, '陈磊', '20mg', '每日1次', '2026-03-17', '第一人民医院', '李医生', NULL, NULL),
(6, 'RX260406', '阿托伐他汀钙片', '20mg*14片', '国药准字H20051408', '心血管', '盒', 42.60, 'B260406', '2026-03-06', '2028-03-05', 9500, 5600, 4000, '赵颖', '20mg', '每日1次', '2026-03-18', '第一人民医院', '孙医生', NULL, NULL),
(7, 'RX260407', '缬沙坦胶囊', '80mg*14粒', '国药准字H20040217', '降压', '盒', 35.40, 'B260407', '2026-03-07', '2028-03-06', 9800, 6000, 4200, '黄杰', '80mg', '每日1次', '2026-03-19', '第一人民医院', '吴医生', NULL, NULL),
(8, 'RX260408', '左氧氟沙星片', '0.5g*10片', '国药准字H20040091', '抗感染', '盒', 26.50, 'B260408', '2026-03-08', '2028-03-07', 8700, 5200, 3500, '何兰', '0.5g', '每日1次', '2026-03-20', '第一人民医院', '冯医生', '患者服药后出现轻度皮疹，停药并更换方案后恢复', '轻度'),
(9, 'RX260409', '甲硝唑片', '0.2g*24片', '国药准字H41021418', '抗感染', '盒', 12.80, 'B260409', '2026-03-09', '2028-03-08', 9200, 5400, 3800, '谢宁', '0.2g', '每日3次', '2026-03-21', '第一人民医院', '高医生', NULL, NULL),
(10, 'RX260410', '维生素C片', '100mg*100片', '国药准字H42021825', '维生素', '瓶', 9.90, 'B260410', '2026-03-10', '2028-03-09', 13000, 8000, 6200, '孙洁', '100mg', '每日1次', '2026-03-22', '第一人民医院', '马医生', NULL, NULL);

-- drug_info
INSERT INTO drug_info (drug_code, name, specification, manufacturer, approval_number, category, unit, price, status)
SELECT t.drug_code, t.drug_name, t.specification, '华康制药有限公司', t.approval_number, t.category, t.unit, t.price, 1
FROM tmp_flow_10 t
WHERE NOT EXISTS (SELECT 1 FROM drug_info d WHERE d.drug_code = t.drug_code);

-- production_batch
INSERT INTO production_batch (batch_number, drug_id, production_date, expiry_date, production_quantity, producer_id, status)
SELECT t.batch_number, d.id, t.production_date, t.expiry_date, t.production_qty, @producer_id, 1
FROM tmp_flow_10 t
JOIN drug_info d ON d.drug_code = t.drug_code
WHERE NOT EXISTS (SELECT 1 FROM production_batch b WHERE b.batch_number = t.batch_number);

-- procurement_record
INSERT INTO procurement_record (batch_id, buyer_id, supplier_id, quantity, purchase_date, purchase_price, status)
SELECT b.id, @distributor_id, @producer_id, t.procurement_qty, DATE_ADD(t.production_date, INTERVAL 5 DAY), ROUND(t.price * 0.72, 2), 1
FROM tmp_flow_10 t
JOIN production_batch b ON b.batch_number = t.batch_number
WHERE NOT EXISTS (
  SELECT 1 FROM procurement_record p
  WHERE p.batch_id = b.id AND p.buyer_id = @distributor_id AND p.supplier_id = @producer_id
);

-- sale_record
INSERT INTO sale_record (batch_id, seller_id, buyer_id, quantity, sale_date, sale_price, status)
SELECT b.id, @distributor_id, @hospital_id, t.sale_qty, DATE_ADD(t.production_date, INTERVAL 10 DAY), ROUND(t.price * 0.93, 2), 1
FROM tmp_flow_10 t
JOIN production_batch b ON b.batch_number = t.batch_number
WHERE NOT EXISTS (
  SELECT 1 FROM sale_record s
  WHERE s.batch_id = b.id AND s.seller_id = @distributor_id AND s.buyer_id = @hospital_id
);

-- inventory (producer/distributor/hospital)
INSERT INTO inventory (batch_id, organization_id, quantity, last_update_date, status)
SELECT b.id, @producer_id, t.production_qty - t.procurement_qty, DATE_ADD(t.production_date, INTERVAL 10 DAY), 1
FROM tmp_flow_10 t
JOIN production_batch b ON b.batch_number = t.batch_number
ON DUPLICATE KEY UPDATE quantity = VALUES(quantity), last_update_date = VALUES(last_update_date), status = 1;

INSERT INTO inventory (batch_id, organization_id, quantity, last_update_date, status)
SELECT b.id, @distributor_id, t.procurement_qty - t.sale_qty, DATE_ADD(t.production_date, INTERVAL 10 DAY), 1
FROM tmp_flow_10 t
JOIN production_batch b ON b.batch_number = t.batch_number
ON DUPLICATE KEY UPDATE quantity = VALUES(quantity), last_update_date = VALUES(last_update_date), status = 1;

INSERT INTO inventory (batch_id, organization_id, quantity, last_update_date, status)
SELECT b.id, @hospital_id, t.sale_qty, DATE_ADD(t.production_date, INTERVAL 10 DAY), 1
FROM tmp_flow_10 t
JOIN production_batch b ON b.batch_number = t.batch_number
ON DUPLICATE KEY UPDATE quantity = VALUES(quantity), last_update_date = VALUES(last_update_date), status = 1;

-- usage_record
INSERT INTO usage_record (drug_id, patient_name, dosage, frequency, usage_date, doctor_id, hospital, status)
SELECT d.id, t.patient_name, t.dosage, t.frequency, t.usage_date, @hospital_id, t.hospital_name, 1
FROM tmp_flow_10 t
JOIN drug_info d ON d.drug_code = t.drug_code
WHERE NOT EXISTS (
  SELECT 1 FROM usage_record u
  WHERE u.drug_id = d.id AND u.patient_name = t.patient_name AND u.usage_date = t.usage_date
);

-- adverse_reaction (only rows with reaction text)
INSERT INTO adverse_reaction (drug_id, patient_name, reaction_description, severity, hospital, doctor_name, reporter_id, status)
SELECT d.id, t.patient_name, t.reaction_desc, t.severity, t.hospital_name, t.doctor_name, @hospital_id, 1
FROM tmp_flow_10 t
JOIN drug_info d ON d.drug_code = t.drug_code
WHERE t.reaction_desc IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM adverse_reaction a
    WHERE a.drug_id = d.id AND a.patient_name = t.patient_name AND a.reaction_description = t.reaction_desc
  );

-- trace_record (6 steps each)
INSERT INTO trace_record (drug_code, batch_number, trace_step, step_time, organization, description, status)
SELECT t.drug_code, t.batch_number, 'raw_material_check', CONCAT(t.production_date, ' 08:30:00'), '华康制药有限公司', '原料入厂并完成检验', 1
FROM tmp_flow_10 t
WHERE NOT EXISTS (
  SELECT 1 FROM trace_record r
  WHERE r.drug_code = t.drug_code AND r.batch_number = t.batch_number AND r.trace_step = 'raw_material_check'
);

INSERT INTO trace_record (drug_code, batch_number, trace_step, step_time, organization, description, status)
SELECT t.drug_code, t.batch_number, 'production_process', CONCAT(t.production_date, ' 14:00:00'), '华康制药有限公司', '生产线按SOP完成加工包装', 1
FROM tmp_flow_10 t
WHERE NOT EXISTS (
  SELECT 1 FROM trace_record r
  WHERE r.drug_code = t.drug_code AND r.batch_number = t.batch_number AND r.trace_step = 'production_process'
);

INSERT INTO trace_record (drug_code, batch_number, trace_step, step_time, organization, description, status)
SELECT t.drug_code, t.batch_number, 'quality_release', CONCAT(DATE_ADD(t.production_date, INTERVAL 1 DAY), ' 10:20:00'), '华康制药有限公司', '批次抽检合格并放行', 1
FROM tmp_flow_10 t
WHERE NOT EXISTS (
  SELECT 1 FROM trace_record r
  WHERE r.drug_code = t.drug_code AND r.batch_number = t.batch_number AND r.trace_step = 'quality_release'
);

INSERT INTO trace_record (drug_code, batch_number, trace_step, step_time, organization, description, status)
SELECT t.drug_code, t.batch_number, 'procurement_in', CONCAT(DATE_ADD(t.production_date, INTERVAL 5 DAY), ' 16:00:00'), '安平医药配送中心', '配送中心完成批次入库', 1
FROM tmp_flow_10 t
WHERE NOT EXISTS (
  SELECT 1 FROM trace_record r
  WHERE r.drug_code = t.drug_code AND r.batch_number = t.batch_number AND r.trace_step = 'procurement_in'
);

INSERT INTO trace_record (drug_code, batch_number, trace_step, step_time, organization, description, status)
SELECT t.drug_code, t.batch_number, 'sale_out', CONCAT(DATE_ADD(t.production_date, INTERVAL 10 DAY), ' 09:30:00'), '安平医药配送中心', '销售配送至第一人民医院', 1
FROM tmp_flow_10 t
WHERE NOT EXISTS (
  SELECT 1 FROM trace_record r
  WHERE r.drug_code = t.drug_code AND r.batch_number = t.batch_number AND r.trace_step = 'sale_out'
);

INSERT INTO trace_record (drug_code, batch_number, trace_step, step_time, organization, description, status)
SELECT t.drug_code, t.batch_number, 'clinical_use', CONCAT(t.usage_date, ' 10:45:00'), '第一人民医院', CONCAT('用于患者', t.patient_name, '治疗方案'), 1
FROM tmp_flow_10 t
WHERE NOT EXISTS (
  SELECT 1 FROM trace_record r
  WHERE r.drug_code = t.drug_code AND r.batch_number = t.batch_number AND r.trace_step = 'clinical_use'
);

DROP TEMPORARY TABLE IF EXISTS tmp_flow_10;