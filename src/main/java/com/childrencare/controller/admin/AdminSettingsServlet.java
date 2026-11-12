package com.childrencare.controller.admin;

import com.childrencare.dao.SettingDAO;
import com.childrencare.model.Setting;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [34] Settings List & [35] Setting Details: Quản lý danh mục và cấu hình cho Admin.
 */
@WebServlet("/admin/settings")
public class AdminSettingsServlet extends HttpServlet {

    private final SettingDAO settingDAO = new SettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String type = request.getParameter("type");
        String status = request.getParameter("status");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");

        int page = 1;
        int pageSize = 10;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {
            }
        }

        List<Setting> settings = settingDAO.getSettings(type, status, keyword, page, pageSize);
        int totalSettings = settingDAO.countSettings(type, status, keyword);
        int totalPages = (int) Math.ceil((double) totalSettings / pageSize);

        request.setAttribute("settings", settings);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalSettings", totalSettings);
        request.setAttribute("selectedType", type);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/admin/settings-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String type = request.getParameter("type");
            String name = request.getParameter("name");
            String value = request.getParameter("value");
            String description = request.getParameter("description");
            String status = request.getParameter("status");

            Setting s = new Setting(0, type, name, value, description, status != null ? status : "Active");
            if (settingDAO.insert(s)) {
                request.getSession().setAttribute("flashSuccess", "Thêm cấu hình thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Thêm cấu hình thất bại (có thể trùng loại và tên).");
            }
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String type = request.getParameter("type");
            String name = request.getParameter("name");
            String value = request.getParameter("value");
            String description = request.getParameter("description");
            String status = request.getParameter("status");

            // Role mặc định không được đổi value
            Setting existing = settingDAO.getById(id);
            if (existing != null && "UserRole".equals(existing.getType())) {
                value = existing.getValue(); // Giữ nguyên
            }

            Setting s = new Setting(id, type, name, value, description, status);
            if (settingDAO.update(s)) {
                request.getSession().setAttribute("flashSuccess", "Cập nhật cấu hình thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Cập nhật cấu hình thất bại.");
            }
        } else if ("toggle".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String newStatus = request.getParameter("newStatus");
            settingDAO.toggleStatus(id, newStatus);
        }

        response.sendRedirect(request.getContextPath() + "/admin/settings");
    }
}

