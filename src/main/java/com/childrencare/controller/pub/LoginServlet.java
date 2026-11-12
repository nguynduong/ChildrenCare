package com.childrencare.controller.pub;

import com.childrencare.dao.UserDAO;
import com.childrencare.model.User;
import com.childrencare.util.SecurityUtils;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [10] User Login: Xử lý đăng nhập, kiểm tra tài khoản và chuyển hướng theo Role.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String redirect = request.getParameter("redirect");

        // Validate cơ bản
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ email và mật khẩu.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.getByEmail(email.trim());

        // Thông báo lỗi chung để đảm bảo an toàn bảo mật (không tiết lộ email hay mật khẩu sai)
        if (user == null || !SecurityUtils.checkPassword(password, user.getPasswordHash())) {
            request.setAttribute("errorMessage", "Email hoặc mật khẩu không chính xác.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Kiểm tra trạng thái tài khoản
        if ("Unverified".equalsIgnoreCase(user.getStatus())) {
            request.setAttribute("errorMessage", "Tài khoản chưa được kích hoạt qua email. Vui lòng kiểm tra hòm thư của bạn.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        if ("Inactive".equalsIgnoreCase(user.getStatus())) {
            request.setAttribute("errorMessage", "Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ quản trị viên.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Đăng nhập thành công: Lưu session
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);

        // Điều hướng theo redirectUrl hoặc theo Role
        if (redirect != null && !redirect.trim().isEmpty() && !redirect.contains("login")) {
            response.sendRedirect(request.getContextPath() + redirect);
        } else {
            switch (user.getRoleId()) {
                case 5: // Admin
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    break;
                case 4: // Manager
                    response.sendRedirect(request.getContextPath() + "/manager/reservations");
                    break;
                case 2: // Doctor
                case 3: // Nurse
                    response.sendRedirect(request.getContextPath() + "/staff/reservations");
                    break;
                default: // Customer
                    response.sendRedirect(request.getContextPath() + "/home");
                    break;
            }
        }
    }
}

