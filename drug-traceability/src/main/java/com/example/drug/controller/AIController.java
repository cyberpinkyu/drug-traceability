package com.example.drug.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.drug.common.RequireRole;
import com.example.drug.common.UserContext;
import com.example.drug.entity.AIConversation;
import com.example.drug.entity.AIMessage;
import com.example.drug.service.AIConversationService;
import com.example.drug.service.AIMessageService;
import com.example.drug.utils.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AIController {

    @Autowired
    private AIConversationService conversationService;

    @Autowired
    private AIMessageService messageService;

    @RequireRole({"admin", "producer", "enterprise", "institution", "regulator", "public"})
    @PostMapping("/chat")
    public Map<String, Object> chat(@RequestBody Map<String, Object> params) {
        String message = (String) params.get("message");
        Object conversationIdRaw = params.get("conversationId");
        Map<String, Object> context = (Map<String, Object>) params.get("context");

        if (message == null || message.trim().isEmpty()) {
            return MapUtils.of("code", 400, "message", "消息不能为空");
        }

        try {
            Long conversationIdFinal = parseConversationId(conversationIdRaw);
            if (conversationIdFinal == null) {
                AIConversation conversation = new AIConversation();
                conversation.setUserId(UserContext.getCurrentUser().getId());
                conversation.setTitle(generateTitle(message));
                conversation.setCreateTime(LocalDateTime.now());
                conversation.setUpdateTime(LocalDateTime.now());
                conversationService.save(conversation);
                conversationIdFinal = conversation.getConversationId();
            } else {
                QueryWrapper<AIConversation> ownerCheck = new QueryWrapper<>();
                ownerCheck.eq("conversation_id", conversationIdFinal)
                    .eq("user_id", UserContext.getCurrentUserId())
                    .last("LIMIT 1");
                if (conversationService.getOne(ownerCheck) == null) {
                    return MapUtils.of("code", 403, "message", "无权访问该会话");
                }
            }

            AIMessage userMessage = new AIMessage();
            userMessage.setConversationId(conversationIdFinal);
            userMessage.setRole("user");
            userMessage.setContent(message);
            userMessage.setCreateTime(LocalDateTime.now());
            messageService.save(userMessage);

            String aiResponse = generateAIResponse(message, UserContext.getCurrentUser().getRoleCode(), context);

            AIMessage assistantMessage = new AIMessage();
            assistantMessage.setConversationId(conversationIdFinal);
            assistantMessage.setRole("assistant");
            assistantMessage.setContent(aiResponse);
            assistantMessage.setCreateTime(LocalDateTime.now());
            messageService.save(assistantMessage);

            return MapUtils.of("code", 200, "message", "成功", "data", MapUtils.of(
                "conversationId", String.valueOf(conversationIdFinal),
                "response", aiResponse
            ));
        } catch (Exception e) {
            return MapUtils.of("code", 500, "message", "AI响应失败: " + e.getMessage());
        }
    }

    @GetMapping("/conversations")
    public Map<String, Object> getConversations() {
        QueryWrapper<AIConversation> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", UserContext.getCurrentUserId());
        wrapper.orderByDesc("created_at");
        List<AIConversation> conversations = conversationService.list(wrapper);
        return MapUtils.of("code", 200, "data", conversations);
    }

    @GetMapping("/conversations/{conversationId}/messages")
    public Map<String, Object> getMessages(@PathVariable Long conversationId) {
        QueryWrapper<AIConversation> conversationWrapper = new QueryWrapper<>();
        conversationWrapper.eq("conversation_id", conversationId)
            .eq("user_id", UserContext.getCurrentUserId())
            .last("LIMIT 1");
        AIConversation conversation = conversationService.getOne(conversationWrapper);
        if (conversation == null) {
            return MapUtils.of("code", 403, "message", "无权访问该会话");
        }

        QueryWrapper<AIMessage> wrapper = new QueryWrapper<>();
        wrapper.eq("conversation_id", conversationId);
        wrapper.orderByAsc("created_at");
        List<AIMessage> messages = messageService.list(wrapper);
        return MapUtils.of("code", 200, "data", messages);
    }

    @RequireRole({"admin", "regulator"})
    @PostMapping("/knowledge/upload")
    public Map<String, Object> uploadKnowledge(@RequestBody Map<String, String> params) {
        String fileName = params.get("fileName");
        String originalText = params.get("originalText");

        if (fileName == null || originalText == null) {
            return MapUtils.of("code", 400, "message", "文件名和内容不能为空");
        }

        try {
            return MapUtils.of("code", 200, "message", "上传成功");
        } catch (Exception e) {
            return MapUtils.of("code", 500, "message", "上传失败: " + e.getMessage());
        }
    }

    private Long parseConversationId(Object conversationIdRaw) {
        if (conversationIdRaw == null) {
            return null;
        }
        String value = String.valueOf(conversationIdRaw).trim();
        if (value.isEmpty()) {
            return null;
        }
        return Long.valueOf(value);
    }

    private String generateTitle(String message) {
        if (message.length() > 20) {
            return message.substring(0, 20) + "...";
        }
        return message;
    }

    private String generateAIResponse(String message, String userRole, Map<String, Object> context) {
        if (message.contains("查询") || message.contains("追溯")) {
            return "我可以帮您查询药品的追溯信息。请提供药品的批次号或监管码，我将为您查询完整的追溯链条。";
        }
        if (message.contains("统计") || message.contains("报告")) {
            return "我可以为您生成药品流通统计报告。请告诉我您需要统计的时间范围和药品类型，我将为您生成详细的统计报表。";
        }
        if (message.contains("风险") || message.contains("预警")) {
            return "我可以为您分析药品风险情况。请提供相关的批次信息或企业信息，我将为您进行风险评估和预警分析。";
        }
        if (message.contains("法规") || message.contains("政策")) {
            return "根据《药品经营质量管理规范》(GSP)的相关规定，药品经营企业需要建立完善的质量管理体系，确保药品来源可查、去向可追。";
        }
        return "您好！我是智能药品追溯助手，可以帮您查询药品追溯信息、生成统计报告、分析风险预警、解答法规政策等问题。请问有什么可以帮助您的？";
    }
}
