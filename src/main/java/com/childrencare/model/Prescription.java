package com.childrencare.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Thực thể Prescription: Đơn thuốc điện tử do Bác sĩ kê.
 */
public class Prescription {
    private int id;
    private int medicalExaminationId;
    private int doctorId;
    private String doctorName;
    private String diagnosis;
    private String note;
    private List<PrescriptionItem> items = new ArrayList<>();
    private Timestamp createdDate;

    public Prescription() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getMedicalExaminationId() {
        return medicalExaminationId;
    }

    public void setMedicalExaminationId(int medicalExaminationId) {
        this.medicalExaminationId = medicalExaminationId;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public List<PrescriptionItem> getItems() {
        return items;
    }

    public void setItems(List<PrescriptionItem> items) {
        this.items = items;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
}

