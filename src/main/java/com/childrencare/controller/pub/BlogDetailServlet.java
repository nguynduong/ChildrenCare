package com.childrencare.controller.pub;

import com.childrencare.dao.PostDAO;
import com.childrencare.dao.SettingDAO;
import com.childrencare.model.Post;
import com.childrencare.model.Setting;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [3] Blog Details: Chi tiết bài viết chia sẻ, danh mục và bài viết liên quan.
 */
@WebServlet("/blog-detail")
public class BlogDetailServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();
    private final SettingDAO settingDAO = new SettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/blogs");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Post post = postDAO.getById(id);
            if (post == null || !"Published".equalsIgnoreCase(post.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/blogs");
                return;
            }

            List<Setting> categories = settingDAO.getActiveByType("PostCategory");
            List<Post> latestPosts = postDAO.getLatestPosts(5);

            request.setAttribute("post", post);
            request.setAttribute("categories", categories);
            request.setAttribute("latestPosts", latestPosts);
            request.setAttribute("activePage", "blogs");

            request.getRequestDispatcher("/WEB-INF/views/pub/blog-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/blogs");
        }
    }
}

