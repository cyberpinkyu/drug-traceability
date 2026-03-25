package com.example.drug.common;

public enum StatusEnum {
    ACTIVE(1),
    INACTIVE(0);

    private final int code;

    StatusEnum(int code) {
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
