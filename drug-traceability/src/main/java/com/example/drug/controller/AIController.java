package com.example.drug.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.drug.common.RequireRole;
import com.example.drug.common.UserContext;
import com.example.drug.entity.AIConversation;
import com.example.drug.entity.AIMessage;
import com.example.drug.service.AIConversationService;
import com.example.drug.service.AIMessageService;
import com.example.drug.service.AIService;
import com.example.drug.service.ReadonlyDatabaseQaService;
import com.example.drug.service.ReadonlyDatabaseQaService.DbAnswerContext;
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

    @Autowired
    private AIService aiService;

    @Autowired
    private ReadonlyDatabaseQaService readonlyDatabaseQaService;

    @RequireRole({"admin", "producer", "enterprise", "institution", "regulator", "public"})
    @PostMapping("/chat")
    public Map<String, Object> chat(@RequestBody Map<String, Object> params) {
        String message = (String) params.get("message");
        Object conversationIdRaw = params.get("conversationId");

        if (message == null || message.trim().isEmpty()) {
            return MapUtils.of("code", 400, "message", "message cannot be empty");
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
                    return MapUtils.of("code", 403, "message", "conversation access denied");
                }
            }

            AIMessage userMessage = new AIMessage();
            userMessage.setConversationId(conversationIdFinal);
            userMessage.setRole("user");
            userMessage.setContent(message);
            userMessage.setCreateTime(LocalDateTime.now());
            messageService.save(userMessage);

            DbAnswerContext dbContext = readonlyDatabaseQaService.resolve(message);
            String aiResponse = aiService.generateResponse(
                buildUserPrompt(message, dbContext),
                buildSystemPrompt(params, dbContext)
            );

            AIMessage assistantMessage = new AIMessage();
            assistantMessage.setConversationId(conversationIdFinal);
            assistantMessage.setRole("assistant");
            assistantMessage.setContent(aiResponse);
            assistantMessage.setCreateTime(LocalDateTime.now());
            messageService.save(assistantMessage);

            return MapUtils.of("code", 200, "message", "success", "data", MapUtils.of(
                "conversationId", String.valueOf(conversationIdFinal),
                "response", aiResponse
            ));
        } catch (Exception e) {
            return MapUtils.of("code", 500, "message", "AI response failed: " + e.getMessage());
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
            return MapUtils.of("code", 403, "message", "conversation access denied");
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
            return MapUtils.of("code", 400, "message", "fileName and originalText are required");
        }

        try {
            return MapUtils.of("code", 200, "message", "upload success");
        } catch (Exception e) {
            return MapUtils.of("code", 500, "message", "upload failed: " + e.getMessage());
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

    private String buildSystemPrompt(Map<String, Object> params, DbAnswerContext dbContext) {
        Object sceneRaw = params.get("scene");
        String scene = sceneRaw == null ? "" : String.valueOf(sceneRaw).trim();
        String dbFacts = readonlyDatabaseQaService.toPromptBlock(dbContext);

        if ("public".equalsIgnoreCase(scene)) {
            return "你是面向公众用户的药品追溯客服助手。只提供通俗、保守、易懂的建议；可以帮助识别追溯信息、说明常见用药安全注意事项、指导问题上报。不要提供诊断结论，不要替代医生。\n\n"
                + "回答时优先依据下面的数据库只读事实，不得编造不存在的数据：\n"
                + dbFacts;
        }
        if ("enterprise".equalsIgnoreCase(scene)) {
            return "你是面向医药企业的运营合规助手。重点帮助处理进销存合规、批次追溯、异常处置、自查建议。回答应简洁、专业、可执行。\n\n"
                + "回答时优先依据下面的数据库只读事实，不得编造不存在的数据：\n"
                + dbFacts;
        }
        if ("institution".equalsIgnoreCase(scene)) {
            return "你是面向医疗机构的药品管理助手。重点帮助验收入库、用药记录规范、不良反应上报、院内追溯流程。回答应专业、保守、合规。\n\n"
                + "回答时优先依据下面的数据库只读事实，不得编造不存在的数据：\n"
                + dbFacts;
        }
        if ("regulator".equalsIgnoreCase(scene)) {
            return "你是面向监管人员的药品监管分析助手。重点帮助风险研判、线索梳理、执法检查准备、统计口径说明。不要编造事实，结论要谨慎。\n\n"
                + "回答时优先依据下面的数据库只读事实，不得编造不存在的数据：\n"
                + dbFacts;
        }
        return "你是药品追溯系统的智能助手。回答使用中文，保持简洁、准确、可执行。\n\n"
            + "回答时优先依据下面的数据库只读事实，不得编造不存在的数据：\n"
            + dbFacts;
    }

    private String buildUserPrompt(String userMessage, DbAnswerContext dbContext) {
        return "请基于系统提供的数据库只读工具结果与角色要求回答下面的问题。"
            + "当前识别出的数据库问答意图是：" + dbContext.getIntent() + "。"
            + "如果数据库没有明确事实，请明确说明不确定，并给出保守建议。\n\n用户问题：" + userMessage;
    }
}
