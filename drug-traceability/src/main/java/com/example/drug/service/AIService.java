package com.example.drug.service;

import com.example.drug.config.AIConfig;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

@Service
public class AIService {

    private final AIConfig aiConfig;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AIService(AIConfig aiConfig) {
        this.aiConfig = aiConfig;
    }

    public String generateResponse(String prompt) {
        return generateResponse(prompt, null);
    }

    public String generateResponse(String prompt, String systemPrompt) {
        HttpURLConnection connection = null;
        try {
            URL url = new URL(aiConfig.getDeepseekBaseUrl() + "/chat/completions");
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setConnectTimeout(15000);
            connection.setReadTimeout(60000);
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setRequestProperty("Authorization", "Bearer " + aiConfig.getDeepseekApiKey());

            String payload = buildPayload(prompt, systemPrompt);
            try (OutputStream outputStream = connection.getOutputStream()) {
                outputStream.write(payload.getBytes(StandardCharsets.UTF_8));
            }

            int status = connection.getResponseCode();
            String body = readBody(status >= 200 && status < 300
                ? connection.getInputStream()
                : connection.getErrorStream());

            if (status < 200 || status >= 300) {
                throw new RuntimeException("DeepSeek request failed: HTTP " + status + " - " + body);
            }

            JsonNode root = objectMapper.readTree(body);
            JsonNode choices = root.path("choices");
            if (!choices.isArray() || choices.size() == 0) {
                throw new RuntimeException("DeepSeek returned empty choices");
            }

            String content = choices.get(0).path("message").path("content").asText("").trim();
            if (content.isEmpty()) {
                throw new RuntimeException("DeepSeek returned empty content");
            }
            return content;
        } catch (Exception e) {
            throw new RuntimeException("AI service unavailable: " + e.getMessage(), e);
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    public String runAgent(String prompt) {
        try {
            return generateResponse(prompt);
        } catch (Exception e) {
            return "AI error: " + e.getMessage();
        }
    }

    private String buildPayload(String prompt, String systemPrompt) throws Exception {
        String finalSystemPrompt = systemPrompt == null || systemPrompt.trim().isEmpty()
            ? "You are a concise assistant for a drug traceability system. Provide practical, safe, and factual answers in Chinese."
            : systemPrompt;

        return objectMapper.writeValueAsString(objectMapper.createObjectNode()
            .put("model", aiConfig.getDeepseekModel())
            .put("temperature", 0.3)
            .set("messages", objectMapper.createArrayNode()
                .add(objectMapper.createObjectNode()
                    .put("role", "system")
                    .put("content", finalSystemPrompt))
                .add(objectMapper.createObjectNode()
                    .put("role", "user")
                    .put("content", prompt))));
    }

    private String readBody(InputStream inputStream) throws Exception {
        if (inputStream == null) {
            return "";
        }

        StringBuilder builder = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
        }
        return builder.toString();
    }
}
