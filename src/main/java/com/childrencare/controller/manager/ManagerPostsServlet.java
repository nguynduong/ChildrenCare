package com.childrencare.controller.manager;

import com.childrencare.dao.PostDAO;
import com.childrencare.dao.SettingDAO;
import com.childrencare.model.Post;
import com.childrencare.model.Setting;
import com.childrencare.model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Màn hình [18] Posts List & [19] Post Details: Quản lý bài viết dành cho Manager.
 */
@WebServlet("/manager/posts")
public class ManagerPostsServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();
    private final SettingDAO settingDAO = new SettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String categoryStr = request.getParameter("categoryId");
        String status = request.getParameter("status");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("page");

        Integer categoryId = (categoryStr != null && !categoryStr.trim().isEmpty()) ? Integer.parseInt(categoryStr) : null;
        int page = 1;
        int pageSize = 10;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Math.max(1, Integer.parseInt(pageStr));
            } catch (NumberFormatException ignored) {}
        }

        List<Post> posts = postDAO.getManagerPosts(categoryId, null, status, keyword, page, pageSize);
        int totalPosts = postDAO.countManagerPosts(categoryId, null, status, keyword);
        int totalPages = (int) Math.ceil((double) totalPosts / pageSize);

        List<Setting> categories = settingDAO.getActiveByType("PostCategory");

        request.setAttribute("posts", posts);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/manager/posts-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String title = request.getParameter("title");
            String thumbnail = request.getParameter("thumbnail");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String briefInfo = request.getParameter("briefInfo");
            String description = request.getParameter("description");
            boolean isFeatured = "on".equalsIgnoreCase(request.getParameter("isFeatured")) || "true".equalsIgnoreCase(request.getParameter("isFeatured"));
            String status = request.getParameter("status");

            Post p = new Post();
            p.setTitle(title.trim());
            p.setThumbnail(thumbnail != null ? thumbnail.trim() : "https://via.placeholder.com/600x400?text=No+Image");
            p.setCategoryId(categoryId);
            p.setAuthorId(currentUser.getId());
            p.setBriefInfo(briefInfo.trim());
            p.setDescription(description);
            p.setFeatured(isFeatured);
            p.setStatus(status != null ? status : "Hidden");

            if (postDAO.insert(p)) {
                request.getSession().setAttribute("flashSuccess", "Thêm bài viết mới thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Thêm bài viết thất bại.");
            }
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String thumbnail = request.getParameter("thumbnail");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String briefInfo = request.getParameter("briefInfo");
            String description = request.getParameter("description");
            boolean isFeatured = "on".equalsIgnoreCase(request.getParameter("isFeatured")) || "true".equalsIgnoreCase(request.getParameter("isFeatured"));
            String status = request.getParameter("status");

            Post p = new Post();
            p.setId(id);
            p.setTitle(title.trim());
            p.setThumbnail(thumbnail != null ? thumbnail.trim() : "");
            p.setCategoryId(categoryId);
            p.setBriefInfo(briefInfo.trim());
            p.setDescription(description);
            p.setFeatured(isFeatured);
            p.setStatus(status);

            if (postDAO.update(p)) {
                request.getSession().setAttribute("flashSuccess", "Cập nhật bài viết thành công!");
            } else {
                request.getSession().setAttribute("flashError", "Cập nhật bài viết thất bại.");
            }
        } else if ("toggle".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String newStatus = request.getParameter("newStatus");
            postDAO.toggleStatus(id, newStatus);
        }

        response.sendRedirect(request.getContextPath() + "/manager/posts");
    }
}

