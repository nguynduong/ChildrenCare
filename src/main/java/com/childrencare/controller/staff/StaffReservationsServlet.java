package com.childrencare.controller.staff;

import com.childrencare.dao.ReservationDAO;
import com.childrencare.dao.UserDAO;
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
 * Màn hình [28] Reservations List & [29] Reservation Details: Quản lý danh sách đặt lịch cho Staff & Manager.
 */
@WebServlet({"/staff/reservations", "/manager/reservations", "/staff/reservation-detail"})
public class StaffReservationsServlet extends HttpServlet {

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        String path = request.getServletPath();

        // 1. Xem chi tiết đơn đặt lịch
        if ("/staff/reservation-detail".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    Reservation reservation = reservationDAO.getById(id);
                    if (reservation != null) {
                        List<User> doctors = userDAO.getActiveStaffByRole(2);
                        List<User> nurses = userDAO.getActiveStaffByRole(3);
                        List<User> allStaff = new ArrayList<>();
                        allStaff.addAll(doctors);
                        allStaff.addAll(nurses);

                        request.setAttribute("reservation", reservation);
                        request.setAttribute("allStaff", allStaff);
                        request.getRequestDispatcher("/WEB-INF/views/staff/reservation-detail.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + (currentUser.getRoleId() >= 4 ? "/manager/reservations" : "/staff/reservations"));
            return;
        }

        // 2. Danh sách đặt lịch
        // Bác sĩ / Y tá (Role 2, 3) chỉ thấy lịch được phân công cho mình. Manager/Admin (Role 4, 5) thấy tất cả.
        Integer filterStaffId = null;
        if (currentUser.getRoleId() == 2 || currentUser.getRoleId() == 3) {
            filterStaffId = currentUser.getId();
        } else {
            String staffParam = request.getParameter("staffId");
            if (staffParam != null && !staffParam.trim().isEmpty()) {
                try {
                    filterStaffId = Integer.parseInt(staffParam);
                } catch (NumberFormatException ignored) {}
            }
        }

        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String status = request.getParameter("status");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");

        int page = 1;
        int pageSize = 10;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {}
        }

        List<Reservation> reservations = reservationDAO.getStaffReservations(filterStaffId, fromDate, toDate, status, keyword, page, pageSize);
        int totalReservations = reservationDAO.countStaffReservations(filterStaffId, fromDate, toDate, status, keyword);
        int totalPages = (int) Math.ceil((double) totalReservations / pageSize);

        List<User> allDoctors = userDAO.getActiveStaffByRole(2);
        List<User> allNurses = userDAO.getActiveStaffByRole(3);
        List<User> allStaff = new ArrayList<>();
        allStaff.addAll(allDoctors);
        allStaff.addAll(allNurses);

        request.setAttribute("reservations", reservations);
        request.setAttribute("allStaff", allStaff);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("selectedStaffId", filterStaffId);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/staff/reservations-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));

        if ("updateStatus".equals(action)) {
            String newStatus = request.getParameter("status");
            if (reservationDAO.updateStatus(reservationId, newStatus)) {
                request.getSession().setAttribute("flashSuccess", "Cập nhật trạng thái thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Cập nhật trạng thái thất bại.");
            }
        } else if ("assignStaff".equals(action)) {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            if (reservationDAO.assignStaff(reservationId, staffId)) {
                request.getSession().setAttribute("flashSuccess", "Phân công nhân viên thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Phân công nhân viên thất bại.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/staff/reservation-detail?id=" + reservationId);
    }
}

