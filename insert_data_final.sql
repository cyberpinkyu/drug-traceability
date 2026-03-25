USE drug_traceability;

INSERT INTO drug_info (drug_code, name, specification, manufacturer, approval_number, category, unit, price, status) VALUES
('D001', 'Amoxicillin Capsules', '0.25g*24caps', 'North China Pharma', 'National Drug H13023371', 'Antibiotic', 'box', 25.50, 1),
('D002', 'Ibuprofen Sustained Capsules', '0.3g*10caps', 'SmithKline', 'National Drug H10900089', 'Analgesic', 'box', 32.80, 1),
('D003', 'Paracetamol Tablets', '0.5g*24tabs', 'Johnson & Johnson', 'National Drug H31020539', 'Antipyretic', 'box', 18.50, 1),
('D004', 'Nifedipine Tablets', '10mg*20tabs', 'Bayer', 'National Drug H10930007', 'Cardiovascular', 'box', 45.20, 1),
('D005', 'Omeprazole Enteric Capsules', '20mg*14caps', 'AstraZeneca', 'National Drug H10960297', 'Digestive', 'box', 68.50, 1),
('D006', 'Metformin Tablets', '0.5g*30tabs', 'Merck', 'National Drug H20023367', 'Endocrine', 'box', 35.80, 1),
('D007', 'Salmeterol Fluticasone Inhaler', '50ug/500ug*60puffs', 'GSK', 'National Drug H20050917', 'Respiratory', 'box', 180.00, 1),
('D008', 'Aspirin Enteric Tablets', '100mg*30tabs', 'Bayer', 'National Drug H11020001', 'Analgesic', 'box', 15.60, 1),
('D009', 'Vitamin C Tablets', '100mg*100tabs', 'Bayer', 'National Drug H42021837', 'Vitamin', 'bottle', 22.80, 1),
('D010', 'Cold and Heat Relief Granules', '12g*10bags', 'Tong Ren Tang', 'National Drug Z11020617', 'Antipyretic', 'box', 28.50, 1);

INSERT INTO production_batch (batch_number, drug_id, production_date, expiry_date, production_quantity, producer_id, status) VALUES
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

INSERT INTO inventory (batch_id, organization_id, quantity, last_update_date, status) VALUES
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

INSERT INTO procurement_record (batch_id, buyer_id, supplier_id, quantity, purchase_date, purchase_price, status) VALUES
(1, 4, 3, 1000, '2026-01-15', 20.00, 1),
(2, 4, 3, 800, '2026-01-16', 28.00, 1),
(3, 5, 3, 1200, '2026-01-17', 15.00, 1),
(4, 4, 3, 600, '2026-01-18', 40.00, 1),
(5, 5, 3, 500, '2026-01-19', 60.00, 1);

INSERT INTO sale_record (batch_id, seller_id, buyer_id, quantity, sale_date, sale_price, status) VALUES
(1, 4, 5, 200, '2026-01-20', 25.50, 1),
(2, 4, 5, 150, '2026-01-21', 32.80, 1),
(3, 5, 6, 300, '2026-01-22', 18.50, 1),
(4, 4, 5, 100, '2026-01-23', 45.20, 1),
(5, 5, 6, 200, '2026-01-24', 68.50, 1);

INSERT INTO adverse_reaction (drug_id, patient_name, reaction_description, severity, hospital, doctor_name, reporter_id, status, created_at) VALUES
(1, 'Zhang San', 'Rash and itching after taking', 'Mild', 'First People''s Hospital', 'Dr. Li', 5, 1, '2026-01-25 10:30:00'),
(2, 'Li Si', 'Stomach discomfort and nausea', 'Moderate', 'Second People''s Hospital', 'Dr. Wang', 5, 1, '2026-01-26 14:20:00'),
(3, 'Wang Wu', 'Dizziness and fatigue', 'Mild', 'Third People''s Hospital', 'Dr. Zhao', 5, 1, '2026-01-27 09:15:00');

INSERT INTO usage_record (drug_id, patient_name, dosage, frequency, usage_date, doctor_id, hospital, status) VALUES
(1, 'Zhang San', '0.5g', '3 times/day', '2026-01-20', 5, 'First People''s Hospital', 1),
(2, 'Li Si', '0.3g', '2 times/day', '2026-01-21', 5, 'Second People''s Hospital', 1),
(3, 'Wang Wu', '0.5g', '2 times/day', '2026-01-22', 5, 'Third People''s Hospital', 1),
(4, 'Zhao Liu', '10mg', '1 time/day', '2026-01-23', 5, 'First People''s Hospital', 1),
(5, 'Qian Qi', '20mg', '1 time/day', '2026-01-24', 5, 'Second People''s Hospital', 1),
(6, 'Sun Ba', '0.5g', '2 times/day', '2026-01-25', 5, 'Third People''s Hospital', 1),
(7, 'Zhou Jiu', '2 puffs', '2 times/day', '2026-01-26', 5, 'First People''s Hospital', 1),
(8, 'Wu Shi', '0.1g', '3 times/day', '2026-01-27', 5, 'Second People''s Hospital', 1),
(9, 'Zheng Shiyi', '1 tablet', '3 times/day', '2026-01-28', 5, 'Third People''s Hospital', 1),
(10, 'Wang Shier', '1 bag', '2 times/day', '2026-01-29', 5, 'First People''s Hospital', 1);

INSERT INTO trace_record (drug_code, batch_number, trace_step, step_time, organization, description, status) VALUES
('D001', 'B001', 'Raw Material Procurement', '2026-01-01 08:00:00', 'Raw Material Supplier', 'Raw material procurement completed', 1),
('D001', 'B001', 'Production Processing', '2026-01-02 10:30:00', 'North China Pharma Factory', 'Production processing completed', 1),
('D001', 'B001', 'Quality Inspection', '2026-01-03 14:00:00', 'Quality Inspection Department', 'Quality inspection passed', 1),
('D001', 'B001', 'Packaging and Warehousing', '2026-01-04 16:00:00', 'Warehouse Department', 'Packaging and warehousing completed', 1),
('D001', 'B001', 'Logistics Distribution', '2026-01-05 09:00:00', 'Logistics Company', 'Shipped to medicine company', 1),
('D001', 'B001', 'Pharmacy Sale', '2026-01-20 15:00:00', 'Kangjian Pharmacy', 'Sold to patient', 1),
('D002', 'B002', 'Raw Material Procurement', '2026-01-02 08:00:00', 'Raw Material Supplier', 'Raw material procurement completed', 1),
('D002', 'B002', 'Production Processing', '2026-01-03 10:30:00', 'SmithKline Factory', 'Production processing completed', 1),
('D002', 'B002', 'Quality Inspection', '2026-01-04 14:00:00', 'Quality Inspection Department', 'Quality inspection passed', 1),
('D002', 'B002', 'Packaging and Warehousing', '2026-01-05 16:00:00', 'Warehouse Department', 'Packaging and warehousing completed', 1),
('D002', 'B002', 'Logistics Distribution', '2026-01-06 09:00:00', 'Logistics Company', 'Shipped to medicine company', 1),
('D002', 'B002', 'Pharmacy Sale', '2026-01-21 10:00:00', 'Kangjian Pharmacy', 'Sold to patient', 1),
('D003', 'B003', 'Raw Material Procurement', '2026-01-03 08:00:00', 'Raw Material Supplier', 'Raw material procurement completed', 1),
('D003', 'B003', 'Production Processing', '2026-01-04 10:30:00', 'Johnson & Johnson Factory', 'Production processing completed', 1),
('D003', 'B003', 'Quality Inspection', '2026-01-05 14:00:00', 'Quality Inspection Department', 'Quality inspection passed', 1),
('D003', 'B003', 'Packaging and Warehousing', '2026-01-06 16:00:00', 'Warehouse Department', 'Packaging and warehousing completed', 1),
('D003', 'B003', 'Logistics Distribution', '2026-01-07 09:00:00', 'Logistics Company', 'Shipped to medicine company', 1),
('D003', 'B003', 'Pharmacy Sale', '2026-01-22 11:00:00', 'Kangjian Pharmacy', 'Sold to patient', 1),
('D004', 'B004', 'Raw Material Procurement', '2026-01-04 08:00:00', 'Raw Material Supplier', 'Raw material procurement completed', 1),
('D004', 'B004', 'Production Processing', '2026-01-05 10:30:00', 'Bayer Factory', 'Production processing completed', 1),
('D004', 'B004', 'Quality Inspection', '2026-01-06 14:00:00', 'Quality Inspection Department', 'Quality inspection passed', 1),
('D004', 'B004', 'Packaging and Warehousing', '2026-01-07 16:00:00', 'Warehouse Department', 'Packaging and warehousing completed', 1),
('D004', 'B004', 'Logistics Distribution', '2026-01-08 09:00:00', 'Logistics Company', 'Shipped to medicine company', 1),
('D004', 'B004', 'Pharmacy Sale', '2026-01-23 12:00:00', 'Kangjian Pharmacy', 'Sold to patient', 1),
('D005', 'B005', 'Raw Material Procurement', '2026-01-05 08:00:00', 'Raw Material Supplier', 'Raw material procurement completed', 1),
('D005', 'B005', 'Production Processing', '2026-01-06 10:30:00', 'AstraZeneca Factory', 'Production processing completed', 1),
('D005', 'B005', 'Quality Inspection', '2026-01-07 14:00:00', 'Quality Inspection Department', 'Quality inspection passed', 1),
('D005', 'B005', 'Packaging and Warehousing', '2026-01-08 16:00:00', 'Warehouse Department', 'Packaging and warehousing completed', 1),
('D005', 'B005', 'Logistics Distribution', '2026-01-09 09:00:00', 'Logistics Company', 'Shipped to medicine company', 1),
('D005', 'B005', 'Pharmacy Sale', '2026-01-24 13:00:00', 'Kangjian Pharmacy', 'Sold to patient', 1);
