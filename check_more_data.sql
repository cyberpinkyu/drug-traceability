USE drug_traceability;
SELECT COUNT(*) as batch_count FROM production_batch;
SELECT COUNT(*) as inventory_count FROM inventory;
SELECT COUNT(*) as procurement_count FROM procurement_record;
SELECT COUNT(*) as sale_count FROM sale_record;
SELECT COUNT(*) as adverse_count FROM adverse_reaction;
SELECT COUNT(*) as usage_count FROM usage_record;
SELECT COUNT(*) as trace_count FROM trace_record;
