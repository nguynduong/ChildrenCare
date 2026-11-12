package com.childrencare.controller.pub;

import com.childrencare.dao.ServiceDAO;
import com.childrencare.model.Cart;
import com.childrencare.model.ReservationItem;
import com.childrencare.model.Service;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [6] Reservation Details (Giỏ lịch hẹn): Thêm, sửa, xóa dịch vụ trong giỏ.
 */
@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }

        // Cập nhật lại giá mới nhất từ hệ thống cho từng dịch vụ trong giỏ
        for (ReservationItem item : cart.getItems()) {
            Service fresh = serviceDAO.getById(item.getServiceId());
            if (fresh != null) {
                item.setUnitPrice(fresh.getSalePrice());
                item.setServiceTitle(fresh.getTitle());
            }
        }

        request.setAttribute("cart", cart);
        request.getRequestDispatcher("/WEB-INF/views/pub/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int quantity = 1;
            int numberOfPerson = 1;
            try {
                if (request.getParameter("quantity") != null) {
                    quantity = Integer.parseInt(request.getParameter("quantity"));
                }
                if (request.getParameter("numberOfPerson") != null) {
                    numberOfPerson = Integer.parseInt(request.getParameter("numberOfPerson"));
                }
            } catch (NumberFormatException ignored) {}

            Service s = serviceDAO.getById(serviceId);
            if (s != null && "Active".equalsIgnoreCase(s.getStatus())) {
                cart.addItem(s, quantity, numberOfPerson);
            }
            response.sendRedirect(request.getContextPath() + "/cart");
        } else if ("update".equals(action)) {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            int numberOfPerson = Integer.parseInt(request.getParameter("numberOfPerson"));
            cart.updateItem(serviceId, quantity, numberOfPerson);
            response.sendRedirect(request.getContextPath() + "/cart");
        } else if ("remove".equals(action)) {
            int serviceId = Integer.parseInt(request.getParameter("serviceId"));
            cart.removeItem(serviceId);
            response.sendRedirect(request.getContextPath() + "/cart");
        } else if ("clear".equals(action)) {
            cart.clear();
            response.sendRedirect(request.getContextPath() + "/cart");
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }
}

