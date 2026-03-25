package com.example.drug.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AIConfig {

    @Value("${ai.deepseek.api-key}")
    private String deepseekApiKey;

    @Value("${ai.embedding.model}")
    private String embeddingModel;

    @Value("${ai.milvus.host}")
    private String milvusHost;

    @Value("${ai.milvus.port}")
    private int milvusPort;

    @Value("${ai.milvus.collection-name}")
    private String milvusCollectionName;

    public String getDeepseekApiKey() {
        return deepseekApiKey;
    }

    public String getEmbeddingModel() {
        return embeddingModel;
    }

    public String getMilvusHost() {
        return milvusHost;
    }

    public int getMilvusPort() {
        return milvusPort;
    }

    public String getMilvusCollectionName() {
        return milvusCollectionName;
    }
}