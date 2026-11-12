package com.childrencare.controller.staff;

import com.childrencare.dao.MedicalDAO;
import com.childrencare.dao.ReservationDAO;
import com.childrencare.model.MedicalExamination;
import com.childrencare.model.Prescription;
import com.childrencare.model.PrescriptionItem;
import com.childrencare.model.Reservation;
import com.childrencare.model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [30] Medical Examination: Bác sĩ ghi nhận kết quả khám và kê đơn thuốc (Y tá chỉ xem).
 */
@WebServlet("/staff/medical-examination")
public class MedicalExaminationServlet extends HttpServlet {

    private final MedicalDAO medicalDAO = new MedicalDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String resIdStr = request.getParameter("reservationId");
        if (resIdStr == null || resIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/reservations");
            return;
        }

        try {
            int reservationId = Integer.parseInt(resIdStr);
            Reservation reservation = reservationDAO.getById(reservationId);
            if (reservation == null) {
                response.sendRedirect(request.getContextPath() + "/staff/reservations");
                return;
            }

            // Kiểm tra xem đã có hồ sơ khám bệnh chưa
            MedicalExamination exam = medicalDAO.getByReservationId(reservationId);

            request.setAttribute("reservation", reservation);
            request.setAttribute("exam", exam);
            request.getRequestDispatcher("/WEB-INF/views/staff/examination.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/staff/reservations");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        // Y tá (Role 3) không có quyền kê đơn thuốc
        if (currentUser.getRoleId() == 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Y tá không có quyền tạo hoặc sửa đơn thuốc.");
            return;
        }

        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        String examNotes = request.getParameter("examNotes");
        String diagnosis = request.getParameter("diagnosis");
        String presNote = request.getParameter("presNote");

        String[] medicineNames = request.getParameterValues("medicineName");
        String[] dosages = request.getParameterValues("dosage");
        String[] quantities = request.getParameterValues("quantity");
        String[] usages = request.getParameterValues("usage");

        MedicalExamination exam = new MedicalExamination();
        exam.setReservationId(reservationId);
        exam.setDoctorId(currentUser.getId());
        exam.setNotes(examNotes != null ? examNotes.trim() : "");

        Prescription pres = new Prescription();
        pres.setDoctorId(currentUser.getId());
        pres.setDiagnosis(diagnosis != null ? diagnosis.trim() : "Khám tổng quát");
        pres.setNote(presNote != null ? presNote.trim() : "");

        List<PrescriptionItem> items = new ArrayList<>();
        if (medicineNames != null) {
            for (int i = 0; i < medicineNames.length; i++) {
                if (medicineNames[i] != null && !medicineNames[i].trim().isEmpty()) {
                    int qty = 1;
                    try {
                        qty = Integer.parseInt(quantities[i]);
                    } catch (Exception ignored) {}
                    items.add(new PrescriptionItem(0, 0, medicineNames[i].trim(), dosages[i].trim(), qty, usages[i].trim()));
                }
            }
        }
        pres.setItems(items);

        if (medicalDAO.saveExaminationAndPrescription(exam, pres)) {
            request.getSession().setAttribute("flashSuccess", "Đã hoàn tất buổi khám và lưu đơn thuốc thành công!");
        } else {
            request.getSession().setAttribute("flashError", "Lưu hồ sơ khám bệnh thất bại.");
        }

        response.sendRedirect(request.getContextPath() + "/staff/medical-examination?reservationId=" + reservationId);
    }
}

