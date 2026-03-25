package com.example.drug.common;

import com.example.drug.entity.User;
import org.springframework.stereotype.Component;

import java.util.concurrent.ConcurrentHashMap;

@Component
public class TokenStore {
    private final ConcurrentHashMap<String, User> store = new ConcurrentHashMap<>();

    public void store(String token, User user) {
        store.put(token, user);
    }

    public User getUser(String token) {
        return store.get(token);
    }

    public void remove(String token) {
        store.remove(token);
    }

    public boolean exists(String token) {
        return store.containsKey(token);
    }
}
