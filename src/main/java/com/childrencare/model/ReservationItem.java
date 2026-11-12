package com.childrencare.model;

import java.math.BigDecimal;

/**
 * Thực thể ReservationItem: Từng dịch vụ trong một đơn đặt lịch.
 */
public class ReservationItem {
    private int id;
    private int reservationId;
    private int serviceId;
    private String serviceTitle;
    private String serviceThumbnail;
    private String serviceCategory;
    private BigDecimal unitPrice;
    private int quantity;
    private int numberOfPerson;
    private BigDecimal totalCost;

    public ReservationItem() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getReservationId() {
        return reservationId;
    }

    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceTitle() {
        return serviceTitle;
    }

    public void setServiceTitle(String serviceTitle) {
        this.serviceTitle = serviceTitle;
    }

    public String getServiceThumbnail() {
        return serviceThumbnail;
    }

    public void setServiceThumbnail(String serviceThumbnail) {
        this.serviceThumbnail = serviceThumbnail;
    }

    public String getServiceCategory() {
        return serviceCategory;
    }

    public void setServiceCategory(String serviceCategory) {
        this.serviceCategory = serviceCategory;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getNumberOfPerson() {
        return numberOfPerson;
    }

    public void setNumberOfPerson(int numberOfPerson) {
        this.numberOfPerson = numberOfPerson;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }
}

