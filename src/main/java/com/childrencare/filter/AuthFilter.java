package com.childrencare.filter;

import com.childrencare.model.User;
import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Filter kiểm tra xác thực (Authentication) và phân quyền (Authorization RBAC) theo 5 Role:
 * RoleId 1: Customer
 * RoleId 2: Doctor
 * RoleId 3: Nurse
 * RoleId 4: Manager
 * RoleId 5: Admin
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;
        String path = request.getRequestURI().substring(request.getContextPath().length());

        // Bỏ qua tài nguyên tĩnh (assets, css, js, images)
        if (path.startsWith("/assets/") || path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".png") || path.endsWith(".jpg")) {
            chain.doFilter(req, resp);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra các URL yêu cầu đăng nhập chung
        boolean requiresLogin = path.startsWith("/profile") || 
                                path.startsWith("/change-password") || 
                                path.startsWith("/customer/") || 
                                path.startsWith("/staff/") || 
                                path.startsWith("/manager/") || 
                                path.startsWith("/admin/");

        if (requiresLogin && user == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=" + path);
            return;
        }

        // 2. Phân quyền theo Role cụ thể
        if (user != null) {
            int roleId = user.getRoleId();

            // Khu vực Admin: Chỉ Role 5
            if (path.startsWith("/admin/") && roleId != 5) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            // Khu vực Manager: Role 4 hoặc 5
            if (path.startsWith("/manager/") && roleId != 4 && roleId != 5) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            // Khu vực Staff (Doctor/Nurse): Role 2, 3, 4, 5
            if (path.startsWith("/staff/") && roleId != 2 && roleId != 3 && roleId != 4 && roleId != 5) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {
    }
}

