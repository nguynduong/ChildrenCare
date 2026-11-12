package com.childrencare.controller.manager;

import com.childrencare.dao.ContactDAO;
import com.childrencare.model.Contact;
import com.childrencare.model.ContactHistory;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [24] Customers List & [25] Customer Details: Quản lý khách hàng và xem lịch sử thay đổi (Manager/Staff).
 */
@WebServlet({"/manager/customers", "/manager/customer-detail"})
public class ManagerCustomersServlet extends HttpServlet {

    private final ContactDAO contactDAO = new ContactDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // 1. Xem chi tiết thông tin và bảng lịch sử thay đổi
        if ("/manager/customer-detail".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    Contact contact = contactDAO.getById(id);
                    if (contact != null) {
                        List<ContactHistory> histories = contactDAO.getHistoriesByContactId(id);
                        request.setAttribute("contact", contact);
                        request.setAttribute("histories", histories);
                        request.getRequestDispatcher("/WEB-INF/views/manager/customer-detail.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect(request.getContextPath() + "/manager/customers");
            return;
        }

        // 2. Danh sách khách hàng
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

        List<Contact> contacts = contactDAO.getContacts(status, keyword, page, pageSize);
        int totalContacts = contactDAO.countContacts(status, keyword);
        int totalPages = (int) Math.ceil((double) totalContacts / pageSize);

        request.setAttribute("contacts", contacts);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalContacts", totalContacts);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/manager/customers-list.jsp").forward(request, response);
    }
}

