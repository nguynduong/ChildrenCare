package com.childrencare.controller.pub;

import com.childrencare.dao.PostDAO;
import com.childrencare.dao.ServiceDAO;
import com.childrencare.dao.SliderDAO;
import com.childrencare.model.Post;
import com.childrencare.model.Service;
import com.childrencare.model.Slider;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Màn hình [1] Home Page: Hiển thị Sliders, Hot posts, Featured services & sider bài viết mới nhất.
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final SliderDAO sliderDAO = new SliderDAO();
    private final PostDAO postDAO = new PostDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Slider> sliders = sliderDAO.getActiveSliders();
        List<Post> hotPosts = postDAO.getFeaturedPosts(4);
        List<Service> featuredServices = serviceDAO.getFeaturedServices(6);
        List<Post> latestPosts = postDAO.getLatestPosts(5);

        request.setAttribute("sliders", sliders);
        request.setAttribute("hotPosts", hotPosts);
        request.setAttribute("featuredServices", featuredServices);
        request.setAttribute("latestPosts", latestPosts);
        request.setAttribute("activePage", "home");

        request.getRequestDispatcher("/WEB-INF/views/pub/home.jsp").forward(request, response);
    }
}

