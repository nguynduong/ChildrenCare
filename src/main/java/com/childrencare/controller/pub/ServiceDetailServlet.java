package com.childrencare.controller.pub;

import com.childrencare.dao.FeedbackDAO;
import com.childrencare.dao.ServiceDAO;
import com.childrencare.dao.SettingDAO;
import com.childrencare.model.Feedback;
import com.childrencare.model.Service;
import com.childrencare.model.Setting;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [5] Service Details: Xem chi tiết gói dịch vụ, bộ sưu tập ảnh và các phản hồi.
 */
@WebServlet("/service-detail")
public class ServiceDetailServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final SettingDAO settingDAO = new SettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/services");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Service service = serviceDAO.getById(id);
            if (service == null || !"Active".equalsIgnoreCase(service.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/services");
                return;
            }

            List<Setting> categories = settingDAO.getActiveByType("ServiceCategory");

            request.setAttribute("service", service);
            request.setAttribute("categories", categories);
            request.setAttribute("activePage", "services");

            request.getRequestDispatcher("/WEB-INF/views/pub/service-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/services");
        }
    }
}

