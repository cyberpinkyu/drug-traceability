USE drug_traceability;
SELECT 'user' as table_name, COUNT(*) as count FROM user
UNION ALL
SELECT 'role', COUNT(*) FROM role
UNION ALL
SELECT 'drug_info', COUNT(*) FROM drug_info
UNION ALL
SELECT 'production_batch', COUNT(*) FROM production_batch
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'procurement_record', COUNT(*) FROM procurement_record
UNION ALL
SELECT 'sale_record', COUNT(*) FROM sale_record
UNION ALL
SELECT 'adverse_reaction', COUNT(*) FROM adverse_reaction
UNION ALL
SELECT 'usage_record', COUNT(*) FROM usage_record
UNION ALL
SELECT 'trace_record', COUNT(*) FROM trace_record
UNION ALL
SELECT 'ai_conversation', COUNT(*) FROM ai_conversation
UNION ALL
SELECT 'ai_message', COUNT(*) FROM ai_message
UNION ALL
SELECT 'ai_knowledge_doc', COUNT(*) FROM ai_knowledge_doc
UNION ALL
SELECT 'ai_tool_usage_log', COUNT(*) FROM ai_tool_usage_log;
