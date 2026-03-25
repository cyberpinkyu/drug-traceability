package com.example.drug.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.drug.common.RequireRole;
import com.example.drug.common.UserContext;
import com.example.drug.entity.AdverseReaction;
import com.example.drug.entity.AlertTicket;
import com.example.drug.entity.DrugInfo;
import com.example.drug.entity.Inventory;
import com.example.drug.entity.MessageNotice;
import com.example.drug.entity.ProcurementRecord;
import com.example.drug.entity.ProductionBatch;
import com.example.drug.entity.SaleRecord;
import com.example.drug.entity.ScanLog;
import com.example.drug.entity.User;
import com.example.drug.service.AdverseReactionService;
import com.example.drug.service.AlertTicketService;
import com.example.drug.service.DrugInfoService;
import com.example.drug.service.InventoryService;
import com.example.drug.service.MessageNoticeService;
import com.example.drug.service.ProcurementRecordService;
import com.example.drug.service.ProductionBatchService;
import com.example.drug.service.SaleRecordService;
import com.example.drug.service.ScanLogService;
import com.example.drug.service.UserService;
import com.example.drug.utils.MapUtils;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@RestController
@RequestMapping("/feature")
public class FeatureController {

    @Autowired
    private ProductionBatchService productionBatchService;
    @Autowired
    private ProcurementRecordService procurementRecordService;
    @Autowired
    private SaleRecordService saleRecordService;
    @Autowired
    private InventoryService inventoryService;
    @Autowired
    private AdverseReactionService adverseReactionService;
    @Autowired
    private MessageNoticeService messageNoticeService;
    @Autowired
    private AlertTicketService alertTicketService;
    @Autowired
    private ScanLogService scanLogService;
    @Autowired
    private UserService userService;
    @Autowired
    private DrugInfoService drugInfoService;

    @Value("${trace.scan.secret:trace-sign-secret}")
    private String scanSecret;

    @Value("${trace.scan.allow-sign-endpoint:false}")
    private boolean allowScanSignEndpoint;

    @GetMapping("/trace/graph/{batchId}")
    public Map<String, Object> getTraceGraph(@PathVariable Long batchId) {
        ProductionBatch batch = productionBatchService.getById(batchId);
        if (batch == null) {
            return MapUtils.of("code", 404, "message", "batch not found");
        }

        List<Map<String, Object>> nodes = new ArrayList<>();
        List<Map<String, Object>> edges = new ArrayList<>();

        Map<String, Object> batchNode = new HashMap<String, Object>();
        batchNode.put("id", "batch-" + batch.getId());
        batchNode.put("type", "batch");
        batchNode.put("label", batch.getBatchNumber());
        batchNode.put("abnormal", isBatchExpired(batch));
        nodes.add(batchNode);

        User producer = userService.getById(batch.getProducerId());
        if (producer != null) {
            Map<String, Object> producerNode = orgNode(producer.getId(), producer.getName(), "producer", false);
            nodes.add(producerNode);
            edges.add(edge("org-" + producer.getId(), "batch-" + batch.getId(), "produced"));
        }

        List<ProcurementRecord> procurementList = procurementRecordService.getRecordsByBatchId(batchId);
        for (ProcurementRecord p : procurementList) {
            boolean abnormal = p.getQuantity() == null || p.getQuantity() <= 0;
            User supplier = userService.getById(p.getSupplierId());
            User buyer = userService.getById(p.getBuyerId());
            if (supplier != null) {
                nodes.add(orgNode(supplier.getId(), supplier.getName(), "supplier", abnormal));
            }
            if (buyer != null) {
                nodes.add(orgNode(buyer.getId(), buyer.getName(), "buyer", abnormal));
            }
            edges.add(edge("org-" + p.getSupplierId(), "org-" + p.getBuyerId(), "procurement:" + p.getQuantity()));
        }

        List<SaleRecord> saleList = saleRecordService.getRecordsByBatchId(batchId);
        for (SaleRecord s : saleList) {
            boolean abnormal = s.getQuantity() == null || s.getQuantity() <= 0;
            User seller = userService.getById(s.getSellerId());
            User buyer = userService.getById(s.getBuyerId());
            if (seller != null) {
                nodes.add(orgNode(seller.getId(), seller.getName(), "seller", abnormal));
            }
            if (buyer != null) {
                nodes.add(orgNode(buyer.getId(), buyer.getName(), "buyer", abnormal));
            }
            edges.add(edge("org-" + s.getSellerId(), "org-" + s.getBuyerId(), "sale:" + s.getQuantity()));
        }

        List<Inventory> inventoryList = inventoryService.getInventoriesByBatchId(batchId);
        for (Inventory inv : inventoryList) {
            boolean abnormal = inv.getQuantity() != null && inv.getQuantity() < 0;
            edges.add(edge("batch-" + batchId, "org-" + inv.getOrganizationId(), "inventory:" + inv.getQuantity()));
            nodes.add(orgNode(inv.getOrganizationId(), "Org" + inv.getOrganizationId(), "inventoryHolder", abnormal));
        }

        List<AdverseReaction> reactions = adverseReactionService.list(
            new QueryWrapper<AdverseReaction>().eq("drug_id", batch.getDrugId())
        );
        int highRiskCount = 0;
        for (AdverseReaction reaction : reactions) {
            if ("high".equalsIgnoreCase(reaction.getSeverity())) {
                highRiskCount++;
            }
        }

        Map<String, Object> summary = new HashMap<String, Object>();
        summary.put("highRiskReactionCount", highRiskCount);
        summary.put("nodeCount", nodes.size());
        summary.put("edgeCount", edges.size());
        summary.put("abnormal", isBatchExpired(batch) || highRiskCount > 0);

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("nodes", deduplicateNodes(nodes));
        data.put("edges", edges);
        data.put("summary", summary);
        return MapUtils.of("code", 200, "data", data);
    }

    @GetMapping("/reports/drilldown")
    public Map<String, Object> drilldown(
        @RequestParam(defaultValue = "time") String dimension,
        @RequestParam(required = false) String startDate,
        @RequestParam(required = false) String endDate,
        @RequestParam(required = false) Long organizationId,
        @RequestParam(required = false) Long batchId
    ) {
        LocalDate start = StringUtils.hasText(startDate) ? LocalDate.parse(startDate) : LocalDate.now().minusMonths(6);
        LocalDate end = StringUtils.hasText(endDate) ? LocalDate.parse(endDate) : LocalDate.now();

        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        if ("batch".equalsIgnoreCase(dimension)) {
            for (ProductionBatch batch : productionBatchService.list()) {
                if (batchId != null && !batchId.equals(batch.getId())) {
                    continue;
                }
                Map<String, Object> row = new HashMap<String, Object>();
                row.put("key", batch.getBatchNumber());
                row.put("productionQuantity", batch.getProductionQuantity());
                row.put("procurementCount", procurementRecordService.count(new QueryWrapper<ProcurementRecord>().eq("batch_id", batch.getId())));
                row.put("saleCount", saleRecordService.count(new QueryWrapper<SaleRecord>().eq("batch_id", batch.getId())));
                row.put("inventoryOrgCount", inventoryService.count(new QueryWrapper<Inventory>().eq("batch_id", batch.getId())));
                rows.add(row);
            }
        } else if ("enterprise".equalsIgnoreCase(dimension) || "region".equalsIgnoreCase(dimension)) {
            Map<Long, Map<String, Object>> bucket = new LinkedHashMap<Long, Map<String, Object>>();
            for (Inventory inventory : inventoryService.list()) {
                if (organizationId != null && !organizationId.equals(inventory.getOrganizationId())) {
                    continue;
                }
                Map<String, Object> row = bucket.get(inventory.getOrganizationId());
                if (row == null) {
                    row = new HashMap<String, Object>();
                    User org = userService.getById(inventory.getOrganizationId());
                    row.put("key", inventory.getOrganizationId());
                    row.put("name", org == null ? "Unknown" : org.getName());
                    row.put("organization", org == null ? "Unknown" : org.getOrganization());
                    row.put("inventoryTotal", 0L);
                    row.put("batchCount", 0L);
                    bucket.put(inventory.getOrganizationId(), row);
                }
                long oldInv = ((Number) row.get("inventoryTotal")).longValue();
                long oldBatch = ((Number) row.get("batchCount")).longValue();
                row.put("inventoryTotal", oldInv + (inventory.getQuantity() == null ? 0 : inventory.getQuantity()));
                row.put("batchCount", oldBatch + 1);
            }
            rows.addAll(bucket.values());
        } else {
            Map<YearMonth, Long> productionByMonth = new LinkedHashMap<YearMonth, Long>();
            long months = ChronoUnit.MONTHS.between(YearMonth.from(start), YearMonth.from(end));
            for (int i = 0; i <= months; i++) {
                YearMonth ym = YearMonth.from(start).plusMonths(i);
                productionByMonth.put(ym, 0L);
            }
            for (ProductionBatch batch : productionBatchService.list()) {
                if (batch.getProductionDate() == null) {
                    continue;
                }
                if (batch.getProductionDate().isBefore(start) || batch.getProductionDate().isAfter(end)) {
                    continue;
                }
                YearMonth ym = YearMonth.from(batch.getProductionDate());
                long old = productionByMonth.containsKey(ym) ? productionByMonth.get(ym) : 0L;
                productionByMonth.put(ym, old + (batch.getProductionQuantity() == null ? 0 : batch.getProductionQuantity()));
            }
            for (Map.Entry<YearMonth, Long> e : productionByMonth.entrySet()) {
                Map<String, Object> row = new HashMap<String, Object>();
                row.put("key", e.getKey().toString());
                row.put("productionQuantity", e.getValue());
                rows.add(row);
            }
        }

        Map<String, Object> summary = new HashMap<String, Object>();
        summary.put("dimension", dimension);
        summary.put("from", start.toString());
        summary.put("to", end.toString());
        summary.put("count", rows.size());
        return MapUtils.of("code", 200, "data", rows, "summary", summary);
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/messages")
    public Map<String, Object> listMessages(@RequestParam(required = false) Long receiverId) {
        Long currentUserId = UserContext.getCurrentUserId();
        String roleCode = UserContext.getCurrentUser() == null ? null : UserContext.getCurrentUser().getRoleCode();

        QueryWrapper<MessageNotice> qw = new QueryWrapper<MessageNotice>();
        if (isAdmin(roleCode)) {
            if (receiverId != null) {
                qw.eq("receiver_id", receiverId);
            }
        } else {
            qw.eq("receiver_id", currentUserId);
        }
        qw.orderByDesc("created_at");
        return MapUtils.of("code", 200, "data", messageNoticeService.list(qw));
    }

    @RequireRole({"admin", "regulator"})
    @PostMapping("/messages")
    public Map<String, Object> sendMessage(@RequestBody MessageNotice message) {
        message.setStatus(0);
        message.setSentAt(LocalDateTime.now());
        boolean ok = messageNoticeService.save(message);
        return ok ? MapUtils.of("code", 200, "message", "sent", "data", message)
            : MapUtils.of("code", 500, "message", "send failed");
    }

    @RequireRole({"admin", "regulator"})
    @PutMapping("/messages/{id}/read")
    public Map<String, Object> readMessage(@PathVariable Long id) {
        MessageNotice notice = messageNoticeService.getById(id);
        if (notice == null) {
            return MapUtils.of("code", 404, "message", "not found");
        }

        Long currentUserId = UserContext.getCurrentUserId();
        String roleCode = UserContext.getCurrentUser() == null ? null : UserContext.getCurrentUser().getRoleCode();
        if (!isAdmin(roleCode) && (notice.getReceiverId() == null || !notice.getReceiverId().equals(currentUserId))) {
            return MapUtils.of("code", 403, "message", "forbidden");
        }

        notice.setStatus(1);
        notice.setReadAt(LocalDateTime.now());
        messageNoticeService.updateById(notice);
        return MapUtils.of("code", 200, "message", "ok");
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/tickets")
    public Map<String, Object> listTickets() {
        QueryWrapper<AlertTicket> qw = new QueryWrapper<AlertTicket>().orderByDesc("created_at");
        String roleCode = UserContext.getCurrentUser() == null ? null : UserContext.getCurrentUser().getRoleCode();
        if (!isAdmin(roleCode)) {
            Long uid = UserContext.getCurrentUserId();
            qw.and(w -> w.eq("assignee_id", uid).or().isNull("assignee_id"));
        }
        return MapUtils.of("code", 200, "data", alertTicketService.list(qw));
    }

    @RequireRole({"admin", "regulator"})
    @PostMapping("/tickets")
    public Map<String, Object> createTicket(@RequestBody AlertTicket ticket) {
        ticket.setStatus(0);
        boolean ok = alertTicketService.save(ticket);
        return ok ? MapUtils.of("code", 200, "message", "created", "data", ticket)
            : MapUtils.of("code", 500, "message", "create failed");
    }

    @RequireRole({"admin", "regulator"})
    @PutMapping("/tickets/{id}/assign")
    public Map<String, Object> assignTicket(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        AlertTicket ticket = alertTicketService.getById(id);
        if (ticket == null) {
            return MapUtils.of("code", 404, "message", "not found");
        }
        Number assigneeId = (Number) payload.get("assigneeId");
        ticket.setAssigneeId(assigneeId == null ? null : assigneeId.longValue());
        ticket.setStatus(1);
        alertTicketService.updateById(ticket);
        return MapUtils.of("code", 200, "message", "assigned", "data", ticket);
    }

    @RequireRole({"admin", "regulator"})
    @PutMapping("/tickets/{id}/close")
    public Map<String, Object> closeTicket(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        AlertTicket ticket = alertTicketService.getById(id);
        if (ticket == null) {
            return MapUtils.of("code", 404, "message", "not found");
        }
        ticket.setClosedResult((String) payload.get("closedResult"));
        ticket.setClosedAt(LocalDateTime.now());
        ticket.setStatus(2);
        alertTicketService.updateById(ticket);
        return MapUtils.of("code", 200, "message", "closed", "data", ticket);
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/scan/sign")
    public Map<String, Object> signPayload(@RequestParam String traceCode, @RequestParam Long ts) {
        if (!allowScanSignEndpoint) {
            return MapUtils.of("code", 403, "message", "sign endpoint disabled");
        }
        String signature = sign(traceCode + "|" + ts);
        return MapUtils.of("code", 200, "data", MapUtils.of("signature", signature));
    }

    @PostMapping("/scan/verify")
    public Map<String, Object> verifyScan(@RequestBody Map<String, Object> payload, HttpServletRequest request) {
        String traceCode = payload.get("traceCode") == null ? "" : payload.get("traceCode").toString();
        String signature = payload.get("signature") == null ? "" : payload.get("signature").toString();
        Long requestTs = payload.get("ts") instanceof Number ? ((Number) payload.get("ts")).longValue() : System.currentTimeMillis();
        String deviceId = payload.get("deviceId") == null ? "unknown" : payload.get("deviceId").toString();
        int offline = payload.get("offline") instanceof Boolean && (Boolean) payload.get("offline") ? 1 : 0;

        String expected = sign(traceCode + "|" + requestTs);
        boolean valid = expected.equalsIgnoreCase(signature) && Math.abs(System.currentTimeMillis() - requestTs) < 24 * 60 * 60 * 1000L;

        ScanLog log = new ScanLog();
        log.setTraceCode(traceCode);
        log.setSignature(signature);
        log.setRequestTs(requestTs);
        log.setDeviceId(deviceId);
        log.setVerifyPassed(valid ? 1 : 0);
        log.setOfflineFlag(offline);
        log.setSourceIp(request.getRemoteAddr());
        scanLogService.save(log);

        ProductionBatch batch = productionBatchService.getBatchByNumber(traceCode);
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("valid", valid);
        data.put("traceFound", batch != null);
        data.put("serverSignature", expected);
        data.put("batchId", batch == null ? null : batch.getId());
        return MapUtils.of("code", 200, "data", data);
    }

    @RequireRole({"admin", "regulator"})
    @GetMapping("/scan/logs")
    public Map<String, Object> scanLogs() {
        return MapUtils.of("code", 200, "data", scanLogService.list(new QueryWrapper<ScanLog>().orderByDesc("created_at")));
    }

    @RequireRole({"admin", "producer", "enterprise", "institution"})
    @PostMapping("/data/import/drug")
    public Map<String, Object> importDrug(@RequestParam("file") MultipartFile file) throws IOException {
        String filename = file.getOriginalFilename() == null ? "" : file.getOriginalFilename().toLowerCase(Locale.ROOT);
        List<Map<String, Object>> rows;
        if (filename.endsWith(".csv")) {
            rows = readCsvRows(file.getBytes());
        } else if (filename.endsWith(".xlsx")) {
            rows = readXlsxRows(file.getBytes());
        } else {
            return MapUtils.of("code", 400, "message", "only csv/xlsx");
        }

        List<String> errors = new ArrayList<String>();
        int success = 0;
        for (int i = 0; i < rows.size(); i++) {
            Map<String, Object> row = rows.get(i);
            String rowNo = "row " + (i + 2);
            String drugCode = str(row.get("drug_code"));
            String name = str(row.get("name"));
            if (!StringUtils.hasText(drugCode) || !StringUtils.hasText(name)) {
                errors.add(rowNo + ": drug_code/name required");
                continue;
            }
            DrugInfo info = drugInfoService.getOne(new QueryWrapper<DrugInfo>().eq("drug_code", drugCode));
            if (info == null) {
                info = new DrugInfo();
                info.setDrugCode(drugCode);
            }
            info.setName(name);
            info.setSpecification(str(row.get("specification")));
            info.setManufacturer(str(row.get("manufacturer")));
            info.setApprovalNumber(str(row.get("approval_number")));
            info.setCategory(str(row.get("category")));
            info.setUnit(str(row.get("unit")));
            String price = str(row.get("price"));
            if (StringUtils.hasText(price)) {
                try {
                    info.setPrice(new BigDecimal(price));
                } catch (Exception ex) {
                    errors.add(rowNo + ": invalid price");
                    continue;
                }
            }
            info.setStatus(parseInt(str(row.get("status")), 1));
            if (info.getId() == null) {
                drugInfoService.save(info);
            } else {
                drugInfoService.updateById(info);
            }
            success++;
        }

        Map<String, Object> receipt = new HashMap<String, Object>();
        receipt.put("total", rows.size());
        receipt.put("success", success);
        receipt.put("failed", rows.size() - success);
        receipt.put("errors", errors);
        return MapUtils.of("code", 200, "data", receipt);
    }

    @GetMapping("/data/template/drug")
    public ResponseEntity<byte[]> drugTemplate(@RequestParam(defaultValue = "csv") String format) throws IOException {
        if ("xlsx".equalsIgnoreCase(format)) {
            return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=drug_template.xlsx")
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(toXlsx(sampleDrugRows()));
        }
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=drug_template.csv")
            .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
            .body(toCsv(sampleDrugRows()).getBytes(StandardCharsets.UTF_8));
    }

    @GetMapping("/data/export/drug")
    public ResponseEntity<byte[]> exportDrug(@RequestParam(defaultValue = "csv") String format) throws IOException {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (DrugInfo d : drugInfoService.list()) {
            Map<String, Object> row = new LinkedHashMap<String, Object>();
            row.put("drug_code", d.getDrugCode());
            row.put("name", d.getName());
            row.put("specification", d.getSpecification());
            row.put("manufacturer", d.getManufacturer());
            row.put("approval_number", d.getApprovalNumber());
            row.put("category", d.getCategory());
            row.put("unit", d.getUnit());
            row.put("price", d.getPrice());
            row.put("status", d.getStatus());
            rows.add(row);
        }

        if ("xlsx".equalsIgnoreCase(format)) {
            return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=drug_export.xlsx")
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(toXlsx(rows));
        }
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=drug_export.csv")
            .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
            .body(toCsv(rows).getBytes(StandardCharsets.UTF_8));
    }

    private List<Map<String, Object>> sampleDrugRows() {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        Map<String, Object> one = new LinkedHashMap<String, Object>();
        one.put("drug_code", "DRUG-001");
        one.put("name", "Sample Drug");
        one.put("specification", "0.5g*24");
        one.put("manufacturer", "Demo Pharma");
        one.put("approval_number", "H20260001");
        one.put("category", "antibiotic");
        one.put("unit", "box");
        one.put("price", "18.50");
        one.put("status", 1);
        rows.add(one);
        return rows;
    }
    private List<Map<String, Object>> readCsvRows(byte[] bytes) throws IOException {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        BufferedReader reader = new BufferedReader(new InputStreamReader(new ByteArrayInputStream(bytes), StandardCharsets.UTF_8));
        String headerLine = reader.readLine();
        if (headerLine == null) {
            return rows;
        }

        if (!headerLine.isEmpty() && headerLine.charAt(0) == '\uFEFF') {
            headerLine = headerLine.substring(1);
        }

        List<String> headers = parseCsvLine(headerLine);
        String line;
        while ((line = reader.readLine()) != null) {
            if (!StringUtils.hasText(line)) {
                continue;
            }
            if (!line.isEmpty() && line.charAt(0) == '\uFEFF') {
                line = line.substring(1);
            }

            List<String> arr = parseCsvLine(line);
            Map<String, Object> row = new HashMap<String, Object>();
            for (int i = 0; i < headers.size(); i++) {
                String key = headers.get(i).trim().toLowerCase(Locale.ROOT);
                row.put(key, i < arr.size() ? arr.get(i).trim() : "");
            }
            rows.add(row);
        }
        return rows;
    }
    private List<Map<String, Object>> readXlsxRows(byte[] bytes) throws IOException {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        Workbook workbook = new XSSFWorkbook(new ByteArrayInputStream(bytes));
        Sheet sheet = workbook.getSheetAt(0);
        if (sheet == null || sheet.getPhysicalNumberOfRows() <= 0) {
            workbook.close();
            return rows;
        }
        Row headerRow = sheet.getRow(0);
        int headerCells = headerRow.getPhysicalNumberOfCells();
        List<String> headers = new ArrayList<String>();
        for (int i = 0; i < headerCells; i++) {
            headers.add(headerRow.getCell(i).getStringCellValue().trim().toLowerCase(Locale.ROOT));
        }
        for (int r = 1; r <= sheet.getLastRowNum(); r++) {
            Row rowData = sheet.getRow(r);
            if (rowData == null) {
                continue;
            }
            Map<String, Object> row = new HashMap<String, Object>();
            for (int c = 0; c < headers.size(); c++) {
                String v = rowData.getCell(c) == null ? "" : rowData.getCell(c).toString();
                row.put(headers.get(c), v.trim());
            }
            rows.add(row);
        }
        workbook.close();
        return rows;
    }
    private String toCsv(List<Map<String, Object>> rows) {
        if (rows.isEmpty()) {
            return "";
        }
        List<String> headers = new ArrayList<String>(rows.get(0).keySet());
        StringBuilder sb = new StringBuilder();
        sb.append(String.join(",", headers)).append("\n");
        for (Map<String, Object> row : rows) {
            List<String> values = new ArrayList<String>();
            for (String h : headers) {
                String v = row.get(h) == null ? "" : row.get(h).toString();
                values.add(escapeCsv(v));
            }
            sb.append(String.join(",", values)).append("\n");
        }
        return sb.toString();
    }

    private List<String> parseCsvLine(String line) {
        List<String> cells = new ArrayList<String>();
        StringBuilder current = new StringBuilder();
        boolean inQuotes = false;

        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == '"') {
                if (inQuotes && i + 1 < line.length() && line.charAt(i + 1) == '"') {
                    current.append('"');
                    i++;
                } else {
                    inQuotes = !inQuotes;
                }
            } else if (c == ',' && !inQuotes) {
                cells.add(current.toString());
                current.setLength(0);
            } else {
                current.append(c);
            }
        }
        cells.add(current.toString());
        return cells;
    }

    private String escapeCsv(String value) {
        String normalized = value == null ? "" : value;
        boolean needQuote = normalized.contains(",")
            || normalized.contains("\"")
            || normalized.contains("\n")
            || normalized.contains("\r");
        if (!needQuote) {
            return normalized;
        }
        return "\"" + normalized.replace("\"", "\"\"") + "\"";
    }

    private byte[] toXlsx(List<Map<String, Object>> rows) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("data");
        if (!rows.isEmpty()) {
            List<String> headers = new ArrayList<String>(rows.get(0).keySet());
            Row head = sheet.createRow(0);
            for (int i = 0; i < headers.size(); i++) {
                head.createCell(i).setCellValue(headers.get(i));
            }
            for (int r = 0; r < rows.size(); r++) {
                Row row = sheet.createRow(r + 1);
                for (int c = 0; c < headers.size(); c++) {
                    Object v = rows.get(r).get(headers.get(c));
                    row.createCell(c).setCellValue(v == null ? "" : v.toString());
                }
            }
        }
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        workbook.write(output);
        workbook.close();
        return output.toByteArray();
    }

    private String sign(String payload) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec keySpec = new SecretKeySpec(scanSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(keySpec);
            byte[] digest = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    private Map<String, Object> orgNode(Long orgId, String label, String type, boolean abnormal) {
        Map<String, Object> node = new HashMap<String, Object>();
        node.put("id", "org-" + orgId);
        node.put("type", type);
        node.put("label", label);
        node.put("abnormal", abnormal);
        return node;
    }

    private Map<String, Object> edge(String from, String to, String label) {
        Map<String, Object> edge = new HashMap<String, Object>();
        edge.put("from", from);
        edge.put("to", to);
        edge.put("label", label);
        return edge;
    }

    private boolean isBatchExpired(ProductionBatch batch) {
        return batch.getExpiryDate() != null && batch.getExpiryDate().isBefore(LocalDate.now());
    }

    private List<Map<String, Object>> deduplicateNodes(List<Map<String, Object>> nodes) {
        Map<String, Map<String, Object>> map = new LinkedHashMap<String, Map<String, Object>>();
        for (Map<String, Object> node : nodes) {
            String id = (String) node.get("id");
            if (!map.containsKey(id)) {
                map.put(id, node);
            } else if (Boolean.TRUE.equals(node.get("abnormal"))) {
                map.get(id).put("abnormal", true);
            }
        }
        return new ArrayList<Map<String, Object>>(map.values());
    }

    private boolean isAdmin(String roleCode) {
        return "admin".equals(roleCode) || "super_admin".equals(roleCode);
    }
    private String str(Object v) {
        return v == null ? "" : v.toString().trim();
    }

    private int parseInt(String text, int defaultValue) {
        try {
            return Integer.parseInt(text);
        } catch (Exception ex) {
            return defaultValue;
        }
    }
}




