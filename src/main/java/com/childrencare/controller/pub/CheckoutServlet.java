package com.childrencare.controller.pub;

import com.childrencare.dao.ContactDAO;
import com.childrencare.dao.ReservationDAO;
import com.childrencare.dao.UserDAO;
import com.childrencare.model.Cart;
import com.childrencare.model.Reservation;
import com.childrencare.model.ReservationItem;
import com.childrencare.model.User;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [7] Reservation Contact & [8] Reservation Completion: Điền thông tin người nhận, đặt lịch và xác nhận.
 */
@WebServlet({"/checkout", "/reservation-complete"})
public class CheckoutServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ContactDAO contactDAO = new ContactDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // 1. Màn hình hoàn tất đặt lịch
        if ("/reservation-complete".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    Reservation reservation = reservationDAO.getById(id);
                    request.setAttribute("reservation", reservation);
                } catch (NumberFormatException ignored) {}
            }
            request.getRequestDispatcher("/WEB-INF/views/pub/reservation-complete.jsp").forward(request, response);
            return;
        }

        // 2. Màn hình liên hệ đặt lịch (Reservation Contact)
        HttpSession session = request.getSession(false);
        Cart cart = (session != null) ? (Cart) session.getAttribute("cart") : null;

        if (cart == null || cart.getItems().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/services");
            return;
        }

        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        request.setAttribute("cart", cart);
        request.setAttribute("currentUser", currentUser);
        request.getRequestDispatcher("/WEB-INF/views/pub/reservation-contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Cart cart = (session != null) ? (Cart) session.getAttribute("cart") : null;

        if (cart == null || cart.getItems().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/services");
            return;
        }

        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String fullName = request.getParameter("receiverFullName");
        String gender = request.getParameter("receiverGender");
        String email = request.getParameter("receiverEmail");
        String mobile = request.getParameter("receiverMobile");
        String address = request.getParameter("receiverAddress");
        String checkupTimeStr = request.getParameter("checkupTime");
        String notes = request.getParameter("notes");

        // Validate thông tin
        if (fullName == null || fullName.trim().length() < 2 || fullName.trim().length() > 100) {
            forwardWithError(request, response, "Họ và tên người nhận phải từ 2 đến 100 ký tự.", cart, currentUser);
            return;
        }
        if (email == null || !email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            forwardWithError(request, response, "Địa chỉ email không đúng định dạng.", cart, currentUser);
            return;
        }
        if (mobile == null || !mobile.matches("^0\\d{9}$")) {
            forwardWithError(request, response, "Số điện thoại phải đúng 10 số và bắt đầu bằng số 0.", cart, currentUser);
            return;
        }
        if (checkupTimeStr == null || checkupTimeStr.trim().isEmpty()) {
            forwardWithError(request, response, "Vui lòng chọn thời gian khám bệnh.", cart, currentUser);
            return;
        }

        Timestamp checkupTimestamp;
        try {
            LocalDateTime ldt = LocalDateTime.parse(checkupTimeStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            if (ldt.isBefore(LocalDateTime.now())) {
                forwardWithError(request, response, "Thời gian khám phải sau thời điểm hiện tại.", cart, currentUser);
                return;
            }
            checkupTimestamp = Timestamp.valueOf(ldt);
        } catch (Exception e) {
            forwardWithError(request, response, "Định dạng thời gian khám không hợp lệ.", cart, currentUser);
            return;
        }

        // Tự động phân công Bác sĩ (Doctor - Role 2) xoay vòng
        List<User> activeDoctors = userDAO.getActiveStaffByRole(2);
        Integer assignedStaffId = null;
        if (!activeDoctors.isEmpty()) {
            // Lấy ngẫu nhiên hoặc xoay vòng bác sĩ đang hoạt động
            int idx = (int) (Math.random() * activeDoctors.size());
            assignedStaffId = activeDoctors.get(idx).getId();
        }

        // Tạo đơn đặt lịch Reservation
        Reservation res = new Reservation();
        if (currentUser != null) {
            res.setUserId(currentUser.getId());
        }
        res.setCheckupTime(checkupTimestamp);
        res.setReceiverFullName(fullName.trim());
        res.setReceiverGender(gender != null ? gender : "Other");
        res.setReceiverEmail(email.trim());
        res.setReceiverMobile(mobile.trim());
        res.setReceiverAddress(address != null ? address.trim() : "");
        res.setNotes(notes != null ? notes.trim() : "");
        res.setTotalCost(cart.getTotalPrice());
        res.setStatus("Submitted");
        res.setAssignedStaffId(assignedStaffId);
        res.setItems(cart.getItems());

        int reservationId = reservationDAO.createReservation(res);

        if (reservationId > 0) {
            // Đồng bộ sang bảng Contact khách hàng tiếp thị (Phần 5)
            contactDAO.syncContact(fullName.trim(), gender != null ? gender : "Other", email.trim(), mobile.trim(), address, currentUser != null ? currentUser.getId() : null);

            // shortcut: mô phỏng gửi email xác nhận đặt lịch
            System.out.println("[EMAIL SIMULATION] Xác nhận đặt lịch #" + reservationId + " gửi tới " + email);

            // Xóa sạch giỏ hàng sau khi đặt thành công
            cart.clear();

            response.sendRedirect(request.getContextPath() + "/reservation-complete?id=" + reservationId);
        } else {
            forwardWithError(request, response, "Đặt lịch thất bại do dịch vụ đã hết lượt hoặc lỗi kỹ thuật. Vui lòng thử lại.", cart, currentUser);
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String message, Cart cart, User currentUser)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.setAttribute("cart", cart);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("receiverFullName", request.getParameter("receiverFullName"));
        request.setAttribute("receiverGender", request.getParameter("receiverGender"));
        request.setAttribute("receiverEmail", request.getParameter("receiverEmail"));
        request.setAttribute("receiverMobile", request.getParameter("receiverMobile"));
        request.setAttribute("receiverAddress", request.getParameter("receiverAddress"));
        request.setAttribute("checkupTime", request.getParameter("checkupTime"));
        request.setAttribute("notes", request.getParameter("notes"));
        request.getRequestDispatcher("/WEB-INF/views/pub/reservation-contact.jsp").forward(request, response);
    }
}

