package com.childrencare.model;

/**
 * Thực thể Setting: Cấu hình hệ thống, Role, Danh mục.
 */
public class Setting {
    private int id;
    private String type;
    private String name;
    private String value;
    private String description;
    private String status; // Active, Inactive

    public Setting() {
    }

    public Setting(int id, String type, String name, String value, String description, String status) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.value = value;
        this.description = description;
        this.status = status;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}

