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
 * Màn hình [11] User Register: Đăng ký tài khoản khách hàng mới và xác thực qua email.
 */
@WebServlet({"/register", "/verify-email"})
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Xử lý xác thực email qua link: /verify-email?token=...
        if ("/verify-email".equals(path)) {
            String token = request.getParameter("token");
            if (token != null && userDAO.verifyEmail(token)) {
                request.setAttribute("successMessage", "Xác thực tài khoản thành công! Bạn có thể đăng nhập ngay bây giờ.");
            } else {
                request.setAttribute("errorMessage", "Liên kết xác thực không hợp lệ hoặc đã hết hạn.");
            }
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String gender = request.getParameter("gender");
        String email = request.getParameter("email");
        String mobile = request.getParameter("mobile");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate dữ liệu theo quy ước chung (Mục 2.3)
        if (fullName == null || fullName.trim().length() < 2 || fullName.trim().length() > 100) {
            forwardWithError(request, response, "Họ và tên phải từ 2 đến 100 ký tự.");
            return;
        }
        if (email == null || !email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            forwardWithError(request, response, "Định dạng email không hợp lệ.");
            return;
        }
        if (mobile == null || !mobile.matches("^0\\d{9}$")) {
            forwardWithError(request, response, "Số điện thoại phải có đúng 10 chữ số và bắt đầu bằng số 0.");
            return;
        }
        if (password == null || password.length() < 8 || !password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$")) {
            forwardWithError(request, response, "Mật khẩu phải từ 8 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường và 1 số.");
            return;
        }
        if (!password.equals(confirmPassword)) {
            forwardWithError(request, response, "Mật khẩu xác nhận không khớp.");
            return;
        }

        // Kiểm tra email đã tồn tại chưa
        if (userDAO.getByEmail(email.trim()) != null) {
            forwardWithError(request, response, "Email này đã được sử dụng. Vui lòng chọn email khác.");
            return;
        }

        // Tạo đối tượng User
        User newUser = new User();
        newUser.setFullName(fullName.trim());
        newUser.setGender(gender != null ? gender : "Other");
        newUser.setEmail(email.trim());
        newUser.setMobile(mobile.trim());
        newUser.setAddress(address != null ? address.trim() : "");
        newUser.setPasswordHash(SecurityUtils.hashPassword(password));
        newUser.setRoleId(1); // 1 = Customer
        newUser.setStatus("Unverified");

        // Sinh token xác thực email (hạn 24 giờ)
        String verifyToken = SecurityUtils.generateRandomToken(32);
        newUser.setVerifyToken(verifyToken);
        newUser.setVerifyTokenExpiry(Timestamp.from(Instant.now().plus(24, ChronoUnit.HOURS)));

        if (userDAO.insert(newUser)) {
            // shortcut: mô phỏng gửi email kích hoạt (in log ra console)
            String verifyLink = request.getRequestURL().toString().replace("/register", "/verify-email?token=" + verifyToken);
            System.out.println("[EMAIL SIMULATION] Kích hoạt tài khoản gửi tới " + email + ": " + verifyLink);

            request.setAttribute("successMessage", "Đăng ký thành công! Vui lòng kiểm tra email để kích hoạt tài khoản.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        } else {
            forwardWithError(request, response, "Có lỗi xảy ra trong quá trình đăng ký. Vui lòng thử lại.");
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.setAttribute("fullName", request.getParameter("fullName"));
        request.setAttribute("gender", request.getParameter("gender"));
        request.setAttribute("email", request.getParameter("email"));
        request.setAttribute("mobile", request.getParameter("mobile"));
        request.setAttribute("address", request.getParameter("address"));
        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    }
}

