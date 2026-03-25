CREATE DATABASE IF NOT EXISTS drug_traceability CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE drug_traceability;

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

CREATE TABLE IF NOT EXISTS `ai_conversation` (
  `conversation_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT(20) NOT NULL,
  `title` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE IF NOT EXISTS `ai_knowledge_doc` (
  `doc_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `content` TEXT NOT NULL,
  `embedding_vector` BLOB,
  `source` VARCHAR(200),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`doc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE IF NOT EXISTS `adverse_reaction` (
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

CREATE TABLE IF NOT EXISTS `usage_record` (
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

CREATE TABLE IF NOT EXISTS `trace_record` (
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

CREATE TABLE IF NOT EXISTS `regulatory_enforcement` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `inspector_id` BIGINT(20),
  `organization_id` BIGINT(20),
  `inspection_type` VARCHAR(50),
  `inspection_result` VARCHAR(200),
  `description` VARCHAR(500),
  `inspection_date` DATETIME,
  `status` INT(11) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_inspector_id` (`inspector_id`),
  KEY `idx_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `regulatory_task` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `report_id` BIGINT(20) NOT NULL,
  `assignee_id` BIGINT(20) NOT NULL,
  `suspected_source` VARCHAR(30),
  `suspected_org_id` BIGINT(20),
  `conclusion_source` VARCHAR(30),
  `conclusion_org_id` BIGINT(20),
  `verified` TINYINT(1) NOT NULL DEFAULT 0,
  `investigation_result` VARCHAR(1000),
  `status` INT(11) NOT NULL DEFAULT 1,
  `dispatched_at` DATETIME,
  `investigated_at` DATETIME,
  `enforced_at` DATETIME,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_report_id` (`report_id`),
  KEY `idx_assignee_id` (`assignee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `message_notice` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL,
  `content` TEXT NOT NULL,
  `channel` VARCHAR(20) NOT NULL DEFAULT 'site',
  `receiver_id` BIGINT(20),
  `receiver_contact` VARCHAR(100),
  `biz_type` VARCHAR(50),
  `biz_id` BIGINT(20),
  `status` INT(11) NOT NULL DEFAULT 0,
  `sent_at` DATETIME,
  `read_at` DATETIME,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_receiver_id` (`receiver_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `alert_ticket` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL,
  `source_type` VARCHAR(50),
  `source_id` BIGINT(20),
  `severity` VARCHAR(20) NOT NULL DEFAULT 'medium',
  `status` INT(11) NOT NULL DEFAULT 0,
  `assignee_id` BIGINT(20),
  `description` VARCHAR(1000),
  `closed_result` VARCHAR(1000),
  `closed_at` DATETIME,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_assignee_id` (`assignee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `scan_log` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `trace_code` VARCHAR(100) NOT NULL,
  `device_id` VARCHAR(100),
  `signature` VARCHAR(256),
  `request_ts` BIGINT(20),
  `verify_passed` TINYINT(1) NOT NULL DEFAULT 0,
  `offline_flag` TINYINT(1) NOT NULL DEFAULT 0,
  `source_ip` VARCHAR(64),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_trace_code` (`trace_code`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
