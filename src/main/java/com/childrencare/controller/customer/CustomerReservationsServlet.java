package com.childrencare.controller.customer;

import com.childrencare.dao.ReservationDAO;
import com.childrencare.model.Reservation;
import com.childrencare.model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [16] My reservations & [17] Reservation Information: Khách hàng quản lý lịch hẹn cá nhân.
 */
@WebServlet({"/customer/my-reservations", "/customer/reservation-detail"})
public class CustomerReservationsServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        String path = request.getServletPath();

        // 1. Chi tiết lịch hẹn
        if ("/customer/reservation-detail".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    Reservation reservation = reservationDAO.getById(id);
                    // Đảm bảo chỉ xem được lịch hẹn của chính mình
                    if (reservation != null && reservation.getUserId() != null && reservation.getUserId() == currentUser.getId()) {
                        request.setAttribute("reservation", reservation);
                        request.getRequestDispatcher("/WEB-INF/views/customer/reservation-detail.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/customer/my-reservations");
            return;
        }

        // 2. Danh sách lịch hẹn của tôi
        String pageStr = request.getParameter("page");
        int page = 1;
        int pageSize = 5;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {}
        }

        List<Reservation> reservations = reservationDAO.getCustomerReservations(currentUser.getId(), page, pageSize);
        int totalReservations = reservationDAO.countCustomerReservations(currentUser.getId());
        int totalPages = (int) Math.ceil((double) totalReservations / pageSize);

        request.setAttribute("reservations", reservations);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalReservations", totalReservations);

        request.getRequestDispatcher("/WEB-INF/views/customer/my-reservations.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");

        if ("cancel".equals(action)) {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            Reservation res = reservationDAO.getById(reservationId);
            if (res != null && res.getUserId() != null && res.getUserId() == currentUser.getId() && "Submitted".equalsIgnoreCase(res.getStatus())) {
                if (reservationDAO.cancelReservation(reservationId)) {
                    request.getSession().setAttribute("flashSuccess", "Hủy lịch hẹn thành công!");
                } else {
                    request.getSession().setAttribute("flashError", "Hủy lịch hẹn thất bại.");
                }
            } else {
                request.getSession().setAttribute("flashError", "Không thể hủy lịch hẹn ở trạng thái này.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/customer/my-reservations");
    }
}

