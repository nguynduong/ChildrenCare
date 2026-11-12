package com.childrencare.controller.manager;

import com.childrencare.dao.ServiceDAO;
import com.childrencare.dao.SettingDAO;
import com.childrencare.model.Service;
import com.childrencare.model.ServiceImage;
import com.childrencare.model.Setting;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [22] Services List & [23] Service Details: Quản lý gói dịch vụ y tế (Manager/Staff).
 */
@WebServlet("/manager/services")
public class ManagerServicesServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final SettingDAO settingDAO = new SettingDAO();

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

        List<Service> services = serviceDAO.getManagerServices(status, keyword, page, pageSize);
        int totalServices = serviceDAO.countManagerServices(status, keyword);
        int totalPages = (int) Math.ceil((double) totalServices / pageSize);

        List<Setting> categories = settingDAO.getActiveByType("ServiceCategory");

        request.setAttribute("services", services);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalServices", totalServices);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/manager/services-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String title = request.getParameter("title");
            String thumbnail = request.getParameter("thumbnail");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String briefInfo = request.getParameter("briefInfo");
            String description = request.getParameter("description");
            int numberOfPerson = Integer.parseInt(request.getParameter("numberOfPerson"));
            BigDecimal listPrice = new BigDecimal(request.getParameter("listPrice"));
            BigDecimal salePrice = new BigDecimal(request.getParameter("salePrice"));
            int availableQuantity = Integer.parseInt(request.getParameter("availableQuantity"));
            boolean isFeatured = "on".equalsIgnoreCase(request.getParameter("isFeatured")) || "true".equalsIgnoreCase(request.getParameter("isFeatured"));
            String status = request.getParameter("status");

            Service s = new Service();
            s.setTitle(title.trim());
            s.setThumbnail(thumbnail != null ? thumbnail.trim() : "https://via.placeholder.com/600x400?text=Service");
            s.setCategoryId(categoryId);
            s.setBriefInfo(briefInfo.trim());
            s.setDescription(description);
            s.setNumberOfPerson(numberOfPerson);
            s.setListPrice(listPrice);
            s.setSalePrice(salePrice);
            s.setAvailableQuantity(availableQuantity);
            s.setFeatured(isFeatured);
            s.setStatus(status != null ? status : "Inactive");

            int newId = serviceDAO.insert(s);
            if (newId > 0) {
                request.getSession().setAttribute("flashSuccess", "Thêm gói dịch vụ mới thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Thêm gói dịch vụ thất bại.");
            }
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String thumbnail = request.getParameter("thumbnail");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String briefInfo = request.getParameter("briefInfo");
            String description = request.getParameter("description");
            int numberOfPerson = Integer.parseInt(request.getParameter("numberOfPerson"));
            BigDecimal listPrice = new BigDecimal(request.getParameter("listPrice"));
            BigDecimal salePrice = new BigDecimal(request.getParameter("salePrice"));
            int availableQuantity = Integer.parseInt(request.getParameter("availableQuantity"));
            boolean isFeatured = "on".equalsIgnoreCase(request.getParameter("isFeatured")) || "true".equalsIgnoreCase(request.getParameter("isFeatured"));
            String status = request.getParameter("status");

            Service s = new Service();
            s.setId(id);
            s.setTitle(title.trim());
            s.setThumbnail(thumbnail != null ? thumbnail.trim() : "");
            s.setCategoryId(categoryId);
            s.setBriefInfo(briefInfo.trim());
            s.setDescription(description);
            s.setNumberOfPerson(numberOfPerson);
            s.setListPrice(listPrice);
            s.setSalePrice(salePrice);
            s.setAvailableQuantity(availableQuantity);
            s.setFeatured(isFeatured);
            s.setStatus(status);

            if (serviceDAO.update(s)) {
                request.getSession().setAttribute("flashSuccess", "Cập nhật dịch vụ thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Cập nhật dịch vụ thất bại.");
            }
        } else if ("toggle".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String newStatus = request.getParameter("newStatus");
            serviceDAO.toggleStatus(id, newStatus);
        } else if ("addImage".equals(action)) {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            String imageUrl = request.getParameter("imageUrl");
            int sortOrder = Integer.parseInt(request.getParameter("sortOrder"));
            serviceDAO.insertImage(new ServiceImage(0, serviceId, imageUrl.trim(), sortOrder));
            request.getSession().setAttribute("flashSuccess", "Đã thêm ảnh cho dịch vụ.");
        } else if ("deleteImage".equals(action)) {
            int imageId = Integer.parseInt(request.getParameter("imageId"));
            serviceDAO.deleteImage(imageId);
            request.getSession().setAttribute("flashSuccess", "Đã xóa ảnh đính kèm.");
        }

        response.sendRedirect(request.getContextPath() + "/manager/services");
    }
}

