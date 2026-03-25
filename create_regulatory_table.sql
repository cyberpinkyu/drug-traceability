USE drug_traceability;

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
