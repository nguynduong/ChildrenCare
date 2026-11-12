package com.childrencare.dao;

import com.childrencare.model.MedicalExamination;
import com.childrencare.model.Prescription;
import com.childrencare.model.PrescriptionItem;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho MedicalExaminations, Prescriptions và PrescriptionItems.
 */
public class MedicalDAO {

    /**
     * Lấy hồ sơ khám bệnh và đơn thuốc theo mã đặt lịch (ReservationId).
     */
    public MedicalExamination getByReservationId(int reservationId) {
        String sqlExam = "SELECT me.*, u.FullName AS DoctorName " +
                         "FROM MedicalExaminations me " +
                         "LEFT JOIN Users u ON me.DoctorId = u.Id " +
                         "WHERE me.ReservationId = ?";

        String sqlPres = "SELECT p.*, u.FullName AS DoctorName " +
                         "FROM Prescriptions p " +
                         "LEFT JOIN Users u ON p.DoctorId = u.Id " +
                         "WHERE p.MedicalExaminationId = ?";

        String sqlItems = "SELECT * FROM PrescriptionItems WHERE PrescriptionId = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement psExam = conn.prepareStatement(sqlExam)) {
            psExam.setInt(1, reservationId);
            try (ResultSet rsExam = psExam.executeQuery()) {
                if (rsExam.next()) {
                    MedicalExamination exam = new MedicalExamination();
                    exam.setId(rsExam.getInt("Id"));
                    exam.setReservationId(rsExam.getInt("ReservationId"));
                    exam.setExaminationDate(rsExam.getTimestamp("ExaminationDate"));
                    exam.setDoctorId(rsExam.getInt("DoctorId"));
                    exam.setDoctorName(rsExam.getString("DoctorName"));
                    exam.setNotes(rsExam.getString("Notes"));

                    // Lấy đơn thuốc
                    try (PreparedStatement psPres = conn.prepareStatement(sqlPres)) {
                        psPres.setInt(1, exam.getId());
                        try (ResultSet rsPres = psPres.executeQuery()) {
                            if (rsPres.next()) {
                                Prescription pres = new Prescription();
                                pres.setId(rsPres.getInt("Id"));
                                pres.setMedicalExaminationId(rsPres.getInt("MedicalExaminationId"));
                                pres.setDoctorId(rsPres.getInt("DoctorId"));
                                pres.setDoctorName(rsPres.getString("DoctorName"));
                                pres.setDiagnosis(rsPres.getString("Diagnosis"));
                                pres.setNote(rsPres.getString("Note"));
                                pres.setCreatedDate(rsPres.getTimestamp("CreatedDate"));

                                // Lấy các dòng thuốc
                                try (PreparedStatement psItem = conn.prepareStatement(sqlItems)) {
                                    psItem.setInt(1, pres.getId());
                                    try (ResultSet rsItem = psItem.executeQuery()) {
                                        while (rsItem.next()) {
                                            pres.getItems().add(new PrescriptionItem(
                                                rsItem.getInt("Id"),
                                                rsItem.getInt("PrescriptionId"),
                                                rsItem.getString("MedicineName"),
                                                rsItem.getString("Dosage"),
                                                rsItem.getInt("Quantity"),
                                                rsItem.getString("Usage")
                                            ));
                                        }
                                    }
                                }
                                exam.setPrescription(pres);
                            }
                        }
                    }
                    return exam;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Bác sĩ lưu hồ sơ khám và kê đơn thuốc trong một Transaction.
     * Đồng thời tự động cập nhật trạng thái Reservation sang 'Success'.
     */
    public boolean saveExaminationAndPrescription(MedicalExamination exam, Prescription pres) {
        String sqlExam = "INSERT INTO MedicalExaminations (ReservationId, ExaminationDate, DoctorId, Notes) VALUES (?, GETDATE(), ?, ?)";
        String sqlPres = "INSERT INTO Prescriptions (MedicalExaminationId, DoctorId, Diagnosis, Note) VALUES (?, ?, ?, ?)";
        String sqlItem = "INSERT INTO PrescriptionItems (PrescriptionId, MedicineName, Dosage, Quantity, Usage) VALUES (?, ?, ?, ?, ?)";
        String sqlSuccess = "UPDATE Reservations SET Status = 'Success', UpdatedDate = GETDATE() WHERE Id = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            int examId;

            // 1. Lưu MedicalExamination
            try (PreparedStatement psExam = conn.prepareStatement(sqlExam, Statement.RETURN_GENERATED_KEYS)) {
                psExam.setInt(1, exam.getReservationId());
                psExam.setInt(2, exam.getDoctorId());
                psExam.setString(3, exam.getNotes());
                psExam.executeUpdate();
                try (ResultSet rs = psExam.getGeneratedKeys()) {
                    if (rs.next()) {
                        examId = rs.getInt(1);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            // 2. Lưu Prescription (nếu có chẩn đoán hoặc thuốc)
            if (pres != null && pres.getItems() != null && !pres.getItems().isEmpty()) {
                int presId;
                try (PreparedStatement psPres = conn.prepareStatement(sqlPres, Statement.RETURN_GENERATED_KEYS)) {
                    psPres.setInt(1, examId);
                    psPres.setInt(2, pres.getDoctorId());
                    psPres.setString(3, pres.getDiagnosis());
                    psPres.setString(4, pres.getNote());
                    psPres.executeUpdate();
                    try (ResultSet rs = psPres.getGeneratedKeys()) {
                        if (rs.next()) {
                            presId = rs.getInt(1);
                        } else {
                            conn.rollback();
                            return false;
                        }
                    }
                }

                // 3. Lưu từng dòng thuốc
                try (PreparedStatement psItem = conn.prepareStatement(sqlItem)) {
                    for (PrescriptionItem item : pres.getItems()) {
                        psItem.setInt(1, presId);
                        psItem.setString(2, item.getMedicineName());
                        psItem.setString(3, item.getDosage());
                        psItem.setInt(4, item.getQuantity());
                        psItem.setString(5, item.getUsage());
                        psItem.executeUpdate();
                    }
                }
            }

            // 4. Chuyển trạng thái đơn sang Success
            try (PreparedStatement psSuccess = conn.prepareStatement(sqlSuccess)) {
                psSuccess.setInt(1, exam.getReservationId());
                psSuccess.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}

