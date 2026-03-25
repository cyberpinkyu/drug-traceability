USE drug_traceability;

INSERT INTO ai_conversation (user_id, title, created_at, updated_at) VALUES
(1, 'Drug Interaction Consultation', '2026-01-20 10:00:00', '2026-01-20 10:30:00'),
(2, 'Adverse Reaction Handling Advice', '2026-01-21 14:00:00', '2026-01-21 14:20:00'),
(3, 'Dosage Adjustment', '2026-01-22 09:00:00', '2026-01-22 09:15:00'),
(4, 'Drug Storage Methods', '2026-01-23 11:00:00', '2026-01-23 11:10:00'),
(5, 'Drug Side Effects Consultation', '2026-01-24 16:00:00', '2026-01-24 16:25:00');

INSERT INTO ai_message (conversation_id, role, content, created_at) VALUES
(1, 'user', 'Can I take Amoxicillin and Ibuprofen together', '2026-01-20 10:00:00'),
(1, 'assistant', 'Amoxicillin and Ibuprofen can generally be taken together, but it is recommended to space them at least 30 minutes apart. Amoxicillin is an antibiotic, and Ibuprofen is an analgesic and antipyretic, with no significant interactions.', '2026-01-20 10:05:00'),
(1, 'user', 'Is it better to take them before or after meals', '2026-01-20 10:10:00'),
(1, 'assistant', 'Amoxicillin is recommended to be taken after meals to reduce stomach discomfort, and Ibuprofen is also recommended to be taken after meals to avoid irritating the stomach lining.', '2026-01-20 10:15:00'),
(2, 'user', 'What should I do if I experience an adverse reaction', '2026-01-21 14:00:00'),
(2, 'assistant', 'If you experience an adverse reaction, stop taking the medication immediately and seek medical attention. Report the adverse reaction to the local drug adverse reaction monitoring center.', '2026-01-21 14:10:00'),
(3, 'user', 'How to adjust the dosage for elderly patients', '2026-01-22 09:00:00'),
(3, 'assistant', 'For elderly patients, it is recommended to start with a lower dose and gradually adjust based on the patient''s response and liver and kidney function. Consult a doctor for specific adjustments.', '2026-01-22 09:10:00'),
(4, 'user', 'How to store drugs properly', '2026-01-23 11:00:00'),
(4, 'assistant', 'Drugs should be stored in a cool, dry place away from direct sunlight. Most drugs should be stored below 25°C. Check the drug instructions for specific storage requirements.', '2026-01-23 11:05:00'),
(5, 'user', 'What are the common side effects of this drug', '2026-01-24 16:00:00'),
(5, 'assistant', 'Common side effects include nausea, vomiting, diarrhea, dizziness, etc. If side effects are severe or persistent, seek medical attention immediately.', '2026-01-24 16:20:00');

INSERT INTO ai_knowledge_doc (content, source, created_at) VALUES
('Amoxicillin is a broad-spectrum antibiotic belonging to the penicillin class. It is used to treat various bacterial infections such as respiratory tract infections, urinary tract infections, and skin infections. Common side effects include allergic reactions and gastrointestinal discomfort.', 'Drug Manual', '2026-01-15 10:00:00'),
('Ibuprofen is a non-steroidal anti-inflammatory drug (NSAID) used for fever reduction, pain relief, and anti-inflammatory effects. It is commonly used for headaches, toothaches, muscle pain, and joint pain. Long-term use may cause gastrointestinal ulcers.', 'Pharmacology Textbook', '2026-01-16 11:00:00'),
('Paracetamol is an analgesic and antipyretic drug. It has strong analgesic and antipyretic effects but weak anti-inflammatory effects. It is suitable for fever reduction and relief of mild to moderate pain. Overdose can cause liver damage.', 'Clinical Pharmacology', '2026-01-17 12:00:00'),
('Nifedipine is a calcium channel blocker used to treat hypertension and angina. It dilates blood vessels, reduces blood pressure, and improves myocardial blood supply. Common side effects include headache and facial flushing.', 'Cardiology Manual', '2026-01-18 13:00:00'),
('Omeprazole is a proton pump inhibitor that reduces gastric acid secretion. It is used to treat gastric ulcers, duodenal ulcers, and gastroesophageal reflux disease. Long-term use may affect calcium absorption.', 'Gastroenterology Manual', '2026-01-19 14:00:00');

INSERT INTO ai_tool_usage_log (tool_name, parameters, result, user_id, created_at) VALUES
('drug_interaction_check', '{"drug1":"Amoxicillin","drug2":"Ibuprofen"}', '{"compatible":true,"interaction":"None significant","recommendation":"Can be taken together with 30 minutes interval"}', 1, '2026-01-20 10:00:00'),
('adverse_reaction_report', '{"drug_id":1,"patient_name":"Zhang San","reaction":"Rash"}', '{"status":"Reported","report_id":"AR20260120001"}', 5, '2026-01-25 10:30:00'),
('drug_search', '{"keyword":"antibiotic"}', '{"results":[{"name":"Amoxicillin","code":"D001"},{"name":"Cefalexin","code":"D011"}]}', 2, '2026-01-21 14:00:00'),
('dosage_recommendation', '{"drug_id":1,"patient_age":65,"weight":70}' , '{"dosage":"0.5g","frequency":"2 times/day","adjustment":"Reduce dose for elderly"}', 3, '2026-01-22 09:00:00'),
('storage_advice', '{"drug_id":1}' , '{"storage":"Cool dry place below 25C","shelf_life":"24 months"}', 4, '2026-01-23 11:00:00');
