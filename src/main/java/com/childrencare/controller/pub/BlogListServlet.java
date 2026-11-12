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
 * Màn hình [2] Blogs List: Danh sách bài viết công khai, phân trang, lọc theo danh mục & tìm kiếm.
 */
@WebServlet("/blogs")
public class BlogListServlet extends HttpServlet {

    private final PostDAO postDAO = new PostDAO();
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

        List<Post> posts = postDAO.getPublicPosts(categoryId, keyword, page, pageSize);
        int totalPosts = postDAO.countPublicPosts(categoryId, keyword);
        int totalPages = (int) Math.ceil((double) totalPosts / pageSize);

        List<Setting> categories = settingDAO.getActiveByType("PostCategory");
        List<Post> latestPosts = postDAO.getLatestPosts(5);

        request.setAttribute("posts", posts);
        request.setAttribute("categories", categories);
        request.setAttribute("latestPosts", latestPosts);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("keyword", keyword);
        request.setAttribute("activePage", "blogs");

        request.getRequestDispatcher("/WEB-INF/views/pub/blog-list.jsp").forward(request, response);
    }
}

