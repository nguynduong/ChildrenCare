package com.childrencare.controller.customer;

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
 * Màn hình [13] Change Password: Đổi mật khẩu cho người dùng đang đăng nhập.
 */
@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/customer/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        User freshUser = userDAO.getById(currentUser.getId());

        if (freshUser == null || !SecurityUtils.checkPassword(currentPassword, freshUser.getPasswordHash())) {
            request.setAttribute("errorMessage", "Mật khẩu hiện tại không chính xác.");
            request.getRequestDispatcher("/WEB-INF/views/customer/change-password.jsp").forward(request, response);
            return;
        }

        if (newPassword == null || newPassword.length() < 8 || !newPassword.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$")) {
            request.setAttribute("errorMessage", "Mật khẩu mới phải từ 8 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường và 1 số.");
            request.getRequestDispatcher("/WEB-INF/views/customer/change-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.equals(currentPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu mới không được trùng với mật khẩu hiện tại.");
            request.getRequestDispatcher("/WEB-INF/views/customer/change-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/WEB-INF/views/customer/change-password.jsp").forward(request, response);
            return;
        }

        String newHash = SecurityUtils.hashPassword(newPassword);
        if (userDAO.updatePassword(currentUser.getId(), newHash)) {
            request.setAttribute("successMessage", "Đổi mật khẩu thành công!");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi đổi mật khẩu.");
        }
        request.getRequestDispatcher("/WEB-INF/views/customer/change-password.jsp").forward(request, response);
    }
}

