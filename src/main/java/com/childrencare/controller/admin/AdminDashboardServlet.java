package com.childrencare.controller.admin;

import com.childrencare.dao.ContactDAO;
import com.childrencare.dao.DashboardDAO;
import com.childrencare.dao.UserDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [31] Admin Dashboard: Thống kê số lượng đặt lịch, doanh thu, khách hàng, đánh giá và xu hướng 7 ngày.
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ContactDAO contactDAO = new ContactDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Integer> reservationStats = dashboardDAO.getReservationStats();
        BigDecimal totalRevenue = dashboardDAO.getTotalRevenue();
        Map<String, BigDecimal> revenueByCategory = dashboardDAO.getRevenueByCategory();
        double avgRating = dashboardDAO.getAverageRating();
        Map<String, Integer> trend7Days = dashboardDAO.getReservationTrend7Days();

        int totalUsers = userDAO.countUsers(null, null, null, null);
        int totalContacts = contactDAO.countContacts(null, null);

        request.setAttribute("stats", reservationStats);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("revenueByCategory", revenueByCategory);
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("trend7Days", trend7Days);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalContacts", totalContacts);

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }
}

