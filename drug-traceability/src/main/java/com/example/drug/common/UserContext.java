package com.example.drug.common;

import com.example.drug.entity.User;

public class UserContext {
    private static final ThreadLocal<User> HOLDER = new ThreadLocal<>();

    public static void setCurrentUser(User user) {
        HOLDER.set(user);
    }

    public static User getCurrentUser() {
        return HOLDER.get();
    }

    public static Long getCurrentUserId() {
        User user = HOLDER.get();
        return user != null ? user.getId() : null;
    }

    public static void clear() {
        HOLDER.remove();
    }
}
