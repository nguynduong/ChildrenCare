package com.childrencare.model;

import java.sql.Timestamp;

/**
 * Thực thể Contact: Danh bạ liên hệ khách hàng phục vụ tiếp thị.
 */
public class Contact {
    private int id;
    private String fullName;
    private String gender;
    private String email;
    private String mobile;
    private String address;
    private String status; // Contact, Potential, Customer
    private Timestamp createdDate;
    private Timestamp updatedDate;

    public Contact() {
    }

    public Contact(int id, String fullName, String gender, String email, String mobile, String address, String status) {
        this.id = id;
        this.fullName = fullName;
        this.gender = gender;
        this.email = email;
        this.mobile = mobile;
        this.address = address;
        this.status = status;
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

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

