package com.childrencare.controller.manager;

import com.childrencare.dao.SliderDAO;
import com.childrencare.model.Slider;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [20] Sliders List & [21] Slider Details: Quản lý banner trượt trang chủ (Manager).
 */
@WebServlet("/manager/sliders")
public class ManagerSlidersServlet extends HttpServlet {

    private final SliderDAO sliderDAO = new SliderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");

        int page = 1;
        int pageSize = 10;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {}
        }

        List<Slider> sliders = sliderDAO.getSliders(status, keyword, page, pageSize);
        int totalSliders = sliderDAO.countSliders(status, keyword);
        int totalPages = (int) Math.ceil((double) totalSliders / pageSize);

        request.setAttribute("sliders", sliders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalSliders", totalSliders);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/manager/sliders-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String title = request.getParameter("title");
            String imageUrl = request.getParameter("imageUrl");
            String backLink = request.getParameter("backLink");
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");

            Slider s = new Slider(0, title.trim(), imageUrl.trim(), backLink.trim(), status != null ? status : "Active", notes);
            if (sliderDAO.insert(s)) {
                request.getSession().setAttribute("flashSuccess", "Thêm slider thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Thêm slider thất bại.");
            }
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String imageUrl = request.getParameter("imageUrl");
            String backLink = request.getParameter("backLink");
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");

            Slider s = new Slider(id, title.trim(), imageUrl.trim(), backLink.trim(), status, notes);
            if (sliderDAO.update(s)) {
                request.getSession().setAttribute("flashSuccess", "Cập nhật slider thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Cập nhật slider thất bại.");
            }
        } else if ("toggle".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String newStatus = request.getParameter("newStatus");
            sliderDAO.toggleStatus(id, newStatus);
        }

        response.sendRedirect(request.getContextPath() + "/manager/sliders");
    }
}

