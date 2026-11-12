package com.childrencare.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Quản lý giỏ dịch vụ (Cart) lưu trong Session.
 */
public class Cart {

    private final List<ReservationItem> items = new ArrayList<>();

    public List<ReservationItem> getItems() {
        return items;
    }

    public void addItem(Service service, int quantity, int numberOfPerson) {
        for (ReservationItem item : items) {
            if (item.getServiceId() == service.getId()) {
                item.setQuantity(item.getQuantity() + quantity);
                item.setNumberOfPerson(numberOfPerson > 0 ? numberOfPerson : item.getNumberOfPerson());
                item.setUnitPrice(service.getSalePrice()); // Cập nhật giá mới nhất
                item.setTotalCost(calculateItemTotal(item));
                return;
            }
        }

        ReservationItem newItem = new ReservationItem();
        newItem.setServiceId(service.getId());
        newItem.setServiceTitle(service.getTitle());
        newItem.setServiceThumbnail(service.getThumbnail());
        newItem.setServiceCategory(service.getCategoryName());
        newItem.setUnitPrice(service.getSalePrice());
        newItem.setQuantity(Math.max(1, quantity));
        newItem.setNumberOfPerson(Math.max(1, numberOfPerson));
        newItem.setTotalCost(calculateItemTotal(newItem));
        items.add(newItem);
    }

    public void updateItem(int serviceId, int quantity, int numberOfPerson) {
        for (ReservationItem item : items) {
            if (item.getServiceId() == serviceId) {
                if (quantity <= 0) {
                    removeItem(serviceId);
                } else {
                    item.setQuantity(quantity);
                    item.setNumberOfPerson(Math.max(1, numberOfPerson));
                    item.setTotalCost(calculateItemTotal(item));
                }
                return;
            }
        }
    }

    public void removeItem(int serviceId) {
        items.removeIf(item -> item.getServiceId() == serviceId);
    }

    public void clear() {
        items.clear();
    }

    public int getTotalItems() {
        int count = 0;
        for (ReservationItem item : items) {
            count += item.getQuantity();
        }
        return count;
    }

    public BigDecimal getTotalPrice() {
        BigDecimal total = BigDecimal.ZERO;
        for (ReservationItem item : items) {
            total = total.add(item.getTotalCost());
        }
        return total;
    }

    private BigDecimal calculateItemTotal(ReservationItem item) {
        return item.getUnitPrice()
                .multiply(BigDecimal.valueOf(item.getQuantity()))
                .multiply(BigDecimal.valueOf(item.getNumberOfPerson()));
    }
}

