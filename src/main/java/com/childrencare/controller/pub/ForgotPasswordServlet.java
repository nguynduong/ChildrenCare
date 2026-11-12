package com.childrencare.controller.pub;

import com.childrencare.dao.UserDAO;
import com.childrencare.model.User;
import com.childrencare.util.SecurityUtils;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [12] Reset Password: Quên mật khẩu & Đặt lại mật khẩu qua liên kết xác thực email.
 */
@WebServlet({"/forgot-password", "/reset-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/reset-password".equals(path)) {
            String token = request.getParameter("token");
            if (token == null || token.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/forgot-password");
                return;
            }
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // 1. Xử lý yêu cầu gửi link quên mật khẩu
        if ("/forgot-password".equals(path)) {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập địa chỉ email của bạn.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            User user = userDAO.getByEmail(email.trim());
            if (user != null) {
                String resetToken = SecurityUtils.generateRandomToken(32);
                Timestamp expiry = Timestamp.from(Instant.now().plus(1, ChronoUnit.HOURS)); // Hạn 1 giờ
                userDAO.saveResetToken(email.trim(), resetToken, expiry);

                // shortcut: mô phỏng gửi email đặt lại mật khẩu
                String resetLink = request.getRequestURL().toString().replace("/forgot-password", "/reset-password?token=" + resetToken);
                System.out.println("[EMAIL SIMULATION] Đặt lại mật khẩu gửi tới " + email + ": " + resetLink);
            }

            // Luôn thông báo thành công dù email có tồn tại hay không để chống dò email
            request.setAttribute("successMessage", "Nếu email của bạn tồn tại trong hệ thống, hướng dẫn đặt lại mật khẩu đã được gửi đến hòm thư.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // 2. Xử lý form đặt mật khẩu mới: /reset-password
        if ("/reset-password".equals(path)) {
            String token = request.getParameter("token");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || newPassword.length() < 8 || !newPassword.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$")) {
                request.setAttribute("token", token);
                request.setAttribute("errorMessage", "Mật khẩu mới phải từ 8 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường và 1 số.");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("token", token);
                request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
                request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                return;
            }

            String hashed = SecurityUtils.hashPassword(newPassword);
            if (userDAO.resetPasswordWithToken(token, hashed)) {
                request.setAttribute("successMessage", "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập ngay.");
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Liên kết đổi mật khẩu không hợp lệ hoặc đã hết hạn.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
            }
        }
    }
}

