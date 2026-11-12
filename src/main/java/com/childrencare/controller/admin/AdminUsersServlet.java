package com.childrencare.controller.admin;

import com.childrencare.dao.SettingDAO;
import com.childrencare.dao.UserDAO;
import com.childrencare.model.Setting;
import com.childrencare.model.User;
import com.childrencare.util.SecurityUtils;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [32] Users List & [33] User Details: Quản lý danh sách người dùng cho Admin.
 */
@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final SettingDAO settingDAO = new SettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String gender = request.getParameter("gender");
        String roleStr = request.getParameter("roleId");
        String status = request.getParameter("status");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");

        Integer roleId = (roleStr != null && !roleStr.trim().isEmpty()) ? Integer.parseInt(roleStr) : null;
        int page = 1;
        int pageSize = 10;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {
            }
        }

        List<User> users = userDAO.getUsers(gender, roleId, status, keyword, page, pageSize);
        int totalUsers = userDAO.countUsers(gender, roleId, status, keyword);
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

        List<Setting> roles = settingDAO.getActiveByType("UserRole");

        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("selectedGender", gender);
        request.setAttribute("selectedRoleId", roleId);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/admin/users-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            // Admin thêm người dùng mới
            String fullName = request.getParameter("fullName");
            String gender = request.getParameter("gender");
            String email = request.getParameter("email");
            String mobile = request.getParameter("mobile");
            String address = request.getParameter("address");
            int roleId = Integer.parseInt(request.getParameter("roleId"));

            if (userDAO.getByEmail(email) != null) {
                request.getSession().setAttribute("flashError", "Email đã tồn tại trong hệ thống.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            // Sinh mật khẩu ngẫu nhiên cho user
            String randomPass = "Ccs@" + (int)(Math.random() * 900000 + 100000);
            User newUser = new User();
            newUser.setFullName(fullName.trim());
            newUser.setGender(gender != null ? gender : "Other");
            newUser.setEmail(email.trim());
            newUser.setMobile(mobile.trim());
            newUser.setAddress(address != null ? address.trim() : "");
            newUser.setRoleId(roleId);
            newUser.setStatus("Active");
            newUser.setPasswordHash(SecurityUtils.hashPassword(randomPass));

            if (userDAO.insert(newUser)) {
                // shortcut: mô phỏng gửi mật khẩu khởi tạo qua email
                System.out.println("[EMAIL SIMULATION] Mật khẩu tài khoản mới gửi tới " + email + ": " + randomPass);
                request.getSession().setAttribute("flashSuccess", "Thêm người dùng thành công! Mật khẩu khởi tạo: " + randomPass);
            } else {
                request.getSession().setAttribute("flashError", "Thêm người dùng thất bại.");
            }
        } else if ("update".equals(action)) {
            // Admin cập nhật Role và Status
            int userId = Integer.parseInt(request.getParameter("userId"));
            int roleId = Integer.parseInt(request.getParameter("roleId"));
            String status = request.getParameter("status");

            if (userDAO.adminUpdateUser(userId, roleId, status)) {
                request.getSession().setAttribute("flashSuccess", "Cập nhật tài khoản thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Cập nhật thất bại.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}

