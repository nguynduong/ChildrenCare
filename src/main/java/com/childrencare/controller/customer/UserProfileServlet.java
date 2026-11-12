package com.childrencare.controller.customer;

import com.childrencare.dao.UserDAO;
import com.childrencare.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [14] User Profile: Xem và chỉnh sửa thông tin cá nhân của người dùng đang đăng nhập.
 */
@WebServlet("/profile")
public class UserProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        // Lấy lại dữ liệu mới nhất từ DB
        User user = userDAO.getById(currentUser.getId());
        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        String fullName = request.getParameter("fullName");
        String gender = request.getParameter("gender");
        String mobile = request.getParameter("mobile");
        String address = request.getParameter("address");
        String avatarUrl = request.getParameter("avatarUrl");

        if (fullName == null || fullName.trim().length() < 2 || fullName.trim().length() > 100) {
            request.setAttribute("errorMessage", "Họ và tên phải từ 2 đến 100 ký tự.");
            request.setAttribute("user", currentUser);
            request.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(request, response);
            return;
        }

        if (mobile == null || !mobile.matches("^0\\d{9}$")) {
            request.setAttribute("errorMessage", "Số điện thoại phải có đúng 10 chữ số bắt đầu bằng 0.");
            request.setAttribute("user", currentUser);
            request.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(request, response);
            return;
        }

        currentUser.setFullName(fullName.trim());
        currentUser.setGender(gender != null ? gender : "Other");
        currentUser.setMobile(mobile.trim());
        currentUser.setAddress(address != null ? address.trim() : "");
        if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
            currentUser.setAvatarUrl(avatarUrl.trim());
        }

        if (userDAO.updateProfile(currentUser)) {
            session.setAttribute("currentUser", currentUser);
            request.setAttribute("successMessage", "Cập nhật hồ sơ cá nhân thành công!");
        } else {
            request.setAttribute("errorMessage", "Có lỗi xảy ra khi lưu thông tin.");
        }

        request.setAttribute("user", currentUser);
        request.getRequestDispatcher("/WEB-INF/views/customer/profile.jsp").forward(request, response);
    }
}

