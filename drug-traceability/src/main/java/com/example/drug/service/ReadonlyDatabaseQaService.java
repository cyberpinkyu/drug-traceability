package com.example.drug.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class ReadonlyDatabaseQaService {

    private static final int DEFAULT_LIMIT = 10;
    private static final Pattern BATCH_PATTERN = Pattern.compile("\\bB\\d{6}[A-Z]?\\b", Pattern.CASE_INSENSITIVE);
    private static final Pattern DRUG_CODE_PATTERN = Pattern.compile("\\bRX\\d{6}\\b", Pattern.CASE_INSENSITIVE);

    private final JdbcTemplate jdbcTemplate;

    public ReadonlyDatabaseQaService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public DbAnswerContext resolve(String question) {
        String normalized = normalize(question);
        if (normalized.isEmpty()) {
            return new DbAnswerContext("general", "未识别到明确问题。", new ArrayList<Map<String, Object>>());
        }

        String batchNumber = extract(BATCH_PATTERN, question);
        if (!batchNumber.isEmpty()) {
            return traceByBatch(batchNumber);
        }

        String drugCode = extract(DRUG_CODE_PATTERN, question);
        if (!drugCode.isEmpty()) {
            return drugByCode(drugCode);
        }

        if (containsAny(normalized, "库存", "存量", "余量")) {
            return inventoryOverview(question);
        }

        if (containsAny(normalized, "风险", "不良反应", "预警")) {
            return riskOverview(question);
        }

        if (containsAny(normalized, "批号", "批次", "追溯码", "追溯")) {
            return latestTraceOverview();
        }

        if (containsAny(normalized, "药品", "阿莫西林", "布洛芬", "用途", "说明")) {
            return drugLookup(question);
        }

        return generalDrugList();
    }

    public String toPromptBlock(DbAnswerContext context) {
        StringBuilder builder = new StringBuilder();
        builder.append("数据库只读工具结果:\n");
        builder.append("intent: ").append(context.getIntent()).append('\n');
        builder.append("summary: ").append(context.getSummary()).append('\n');
        builder.append("rows:\n");
        if (context.getRows().isEmpty()) {
          builder.append("- none\n");
        } else {
          for (int i = 0; i < context.getRows().size(); i++) {
              builder.append(i + 1).append(". ").append(context.getRows().get(i)).append('\n');
          }
        }
        builder.append("请严格基于这些事实回答；如果事实不足，要明确说明无法从数据库确认。");
        return builder.toString().trim();
    }

    private DbAnswerContext traceByBatch(String batchNumber) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT pb.batch_number, di.drug_code, di.name AS drug_name, pb.production_date, pb.expiry_date, " +
                "pb.production_quantity, producer.organization AS producer_name " +
                "FROM production_batch pb " +
                "LEFT JOIN drug_info di ON di.id = pb.drug_id " +
                "LEFT JOIN user producer ON producer.id = pb.producer_id " +
                "WHERE pb.batch_number = ? LIMIT " + DEFAULT_LIMIT,
            batchNumber.toUpperCase(Locale.ROOT)
        );
        return new DbAnswerContext("trace_by_batch", "按批号查询追溯批次信息", rows);
    }

    private DbAnswerContext drugByCode(String drugCode) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT drug_code, name, specification, manufacturer, approval_number, category, unit, price, status " +
                "FROM drug_info WHERE drug_code = ? LIMIT " + DEFAULT_LIMIT,
            drugCode.toUpperCase(Locale.ROOT)
        );
        return new DbAnswerContext("drug_by_code", "按药品编码查询药品基础信息", rows);
    }

    private DbAnswerContext inventoryOverview(String question) {
        String keyword = findDrugKeyword(question);
        List<Map<String, Object>> rows;
        if (!keyword.isEmpty()) {
            rows = jdbcTemplate.queryForList(
                "SELECT di.name AS drug_name, pb.batch_number, i.quantity, i.last_update_date, u.organization AS organization_name " +
                    "FROM inventory i " +
                    "LEFT JOIN production_batch pb ON pb.id = i.batch_id " +
                    "LEFT JOIN drug_info di ON di.id = pb.drug_id " +
                    "LEFT JOIN user u ON u.id = i.organization_id " +
                    "WHERE di.name LIKE ? OR di.drug_code LIKE ? " +
                    "ORDER BY i.last_update_date DESC LIMIT " + DEFAULT_LIMIT,
                "%" + keyword + "%",
                "%" + keyword + "%"
            );
        } else {
            rows = jdbcTemplate.queryForList(
                "SELECT di.name AS drug_name, pb.batch_number, i.quantity, i.last_update_date, u.organization AS organization_name " +
                    "FROM inventory i " +
                    "LEFT JOIN production_batch pb ON pb.id = i.batch_id " +
                    "LEFT JOIN drug_info di ON di.id = pb.drug_id " +
                    "LEFT JOIN user u ON u.id = i.organization_id " +
                    "ORDER BY i.last_update_date DESC LIMIT " + DEFAULT_LIMIT
            );
        }
        return new DbAnswerContext("inventory", "查询库存与组织分布信息", rows);
    }

    private DbAnswerContext riskOverview(String question) {
        String keyword = findDrugKeyword(question);
        List<Map<String, Object>> rows;
        if (!keyword.isEmpty()) {
            rows = jdbcTemplate.queryForList(
                "SELECT di.name AS drug_name, ar.severity, ar.hospital, ar.reaction_description, ar.created_at " +
                    "FROM adverse_reaction ar " +
                    "LEFT JOIN drug_info di ON di.id = ar.drug_id " +
                    "WHERE di.name LIKE ? OR di.drug_code LIKE ? " +
                    "ORDER BY ar.created_at DESC LIMIT " + DEFAULT_LIMIT,
                "%" + keyword + "%",
                "%" + keyword + "%"
            );
        } else {
            rows = jdbcTemplate.queryForList(
                "SELECT di.name AS drug_name, ar.severity, ar.hospital, ar.reaction_description, ar.created_at " +
                    "FROM adverse_reaction ar " +
                    "LEFT JOIN drug_info di ON di.id = ar.drug_id " +
                    "ORDER BY ar.created_at DESC LIMIT " + DEFAULT_LIMIT
            );
        }
        return new DbAnswerContext("risk", "查询不良反应与风险相关记录", rows);
    }

    private DbAnswerContext latestTraceOverview() {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT pb.batch_number, di.name AS drug_name, pb.production_date, pb.expiry_date, pb.production_quantity " +
                "FROM production_batch pb " +
                "LEFT JOIN drug_info di ON di.id = pb.drug_id " +
                "ORDER BY pb.production_date DESC LIMIT " + DEFAULT_LIMIT
        );
        return new DbAnswerContext("trace_overview", "查询最新批次追溯记录", rows);
    }

    private DbAnswerContext drugLookup(String question) {
        String keyword = findDrugKeyword(question);
        List<Map<String, Object>> rows;
        if (!keyword.isEmpty()) {
            rows = jdbcTemplate.queryForList(
                "SELECT drug_code, name, specification, manufacturer, approval_number, category, unit, price " +
                    "FROM drug_info WHERE name LIKE ? OR drug_code LIKE ? ORDER BY id DESC LIMIT " + DEFAULT_LIMIT,
                "%" + keyword + "%",
                "%" + keyword + "%"
            );
        } else {
            rows = jdbcTemplate.queryForList(
                "SELECT drug_code, name, specification, manufacturer, approval_number, category, unit, price " +
                    "FROM drug_info ORDER BY id DESC LIMIT " + DEFAULT_LIMIT
            );
        }
        return new DbAnswerContext("drug_lookup", "查询药品基础信息与说明相关数据", rows);
    }

    private DbAnswerContext generalDrugList() {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT drug_code, name, manufacturer, category, price FROM drug_info ORDER BY id DESC LIMIT " + DEFAULT_LIMIT
        );
        return new DbAnswerContext("general", "默认返回最近药品基础信息", rows);
    }

    private String findDrugKeyword(String question) {
        String[] knownKeywords = {
            "阿莫西林", "布洛芬", "二甲双胍", "氯雷他定", "头孢克肟", "奥美拉唑", "阿托伐他汀", "蒙脱石散", "左氧氟沙星", "缬沙坦"
        };
        for (String keyword : knownKeywords) {
            if (question.contains(keyword)) {
                return keyword;
            }
        }
        String code = extract(DRUG_CODE_PATTERN, question);
        if (!code.isEmpty()) {
            return code;
        }
        return "";
    }

    private String extract(Pattern pattern, String input) {
        if (input == null) {
            return "";
        }
        Matcher matcher = pattern.matcher(input);
        if (matcher.find()) {
            return matcher.group().trim();
        }
        return "";
    }

    private String normalize(String input) {
        return input == null ? "" : input.trim().toLowerCase(Locale.ROOT);
    }

    private boolean containsAny(String text, String... keywords) {
        return Arrays.stream(keywords).anyMatch(text::contains);
    }

    public static class DbAnswerContext {
        private final String intent;
        private final String summary;
        private final List<Map<String, Object>> rows;

        public DbAnswerContext(String intent, String summary, List<Map<String, Object>> rows) {
            this.intent = intent;
            this.summary = summary;
            this.rows = rows == null ? new ArrayList<Map<String, Object>>() : rows;
        }

        public String getIntent() {
            return intent;
        }

        public String getSummary() {
            return summary;
        }

        public List<Map<String, Object>> getRows() {
            return rows;
        }
    }
}
