package com.childrencare.model;

import java.sql.Timestamp;

/**
 * Thực thể Slider: Ảnh trượt biểu ngữ trang chủ.
 */
public class Slider {
    private int id;
    private String title;
    private String imageUrl;
    private String backLink;
    private String status; // Active, Inactive
    private String notes;
    private Timestamp createdDate;
    private Timestamp updatedDate;

    public Slider() {
    }

    public Slider(int id, String title, String imageUrl, String backLink, String status, String notes) {
        this.id = id;
        this.title = title;
        this.imageUrl = imageUrl;
        this.backLink = backLink;
        this.status = status;
        this.notes = notes;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getBackLink() {
        return backLink;
    }

    public void setBackLink(String backLink) {
        this.backLink = backLink;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public Timestamp getUpdatedDate() {
        return updatedDate;
    }

    public void setUpdatedDate(Timestamp updatedDate) {
        this.updatedDate = updatedDate;
    }
}

