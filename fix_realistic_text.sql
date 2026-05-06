UPDATE user SET organization = '华南现代制药有限公司' WHERE id = 3;
UPDATE user SET organization = '广东瑞康医药供应链有限公司' WHERE id = 4;
UPDATE user SET organization = '深圳市人民医院' WHERE id = 5;
UPDATE user SET organization = '岭南生物医药股份有限公司' WHERE id = 8;
UPDATE user SET organization = '佛山广济医药物流有限公司' WHERE id = 9;
UPDATE user SET organization = '东莞安泽医药供应链有限公司' WHERE id = 10;
UPDATE user SET organization = '中山大学附属第一医院' WHERE id = 11;
UPDATE user SET organization = '惠州众健医药有限公司' WHERE id = 15;

UPDATE drug_info SET manufacturer = '华南现代制药有限公司' WHERE id BETWEEN 101 AND 108;
UPDATE drug_info SET manufacturer = '岭南生物医药股份有限公司' WHERE id BETWEEN 109 AND 112;
