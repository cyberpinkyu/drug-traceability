package com.example.drug.interceptor;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.example.drug.common.UserContext;
import com.example.drug.entity.AuditOperationLog;
import com.example.drug.entity.User;
import com.example.drug.mapper.AlertTicketMapper;
import com.example.drug.mapper.AuditOperationLogMapper;
import com.example.drug.mapper.DrugInfoMapper;
import com.example.drug.mapper.InventoryMapper;
import com.example.drug.mapper.MessageNoticeMapper;
import com.example.drug.mapper.ProcurementRecordMapper;
import com.example.drug.mapper.ProductionBatchMapper;
import com.example.drug.mapper.RegulatoryEnforcementMapper;
import com.example.drug.mapper.RegulatoryTaskMapper;
import com.example.drug.mapper.SaleRecordMapper;
import com.example.drug.mapper.UserMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.util.ContentCachingRequestWrapper;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

@Slf4j
@Component
public class AuditLogInterceptor implements HandlerInterceptor {

    private static final String ATTR_TARGET = "audit.target";
    private static final String ATTR_TARGET_ID = "audit.targetId";
    private static final String ATTR_BEFORE = "audit.before";

    @Autowired
    private AuditOperationLogMapper auditOperationLogMapper;
    @Autowired
    private UserMapper userMapper;
    @Autowired
    private DrugInfoMapper drugInfoMapper;
    @Autowired
    private ProductionBatchMapper productionBatchMapper;
    @Autowired
    private ProcurementRecordMapper procurementRecordMapper;
    @Autowired
    private SaleRecordMapper saleRecordMapper;
    @Autowired
    private InventoryMapper inventoryMapper;
    @Autowired
    private RegulatoryEnforcementMapper regulatoryEnforcementMapper;
    @Autowired
    private RegulatoryTaskMapper regulatoryTaskMapper;
    @Autowired
    private MessageNoticeMapper messageNoticeMapper;
    @Autowired
    private AlertTicketMapper alertTicketMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (!isWriteMethod(request.getMethod())) {
            return true;
        }

        SnapshotTarget target = resolveTarget(request.getRequestURI());
        Long targetId = extractPrimaryId(request.getRequestURI());
        request.setAttribute(ATTR_TARGET, target == null ? null : target.type);
        request.setAttribute(ATTR_TARGET_ID, targetId);

        if (target != null && targetId != null) {
            Map<String, Object> before = entityToMap(target.load(targetId));
            request.setAttribute(ATTR_BEFORE, before);
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        String method = request.getMethod();
        if (!isWriteMethod(method)) {
            return;
        }

        User user = UserContext.getCurrentUser();
        Long actorId = user != null ? user.getId() : null;
        String actor = user != null ? user.getUsername() : "anonymous";
        String role = user != null ? user.getRoleCode() : "anonymous";
        Integer status = response.getStatus();
        String path = request.getRequestURI();

        try {
            String targetType = (String) request.getAttribute(ATTR_TARGET);
            Long targetId = (Long) request.getAttribute(ATTR_TARGET_ID);
            Map<String, Object> before = castMap(request.getAttribute(ATTR_BEFORE));
            Map<String, Object> requestBody = readRequestBodyAsMap(request);
            Map<String, Object> after = resolveAfterSnapshot(path, method, targetType, targetId, requestBody);
            Map<String, Object> diff = buildFieldDiff(before, after);

            AuditOperationLog record = new AuditOperationLog();
            record.setActorId(actorId);
            record.setActorUsername(cut(actor, 100));
            record.setActorRole(cut(role, 50));
            record.setMethod(cut(method, 10));
            record.setPath(cut(path, 300));
            record.setQueryString(cut(request.getQueryString(), 500));
            record.setStatusCode(status);
            record.setClientIp(cut(request.getRemoteAddr(), 64));
            record.setUserAgent(cut(request.getHeader("User-Agent"), 255));
            record.setTargetType(cut(targetType, 64));
            record.setTargetId(targetId);
            record.setRequestBody(cutJson(requestBody));
            record.setBeforeJson(cutJson(before));
            record.setAfterJson(cutJson(after));
            record.setDiffJson(cutJson(diff));
            record.setOccurredAt(LocalDateTime.now());
            auditOperationLogMapper.insert(record);

            log.info("AUDIT actorId={} actor={} role={} method={} path={} status={} target={}#{} diffFields={}",
                actorId, actor, role, method, path, status, targetType, targetId, diff == null ? 0 : diff.size());
        } catch (Exception persistEx) {
            log.warn("persist audit log failed: {}", persistEx.getMessage());
        }
    }

    private Map<String, Object> resolveAfterSnapshot(String path, String method, String targetType, Long targetId,
                                                     Map<String, Object> requestBody) {
        if ("DELETE".equalsIgnoreCase(method)) {
            return null;
        }
        if (StringUtils.hasText(targetType) && targetId != null) {
            SnapshotTarget target = resolveTarget(path);
            return target == null ? null : entityToMap(target.load(targetId));
        }
        return requestBody;
    }

    private Map<String, Object> readRequestBodyAsMap(HttpServletRequest request) {
        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase().contains("multipart/form-data")) {
            return null;
        }

        if (!(request instanceof ContentCachingRequestWrapper)) {
            return null;
        }

        byte[] bodyBytes = ((ContentCachingRequestWrapper) request).getContentAsByteArray();
        if (bodyBytes == null || bodyBytes.length == 0) {
            return null;
        }

        String body = new String(bodyBytes, StandardCharsets.UTF_8).trim();
        if (!StringUtils.hasText(body)) {
            return null;
        }

        try {
            Object obj = objectMapper.readValue(body, Object.class);
            if (obj instanceof Map) {
                return maskSensitive(castMap(obj));
            }
            Map<String, Object> wrapper = new LinkedHashMap<String, Object>();
            wrapper.put("value", obj);
            return wrapper;
        } catch (Exception ex) {
            Map<String, Object> wrapper = new LinkedHashMap<String, Object>();
            wrapper.put("raw", body);
            return wrapper;
        }
    }

    private Map<String, Object> buildFieldDiff(Map<String, Object> before, Map<String, Object> after) {
        Map<String, Object> oldMap = before == null ? Collections.<String, Object>emptyMap() : before;
        Map<String, Object> newMap = after == null ? Collections.<String, Object>emptyMap() : after;

        Set<String> keys = new LinkedHashSet<String>();
        keys.addAll(oldMap.keySet());
        keys.addAll(newMap.keySet());

        Map<String, Object> diff = new LinkedHashMap<String, Object>();
        for (String key : keys) {
            Object oldVal = oldMap.get(key);
            Object newVal = newMap.get(key);
            if (!Objects.equals(oldVal, newVal)) {
                Map<String, Object> node = new LinkedHashMap<String, Object>();
                node.put("before", oldVal);
                node.put("after", newVal);
                diff.put(key, node);
            }
        }
        return diff;
    }

    private SnapshotTarget resolveTarget(String path) {
        if (path == null) {
            return null;
        }
        if (path.startsWith("/auth/users")) {
            return new SnapshotTarget("user", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return userMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/drug/info")) {
            return new SnapshotTarget("drug_info", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return drugInfoMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/trace/batch")) {
            return new SnapshotTarget("production_batch", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return productionBatchMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/trace/procurement")) {
            return new SnapshotTarget("procurement_record", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return procurementRecordMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/trace/sale")) {
            return new SnapshotTarget("sale_record", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return saleRecordMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/trace/inventory")) {
            return new SnapshotTarget("inventory", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return inventoryMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/regulatory/enforcement")) {
            return new SnapshotTarget("regulatory_enforcement", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return regulatoryEnforcementMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/regulatory/tasks")) {
            return new SnapshotTarget("regulatory_task", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return regulatoryTaskMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/feature/messages")) {
            return new SnapshotTarget("message_notice", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return messageNoticeMapper.selectById(id);
                }
            });
        }
        if (path.startsWith("/feature/tickets")) {
            return new SnapshotTarget("alert_ticket", new SnapshotLoader() {
                @Override
                public Object load(Long id) {
                    return alertTicketMapper.selectById(id);
                }
            });
        }
        return null;
    }

    private Long extractPrimaryId(String path) {
        if (!StringUtils.hasText(path)) {
            return null;
        }
        String[] parts = path.split("/");
        for (int i = parts.length - 1; i >= 0; i--) {
            String p = parts[i];
            if (!StringUtils.hasText(p)) {
                continue;
            }
            if (isDigits(p)) {
                try {
                    return Long.valueOf(p);
                } catch (Exception ignore) {
                    return null;
                }
            }
        }
        return null;
    }

    private boolean isDigits(String text) {
        for (int i = 0; i < text.length(); i++) {
            if (!Character.isDigit(text.charAt(i))) {
                return false;
            }
        }
        return text.length() > 0;
    }

    private Map<String, Object> entityToMap(Object entity) {
        if (entity == null) {
            return null;
        }
        Map<String, Object> map = objectMapper.convertValue(entity, new TypeReference<Map<String, Object>>() {
        });
        return maskSensitive(map);
    }

    private Map<String, Object> maskSensitive(Map<String, Object> input) {
        if (input == null) {
            return null;
        }
        Map<String, Object> copy = new LinkedHashMap<String, Object>();
        for (Map.Entry<String, Object> e : input.entrySet()) {
            String key = e.getKey() == null ? "" : e.getKey().toLowerCase();
            Object value = e.getValue();
            if (key.contains("password") || key.contains("secret") || key.contains("token") || key.contains("authorization")) {
                copy.put(e.getKey(), "***");
            } else {
                copy.put(e.getKey(), value);
            }
        }
        return copy;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> castMap(Object obj) {
        if (!(obj instanceof Map)) {
            return null;
        }
        return (Map<String, Object>) obj;
    }

    private String cutJson(Map<String, Object> map) {
        if (map == null) {
            return null;
        }
        try {
            return cut(objectMapper.writeValueAsString(map), 60000);
        } catch (Exception ex) {
            return null;
        }
    }

    private String cut(String text, int max) {
        if (text == null) {
            return null;
        }
        return text.length() <= max ? text : text.substring(0, max);
    }

    private boolean isWriteMethod(String method) {
        return "POST".equalsIgnoreCase(method)
            || "PUT".equalsIgnoreCase(method)
            || "DELETE".equalsIgnoreCase(method)
            || "PATCH".equalsIgnoreCase(method);
    }

    private interface SnapshotLoader {
        Object load(Long id);
    }

    private static class SnapshotTarget {
        private final String type;
        private final SnapshotLoader loader;

        private SnapshotTarget(String type, SnapshotLoader loader) {
            this.type = type;
            this.loader = loader;
        }

        private Object load(Long id) {
            return loader.load(id);
        }
    }
}