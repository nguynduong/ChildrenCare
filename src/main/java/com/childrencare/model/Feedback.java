package com.childrencare.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Thực thể Feedback: Phản hồi & đánh giá dịch vụ của khách hàng.
 */
public class Feedback {
    private int id;
    private String fullName;
    private String gender;
    private String email;
    private String mobile;
    private Integer serviceId; // NULL nếu là phản hồi chung
    private String serviceTitle;
    private int ratedStar; // 1 đến 5 sao
    private String content;
    private String status; // Published, Hidden
    private List<String> images = new ArrayList<>();
    private Timestamp createdDate;

    public Feedback() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public Integer getServiceId() {
        return serviceId;
    }

    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceTitle() {
        return serviceTitle;
    }

    public void setServiceTitle(String serviceTitle) {
        this.serviceTitle = serviceTitle;
    }

    public int getRatedStar() {
        return ratedStar;
    }

    public void setRatedStar(int ratedStar) {
        this.ratedStar = ratedStar;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
}

