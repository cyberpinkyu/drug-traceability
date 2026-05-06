SET NAMES utf8mb4;
USE drug_traceability;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE audit_operation_log;
TRUNCATE TABLE ai_message;
TRUNCATE TABLE ai_conversation;
TRUNCATE TABLE ai_tool_usage_log;
TRUNCATE TABLE ai_knowledge_doc;
TRUNCATE TABLE scan_log;
TRUNCATE TABLE regulatory_enforcement;
TRUNCATE TABLE regulatory_task;
TRUNCATE TABLE alert_ticket;
TRUNCATE TABLE message_notice;
TRUNCATE TABLE trace_record;
TRUNCATE TABLE adverse_reaction;
TRUNCATE TABLE usage_record;
TRUNCATE TABLE inventory;
TRUNCATE TABLE sale_record;
TRUNCATE TABLE procurement_record;
TRUNCATE TABLE production_batch;
TRUNCATE TABLE drug_info;
TRUNCATE TABLE user;
TRUNCATE TABLE role;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO role (id, name, code, description) VALUES
(1, '平台管理员', 'admin', '系统配置、基础数据与全局监管'),
(2, '监管人员', 'regulator', '风险研判、任务派发和执法闭环'),
(3, '生产企业', 'producer', '药品生产与批次建档'),
(4, '流通企业', 'distributor', '药品采购、仓储和配送'),
(5, '医疗机构', 'hospital', '院内库存、用药和不良反应上报'),
(6, '公众用户', 'public', '扫码溯源和公众查询');

INSERT INTO user (id, username, password, name, role_id, organization, phone, email, status) VALUES
(1, 'admin', '123456', '平台管理员', 1, '广东省药品追溯监管平台', '13800000001', 'admin@trace.local', 1),
(2, 'regulator', '123456', '李卫东', 2, '广东省药品监督管理局', '13800000002', 'regulator@trace.local', 1),
(3, 'producer', '123456', '陈立峰', 3, '华南现代制药有限公司', '13800000003', 'producer@trace.local', 1),
(4, 'distributor', '123456', '王晓晨', 4, '广东瑞康医药供应链有限公司', '13800000004', 'gz-distribution@trace.local', 1),
(5, 'hospital', '123456', '刘敏', 5, '深圳市人民医院', '13800000005', 'sz-hospital@trace.local', 1),
(6, 'public', '123456', '张晓雯', 6, '个人用户', '13800000006', 'public@trace.local', 1),
(7, 'regulator2', '123456', '周宁', 2, '深圳市市场监督管理局药品处', '13800000007', 'sz-regulator@trace.local', 1),
(8, 'producer2', '123456', '赵嘉明', 3, '岭南生物医药股份有限公司', '13800000008', 'producer2@trace.local', 1),
(9, 'dist_foshan', '123456', '何志强', 4, '佛山广济医药物流有限公司', '13800000009', 'fs-distribution@trace.local', 1),
(10, 'dist_dongguan', '123456', '梁思远', 4, '东莞安泽医药供应链有限公司', '13800000010', 'dg-distribution@trace.local', 1),
(11, 'hospital_gz', '123456', '黄雅婷', 5, '中山大学附属第一医院', '13800000011', 'gz-hospital@trace.local', 1),
(12, 'hospital_fs', '123456', '郑文博', 5, '佛山市第一人民医院', '13800000012', 'fs-hospital@trace.local', 1),
(13, 'hospital_dg', '123456', '林秋月', 5, '东莞市人民医院', '13800000013', 'dg-hospital@trace.local', 1),
(14, 'hospital_zh', '123456', '许嘉怡', 5, '珠海市人民医院', '13800000014', 'zh-hospital@trace.local', 1),
(15, 'dist_huizhou', '123456', '叶景辉', 4, '惠州众健医药有限公司', '13800000015', 'hz-distribution@trace.local', 1),
(16, 'hospital_hz', '123456', '陈若琳', 5, '惠州市中心人民医院', '13800000016', 'hz-hospital@trace.local', 1);

INSERT INTO drug_info (id, drug_code, name, specification, manufacturer, approval_number, category, unit, price, status) VALUES
(101, 'RX260401', '阿莫西林胶囊', '0.25g*24粒/盒', '华南现代制药有限公司', '国药准字H13023371', '抗感染', '盒', 25.80, 1),
(102, 'RX260402', '布洛芬缓释胶囊', '0.3g*20粒/盒', '华南现代制药有限公司', '国药准字H10900089', '解热镇痛', '盒', 29.60, 1),
(103, 'RX260403', '盐酸二甲双胍片', '0.5g*60片/瓶', '华南现代制药有限公司', '国药准字H20023367', '内分泌', '瓶', 18.90, 1),
(104, 'RX260404', '氯雷他定片', '10mg*12片/盒', '华南现代制药有限公司', '国药准字H20000008', '抗过敏', '盒', 16.50, 1),
(105, 'RX260405', '头孢克肟分散片', '0.1g*12片/盒', '华南现代制药有限公司', '国药准字H20080614', '抗感染', '盒', 36.00, 1),
(106, 'RX260406', '奥美拉唑肠溶胶囊', '20mg*14粒/盒', '华南现代制药有限公司', '国药准字H20051408', '消化系统', '盒', 22.80, 1),
(107, 'RX260407', '阿托伐他汀钙片', '20mg*7片/盒', '华南现代制药有限公司', '国药准字H20040217', '心血管', '盒', 42.50, 1),
(108, 'RX260408', '蒙脱石散', '3g*10袋/盒', '华南现代制药有限公司', '国药准字H20040091', '消化系统', '盒', 19.80, 1),
(109, 'RX260409', '左氧氟沙星片', '0.5g*6片/盒', '岭南生物医药股份有限公司', '国药准字H20000258', '抗感染', '盒', 31.20, 1),
(110, 'RX260410', '缬沙坦胶囊', '80mg*14粒/盒', '岭南生物医药股份有限公司', '国药准字H20040215', '心血管', '盒', 38.90, 1),
(111, 'RX260411', '维生素C片', '100mg*100片/瓶', '岭南生物医药股份有限公司', '国药准字H44020774', '维生素矿物质', '瓶', 12.60, 1),
(112, 'RX260412', '复方甘草片', '100片/瓶', '岭南生物医药股份有限公司', '国药准字H44022188', '呼吸系统', '瓶', 14.80, 1);

DROP TEMPORARY TABLE IF EXISTS tmp_batch_seed;
CREATE TEMPORARY TABLE tmp_batch_seed (
  seq INT PRIMARY KEY,
  drug_id BIGINT,
  batch_number VARCHAR(50),
  producer_id BIGINT,
  production_date DATE,
  quantity INT,
  price DECIMAL(10,2)
);

INSERT INTO tmp_batch_seed (seq, drug_id, batch_number, producer_id, production_date, quantity, price)
SELECT n,
       101 + ((n - 1) % 12),
       CONCAT('B26', LPAD(MONTH(DATE_ADD('2026-01-05', INTERVAL n * 3 DAY)), 2, '0'), LPAD(n, 3, '0'), CHAR(64 + ((n - 1) % 3) + 1)),
       CASE WHEN n % 4 = 0 THEN 8 ELSE 3 END,
       DATE_ADD('2026-01-05', INTERVAL n * 3 DAY),
       8000 + (n % 9) * 850 + (n % 5) * 300,
       12 + (n % 10) * 2.3
FROM (
  SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
  UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
  UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30
  UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40
  UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45 UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48
) nums;

UPDATE tmp_batch_seed SET batch_number = 'B260405A', drug_id = 105, production_date = '2026-03-09', quantity = 14000 WHERE seq = 21;
UPDATE tmp_batch_seed SET batch_number = 'B260401A', drug_id = 101, production_date = '2026-03-01', quantity = 12000 WHERE seq = 18;
UPDATE tmp_batch_seed SET batch_number = 'B260407A', drug_id = 107, production_date = '2026-03-13', quantity = 16000 WHERE seq = 22;

INSERT INTO production_batch (id, batch_number, drug_id, production_date, expiry_date, production_quantity, producer_id, status)
SELECT 1000 + seq, batch_number, drug_id, production_date, DATE_ADD(production_date, INTERVAL 24 MONTH), quantity, producer_id, 1
FROM tmp_batch_seed;

INSERT INTO procurement_record (id, batch_id, buyer_id, supplier_id, quantity, purchase_date, purchase_price, status)
SELECT 2000 + seq * 10 + route,
       1000 + seq,
       CASE route WHEN 1 THEN 4 WHEN 2 THEN 9 WHEN 3 THEN 10 ELSE 15 END,
       producer_id,
       FLOOR(quantity * (0.20 + route * 0.035)),
       DATE_ADD(production_date, INTERVAL 5 + route DAY),
       price,
       1
FROM tmp_batch_seed
JOIN (SELECT 1 route UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) routes;

INSERT INTO sale_record (id, batch_id, seller_id, buyer_id, quantity, sale_date, sale_price, status)
SELECT 3000 + seq * 10 + route,
       1000 + seq,
       CASE route WHEN 1 THEN 4 WHEN 2 THEN 9 WHEN 3 THEN 10 ELSE 15 END,
       CASE route WHEN 1 THEN 11 WHEN 2 THEN 12 WHEN 3 THEN 13 ELSE 16 END,
       FLOOR(quantity * (0.08 + route * 0.02)),
       DATE_ADD(production_date, INTERVAL 13 + route * 2 DAY),
       price * 1.28,
       1
FROM tmp_batch_seed
JOIN (SELECT 1 route UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) routes;

INSERT INTO sale_record (id, batch_id, seller_id, buyer_id, quantity, sale_date, sale_price, status)
SELECT 3600 + seq,
       1000 + seq,
       4,
       5,
       FLOOR(quantity * 0.07),
       DATE_ADD(production_date, INTERVAL 18 DAY),
       price * 1.32,
       1
FROM tmp_batch_seed
WHERE seq % 2 = 0;

INSERT INTO inventory (id, batch_id, organization_id, quantity, last_update_date, status)
SELECT 4000 + seq * 100 + org_id,
       1000 + seq,
       org_id,
       CASE
         WHEN org_id = producer_id THEN FLOOR(quantity * 0.22)
         WHEN org_id IN (4, 9, 10, 15) THEN FLOOR(quantity * 0.09 + (seq % 5) * 70)
         ELSE FLOOR(quantity * 0.04 + (seq % 4) * 40)
       END,
       DATE_ADD(production_date, INTERVAL 24 DAY),
       1
FROM tmp_batch_seed
JOIN (
  SELECT 3 org_id UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
  UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
) orgs
WHERE org_id = producer_id OR org_id IN (4, 5, 9, 10, 11, 12, 13, 14, 15, 16);

INSERT INTO usage_record (id, drug_id, patient_name, dosage, frequency, usage_date, doctor_id, hospital, status, created_at)
SELECT 5000 + seq * 10 + route,
       drug_id,
       ELT(((seq + route) % 12) + 1, '赵云海', '林晓彤', '陈建国', '黄丽君', '宋伟', '谢婉婷', '周明', '罗嘉欣', '吴国强', '梁敏', '何思源', '郑芳'),
       ELT(((seq + route) % 5) + 1, '0.25g', '0.5g', '10mg', '20mg', '1袋'),
       ELT(((seq + route) % 4) + 1, '每日1次', '每日2次', '每日3次', '必要时服用'),
       DATE_ADD(production_date, INTERVAL 24 + route DAY),
       CASE route WHEN 1 THEN 11 WHEN 2 THEN 12 WHEN 3 THEN 13 ELSE 16 END,
       CASE route WHEN 1 THEN '广州中山大学附属第一医院' WHEN 2 THEN '佛山市第一人民医院' WHEN 3 THEN '东莞市人民医院' ELSE '惠州市中心人民医院' END,
       1,
       CONCAT(DATE_ADD(production_date, INTERVAL 24 + route DAY), ' ', LPAD(8 + route, 2, '0'), ':20:00')
FROM tmp_batch_seed
JOIN (SELECT 1 route UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) routes
WHERE seq <= 36;

INSERT INTO adverse_reaction (id, drug_id, patient_name, reaction_description, severity, hospital, doctor_name, reporter_id, status, created_at)
SELECT 6000 + seq,
       drug_id,
       ELT((seq % 10) + 1, '刘先生', '张女士', '陈先生', '王女士', '孙先生', '赵女士', '李先生', '黄女士', '周先生', '许女士'),
       ELT((seq % 6) + 1, '服药后出现皮疹，停药观察后缓解。', '用药后出现胃部不适，调整餐后服用后改善。', '出现轻度头晕，门诊复核后继续观察。', '出现喉部不适，已完成过敏史复核。', '疑似剂量相关肌肉酸痛，已建议复诊。', '出现短暂腹泻，补液后好转。'),
       CASE WHEN seq % 7 IN (0, 1) THEN 'high' WHEN seq % 7 IN (2, 3, 4) THEN 'medium' ELSE 'low' END,
       ELT((seq % 6) + 1, '深圳市人民医院', '中山大学附属第一医院', '佛山市第一人民医院', '东莞市人民医院', '珠海市人民医院', '惠州市中心人民医院'),
       ELT((seq % 6) + 1, '刘敏', '黄雅婷', '郑文博', '林秋月', '许嘉怡', '陈若琳'),
       ELT((seq % 6) + 1, 5, 11, 12, 13, 14, 16),
       CASE WHEN seq % 4 = 0 THEN 4 WHEN seq % 4 = 1 THEN 3 WHEN seq % 4 = 2 THEN 2 ELSE 1 END,
       CONCAT(DATE_ADD(production_date, INTERVAL 28 + (seq % 9) DAY), ' ', LPAD(9 + (seq % 8), 2, '0'), ':15:00')
FROM tmp_batch_seed
WHERE seq <= 30;

INSERT INTO trace_record (id, drug_code, batch_number, trace_step, step_time, organization, description, status)
SELECT 7000 + seq * 10 + step_no,
       d.drug_code,
       b.batch_number,
       ELT(step_no, '原料入厂', '生产投料', '成品检验', '成品入库', '配送出库', '医疗机构验收', '院内使用', '风险监测'),
       CASE step_no
         WHEN 1 THEN CONCAT(b.production_date, ' 08:30:00')
         WHEN 2 THEN CONCAT(b.production_date, ' 13:20:00')
         WHEN 3 THEN CONCAT(DATE_ADD(b.production_date, INTERVAL 1 DAY), ' 10:10:00')
         WHEN 4 THEN CONCAT(DATE_ADD(b.production_date, INTERVAL 2 DAY), ' 09:40:00')
         WHEN 5 THEN CONCAT(DATE_ADD(b.production_date, INTERVAL 8 DAY), ' 15:10:00')
         WHEN 6 THEN CONCAT(DATE_ADD(b.production_date, INTERVAL 16 DAY), ' 09:25:00')
         WHEN 7 THEN CONCAT(DATE_ADD(b.production_date, INTERVAL 25 DAY), ' 10:30:00')
         ELSE CONCAT(DATE_ADD(b.production_date, INTERVAL 32 DAY), ' 11:00:00')
       END,
       ELT(step_no, u.organization, u.organization, u.organization, u.organization, '广东瑞康医药供应链有限公司', '深圳市人民医院', '深圳市人民医院', '广东省药品监督管理局'),
       ELT(step_no, '完成原辅料到货验收和供应商资质核验', '按生产指令完成投料和过程记录', '关键质量指标检验合格', '成品入库并生成追溯码', '冷链/常温运输记录完整', '院内扫码验收入库', '完成患者用药登记', '监管端完成风险复核'),
       1
FROM tmp_batch_seed b
JOIN drug_info d ON d.id = b.drug_id
JOIN user u ON u.id = b.producer_id
JOIN (SELECT 1 step_no UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8) steps;

INSERT INTO scan_log (id, trace_code, device_id, signature, request_ts, verify_passed, offline_flag, source_ip, created_at)
SELECT 9700 + seq,
       batch_number,
       ELT((seq % 4) + 1, 'web-regulator', 'app-public', 'app-hospital', 'app-regulator'),
       CONCAT('sample-sign-', seq),
       UNIX_TIMESTAMP(DATE_ADD(production_date, INTERVAL 30 DAY)) * 1000,
       CASE WHEN seq % 13 = 0 THEN 0 ELSE 1 END,
       CASE WHEN seq % 11 = 0 THEN 1 ELSE 0 END,
       '127.0.0.1',
       CONCAT(DATE_ADD(production_date, INTERVAL 30 DAY), ' 09:00:00')
FROM tmp_batch_seed;

INSERT INTO alert_ticket (id, title, source_type, source_id, severity, status, assignee_id, description, closed_result, closed_at)
SELECT 9000 + id - 6000,
       CONCAT('不良反应复核：', patient_name),
       'adverse',
       id,
       severity,
       CASE WHEN status >= 3 THEN 2 ELSE 1 END,
       CASE WHEN hospital LIKE '%深圳%' THEN 7 ELSE 2 END,
       reaction_description,
       CASE WHEN status >= 3 THEN '已核对批次流向和院内处置记录，未发现假劣药风险。' ELSE NULL END,
       CASE WHEN status >= 3 THEN DATE_ADD(created_at, INTERVAL 1 DAY) ELSE NULL END
FROM adverse_reaction
WHERE id <= 6018;

INSERT INTO message_notice (id, title, content, channel, receiver_id, receiver_contact, biz_type, biz_id, status, sent_at, read_at)
SELECT 8000 + id - 6000,
       CONCAT('风险上报提醒：', severity),
       CONCAT(hospital, '上报不良反应，需核查批次流向和库存。'),
       'site',
       CASE WHEN hospital LIKE '%深圳%' THEN 7 ELSE 2 END,
       CASE WHEN hospital LIKE '%深圳%' THEN 'sz-regulator@trace.local' ELSE 'regulator@trace.local' END,
       'adverse_reaction',
       id,
       CASE WHEN status >= 3 THEN 1 ELSE 0 END,
       created_at,
       CASE WHEN status >= 3 THEN DATE_ADD(created_at, INTERVAL 2 HOUR) ELSE NULL END
FROM adverse_reaction
WHERE id <= 6020;

INSERT INTO regulatory_task (id, report_id, assignee_id, suspected_source, suspected_org_id, conclusion_source, conclusion_org_id, verified, investigation_result, status, dispatched_at, investigated_at, enforced_at)
SELECT 9500 + id - 6000,
       id,
       CASE WHEN hospital LIKE '%深圳%' THEN 7 ELSE 2 END,
       'hospital',
       reporter_id,
       'hospital',
       reporter_id,
       CASE WHEN status >= 3 THEN 1 ELSE 0 END,
       CASE WHEN status >= 3 THEN '已核查用药记录、库存记录和批次流向，处置流程完整。' ELSE '待完成现场核查和处置闭环。' END,
       CASE WHEN status >= 3 THEN 3 ELSE 1 END,
       created_at,
       CASE WHEN status >= 3 THEN DATE_ADD(created_at, INTERVAL 1 DAY) ELSE NULL END,
       CASE WHEN status = 4 THEN DATE_ADD(created_at, INTERVAL 2 DAY) ELSE NULL END
FROM adverse_reaction
WHERE id <= 6012;

INSERT INTO regulatory_enforcement (id, inspector_id, organization_id, inspection_type, inspection_result, description, inspection_date, status)
VALUES
(9601, 2, 11, '专项核查', '完成整改', '核查抗感染类药品批次流向、不良反应上报和院内处置记录。', '2026-03-28 10:00:00', 1),
(9602, 7, 5, '飞行检查', '记录完整', '抽查扫码验收、院内用药登记和库存台账。', '2026-04-02 15:00:00', 1),
(9603, 2, 4, '日常巡查', '未发现异常', '核查配送中心出入库记录和温湿度记录。', '2026-04-06 09:30:00', 1),
(9604, 7, 13, '风险复核', '持续跟踪', '针对高风险上报开展院内病例复核。', '2026-04-10 14:20:00', 1);

INSERT INTO ai_conversation (conversation_id, user_id, title, created_at, updated_at) VALUES
(9801, 2, '三月重点批次风险复盘', '2026-04-03 09:00:00', '2026-04-03 09:12:00'),
(9802, 5, '院内常用药库存建议', '2026-04-04 14:00:00', '2026-04-04 14:10:00');

INSERT INTO ai_message (message_id, conversation_id, role, content, created_at) VALUES
(9901, 9801, 'user', '请总结三月高风险批次和不良反应处置情况。', '2026-04-03 09:00:00'),
(9902, 9801, 'assistant', '三月重点关注头孢克肟分散片批次 B260405A，已完成批次流向、院内库存和不良反应闭环核查。', '2026-04-03 09:03:00'),
(9903, 9802, 'user', '结合近期用量，哪些药品需要优先补货？', '2026-04-04 14:00:00'),
(9904, 9802, 'assistant', '建议优先关注阿莫西林胶囊、头孢克肟分散片和蒙脱石散的院内库存周转。', '2026-04-04 14:04:00');

INSERT INTO ai_knowledge_doc (doc_id, content, source, created_at, updated_at) VALUES
(10001, '抗感染类药品应重点关注批次流向、不良反应聚集和库存周转异常。', '监管知识库', '2026-04-01 08:00:00', '2026-04-01 08:00:00'),
(10002, '扫码溯源结果应包含生产、检验、仓储、配送、验收、使用和风险监测节点。', '追溯规范', '2026-04-01 08:05:00', '2026-04-01 08:05:00');

DROP TEMPORARY TABLE IF EXISTS tmp_batch_seed;
