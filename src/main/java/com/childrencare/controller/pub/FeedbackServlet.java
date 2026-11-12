package com.childrencare.controller.pub;

import com.childrencare.dao.ContactDAO;
import com.childrencare.dao.FeedbackDAO;
import com.childrencare.dao.ServiceDAO;
import com.childrencare.model.Feedback;
import com.childrencare.model.Service;
import com.childrencare.model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [9] Feedback (Public) & [26], [27] Feedbacks List/Details (Manager).
 */
@WebServlet({"/feedback", "/manager/feedbacks"})
public class FeedbackServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final ContactDAO contactDAO = new ContactDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // 1. Quản lý danh sách Feedback (Manager)
        if ("/manager/feedbacks".equals(path)) {
            String serviceStr = request.getParameter("serviceId");
            String starStr = request.getParameter("ratedStar");
            String status = request.getParameter("status");
            String keyword = request.getParameter("keyword");
            String pageStr = request.getParameter("page");

            Integer serviceId = (serviceStr != null && !serviceStr.trim().isEmpty()) ? Integer.parseInt(serviceStr) : null;
            Integer ratedStar = (starStr != null && !starStr.trim().isEmpty()) ? Integer.parseInt(starStr) : null;
            int page = 1;
            int pageSize = 10;
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                try {
                    page = Math.max(1, Integer.parseInt(pageStr));
                } catch (NumberFormatException ignored) {}
            }

            List<Feedback> feedbacks = feedbackDAO.getFeedbacks(serviceId, ratedStar, status, keyword, page, pageSize);
            int totalFeedbacks = feedbackDAO.countFeedbacks(serviceId, ratedStar, status, keyword);
            int totalPages = (int) Math.ceil((double) totalFeedbacks / pageSize);

            List<Service> services = serviceDAO.getPublicServices(null, null, 1, 100);

            request.setAttribute("feedbacks", feedbacks);
            request.setAttribute("services", services);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalFeedbacks", totalFeedbacks);
            request.setAttribute("selectedServiceId", serviceId);
            request.setAttribute("selectedRatedStar", ratedStar);
            request.setAttribute("selectedStatus", status);
            request.setAttribute("keyword", keyword);

            request.getRequestDispatcher("/WEB-INF/views/manager/feedbacks-list.jsp").forward(request, response);
            return;
        }

        // 2. Giao diện gửi Feedback (Public)
        String srvIdStr = request.getParameter("serviceId");
        if (srvIdStr != null && !srvIdStr.trim().isEmpty()) {
            try {
                int srvId = Integer.parseInt(srvIdStr);
                Service s = serviceDAO.getById(srvId);
                request.setAttribute("selectedService", s);
            } catch (NumberFormatException ignored) {}
        }

        List<Service> services = serviceDAO.getPublicServices(null, null, 1, 100);
        request.setAttribute("services", services);
        request.setAttribute("activePage", "feedback");

        request.getRequestDispatcher("/WEB-INF/views/pub/feedback.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // 1. Quản lý đổi trạng thái ẩn/hiện Feedback (Manager)
        if ("/manager/feedbacks".equals(path)) {
            String action = request.getParameter("action");
            if ("toggle".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String newStatus = request.getParameter("newStatus");
                feedbackDAO.toggleStatus(id, newStatus);
            }
            response.sendRedirect(request.getContextPath() + "/manager/feedbacks");
            return;
        }

        // 2. Khách gửi Feedback mới
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String fullName = request.getParameter("fullName");
        String gender = request.getParameter("gender");
        String email = request.getParameter("email");
        String mobile = request.getParameter("mobile");
        String serviceStr = request.getParameter("serviceId");
        String starStr = request.getParameter("ratedStar");
        String content = request.getParameter("content");
        String imgUrl = request.getParameter("imageUrl");

        Integer serviceId = (serviceStr != null && !serviceStr.trim().isEmpty()) ? Integer.parseInt(serviceStr) : null;
        int ratedStar = 5;
        try {
            if (starStr != null) {
                ratedStar = Math.min(5, Math.max(1, Integer.parseInt(starStr)));
            }
        } catch (NumberFormatException ignored) {}

        Feedback fb = new Feedback();
        fb.setFullName(fullName != null ? fullName.trim() : (currentUser != null ? currentUser.getFullName() : ""));
        fb.setGender(gender != null ? gender : "Other");
        fb.setEmail(email != null ? email.trim() : (currentUser != null ? currentUser.getEmail() : ""));
        fb.setMobile(mobile != null ? mobile.trim() : (currentUser != null ? currentUser.getMobile() : ""));
        fb.setServiceId(serviceId);
        fb.setRatedStar(ratedStar);
        fb.setContent(content != null ? content.trim() : "");
        fb.setStatus("Published");

        if (imgUrl != null && !imgUrl.trim().isEmpty()) {
            List<String> imgs = new ArrayList<>();
            imgs.add(imgUrl.trim());
            fb.setImages(imgs);
        }

        if (feedbackDAO.insertFeedback(fb)) {
            // Tự động đồng bộ Contact marketing
            contactDAO.syncContact(fb.getFullName(), fb.getGender(), fb.getEmail(), fb.getMobile(), null, currentUser != null ? currentUser.getId() : null);
            request.setAttribute("successMessage", "Cảm ơn bạn đã gửi đánh giá! Ý kiến của bạn sẽ giúp ChildrenCare nâng cao chất lượng phục vụ.");
        } else {
            request.setAttribute("errorMessage", "Gửi đánh giá không thành công. Vui lòng kiểm tra lại thông tin.");
        }

        List<Service> services = serviceDAO.getPublicServices(null, null, 1, 100);
        request.setAttribute("services", services);
        request.setAttribute("activePage", "feedback");
        request.getRequestDispatcher("/WEB-INF/views/pub/feedback.jsp").forward(request, response);
    }
}

