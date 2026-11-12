package com.childrencare.model;

/**
 * Thực thể PrescriptionItem: Từng loại thuốc trong đơn.
 */
public class PrescriptionItem {
    private int id;
    private int prescriptionId;
    private String medicineName;
    private String dosage;
    private int quantity;
    private String usage;

    public PrescriptionItem() {
    }

    public PrescriptionItem(int id, int prescriptionId, String medicineName, String dosage, int quantity, String usage) {
        this.id = id;
        this.prescriptionId = prescriptionId;
        this.medicineName = medicineName;
        this.dosage = dosage;
        this.quantity = quantity;
        this.usage = usage;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getPrescriptionId() {
        return prescriptionId;
    }

    public void setPrescriptionId(int prescriptionId) {
        this.prescriptionId = prescriptionId;
    }

    public String getMedicineName() {
        return medicineName;
    }

    public void setMedicineName(String medicineName) {
        this.medicineName = medicineName;
    }

    public String getDosage() {
        return dosage;
    }

    public void setDosage(String dosage) {
        this.dosage = dosage;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getUsage() {
        return usage;
    }

    public void setUsage(String usage) {
        this.usage = usage;
    }
}

