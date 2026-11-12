package com.childrencare.controller.pub;

import com.childrencare.dao.ServiceDAO;
import com.childrencare.dao.SettingDAO;
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
 * Màn hình [4] Services List: Danh sách dịch vụ công khai có lọc danh mục, tìm kiếm và phân trang.
 */
@WebServlet("/services")
public class ServiceListServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final SettingDAO settingDAO = new SettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String categoryStr = request.getParameter("categoryId");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");

        Integer categoryId = (categoryStr != null && !categoryStr.trim().isEmpty()) ? Integer.parseInt(categoryStr) : null;
        int page = 1;
        int pageSize = 6;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {}
        }

        List<Service> services = serviceDAO.getPublicServices(categoryId, keyword, page, pageSize);
        int totalServices = serviceDAO.countPublicServices(categoryId, keyword);
        int totalPages = (int) Math.ceil((double) totalServices / pageSize);

        List<Setting> categories = settingDAO.getActiveByType("ServiceCategory");

        request.setAttribute("services", services);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalServices", totalServices);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("keyword", keyword);
        request.setAttribute("activePage", "services");

        request.getRequestDispatcher("/WEB-INF/views/pub/service-list.jsp").forward(request, response);
    }
}

