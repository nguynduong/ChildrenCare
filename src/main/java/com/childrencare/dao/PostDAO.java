package com.childrencare.dao;

import com.childrencare.model.Post;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Posts.
 */
public class PostDAO {

    /**
     * Lấy danh sách bài viết nổi bật (Hot Posts) hiển thị ở Trang chủ.
     */
    public List<Post> getFeaturedPosts(int limit) {
        List<Post> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, s.Name AS CategoryName, u.FullName AS AuthorName " +
                     "FROM Posts p " +
                     "LEFT JOIN Settings s ON p.CategoryId = s.Id " +
                     "LEFT JOIN Users u ON p.AuthorId = u.Id " +
                     "WHERE p.Status = 'Published' AND p.IsFeatured = 1 " +
                     "ORDER BY p.UpdatedDate DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy các bài viết mới nhất phục vụ sider/sidebar.
     */
    public List<Post> getLatestPosts(int limit) {
        List<Post> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, s.Name AS CategoryName, u.FullName AS AuthorName " +
                     "FROM Posts p " +
                     "LEFT JOIN Settings s ON p.CategoryId = s.Id " +
                     "LEFT JOIN Users u ON p.AuthorId = u.Id " +
                     "WHERE p.Status = 'Published' " +
                     "ORDER BY p.UpdatedDate DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách bài viết công khai (Blogs List) có tìm kiếm, lọc danh mục, phân trang.
     */
    public List<Post> getPublicPosts(Integer categoryId, String keyword, int page, int pageSize) {
        List<Post> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, s.Name AS CategoryName, u.FullName AS AuthorName " +
            "FROM Posts p " +
            "LEFT JOIN Settings s ON p.CategoryId = s.Id " +
            "LEFT JOIN Users u ON p.AuthorId = u.Id " +
            "WHERE p.Status = 'Published'"
        );
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryId = ?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.Title LIKE ? OR p.BriefInfo LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY p.UpdatedDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm tổng số bài viết công khai phục vụ phân trang.
     */
    public int countPublicPosts(Integer categoryId, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Posts p WHERE p.Status = 'Published'");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryId = ?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.Title LIKE ? OR p.BriefInfo LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy chi tiết bài viết theo ID.
     */
    public Post getById(int id) {
        String sql = "SELECT p.*, s.Name AS CategoryName, u.FullName AS AuthorName " +
                     "FROM Posts p " +
                     "LEFT JOIN Settings s ON p.CategoryId = s.Id " +
                     "LEFT JOIN Users u ON p.AuthorId = u.Id " +
                     "WHERE p.Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Quản lý danh sách bài viết (Manager) có lọc theo Category, Author, Status, phân trang.
     */
    public List<Post> getManagerPosts(Integer categoryId, Integer authorId, String status, String keyword, int page, int pageSize) {
        List<Post> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, s.Name AS CategoryName, u.FullName AS AuthorName " +
            "FROM Posts p " +
            "LEFT JOIN Settings s ON p.CategoryId = s.Id " +
            "LEFT JOIN Users u ON p.AuthorId = u.Id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryId = ?");
            params.add(categoryId);
        }
        if (authorId != null && authorId > 0) {
            sql.append(" AND p.AuthorId = ?");
            params.add(authorId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND p.Title LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }

        sql.append(" ORDER BY p.Id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm tổng số bài viết trong quản lý.
     */
    public int countManagerPosts(Integer categoryId, Integer authorId, String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Posts p WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.CategoryId = ?");
            params.add(categoryId);
        }
        if (authorId != null && authorId > 0) {
            sql.append(" AND p.AuthorId = ?");
            params.add(authorId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND p.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND p.Title LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Thêm bài viết mới.
     */
    public boolean insert(Post p) {
        String sql = "INSERT INTO Posts (Title, Thumbnail, CategoryId, AuthorId, BriefInfo, Description, IsFeatured, Status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getTitle());
            ps.setString(2, p.getThumbnail());
            ps.setInt(3, p.getCategoryId());
            ps.setInt(4, p.getAuthorId());
            ps.setString(5, p.getBriefInfo());
            ps.setString(6, p.getDescription());
            ps.setBoolean(7, p.isFeatured());
            ps.setString(8, p.getStatus() != null ? p.getStatus() : "Hidden");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật bài viết.
     */
    public boolean update(Post p) {
        String sql = "UPDATE Posts SET Title = ?, Thumbnail = ?, CategoryId = ?, BriefInfo = ?, Description = ?, " +
                     "IsFeatured = ?, Status = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getTitle());
            ps.setString(2, p.getThumbnail());
            ps.setInt(3, p.getCategoryId());
            ps.setString(4, p.getBriefInfo());
            ps.setString(5, p.getDescription());
            ps.setBoolean(6, p.isFeatured());
            ps.setString(7, p.getStatus());
            ps.setInt(8, p.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Bật/tắt trạng thái (Published / Hidden).
     */
    public boolean toggleStatus(int id, String newStatus) {
        String sql = "UPDATE Posts SET Status = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Post mapResultSet(ResultSet rs) throws SQLException {
        Post p = new Post();
        p.setId(rs.getInt("Id"));
        p.setTitle(rs.getString("Title"));
        p.setThumbnail(rs.getString("Thumbnail"));
        p.setCategoryId(rs.getInt("CategoryId"));
        try {
            p.setCategoryName(rs.getString("CategoryName"));
        } catch (SQLException ignored) {}
        p.setAuthorId(rs.getInt("AuthorId"));
        try {
            p.setAuthorName(rs.getString("AuthorName"));
        } catch (SQLException ignored) {}
        p.setBriefInfo(rs.getString("BriefInfo"));
        p.setDescription(rs.getString("Description"));
        p.setFeatured(rs.getBoolean("IsFeatured"));
        p.setStatus(rs.getString("Status"));
        p.setCreatedDate(rs.getTimestamp("CreatedDate"));
        p.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return p;
    }
}

