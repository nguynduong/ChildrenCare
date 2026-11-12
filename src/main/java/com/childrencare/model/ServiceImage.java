package com.childrencare.model;

/**
 * Thực thể ServiceImage: Các ảnh đính kèm của gói dịch vụ.
 */
public class ServiceImage {
    private int id;
    private int serviceId;
    private String imageUrl;
    private int sortOrder;

    public ServiceImage() {
    }

    public ServiceImage(int id, int serviceId, String imageUrl, int sortOrder) {
        this.id = id;
        this.serviceId = serviceId;
        this.imageUrl = imageUrl;
        this.sortOrder = sortOrder;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }
}

