package com.childrencare.dao;

import com.childrencare.model.Slider;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Sliders.
 */
public class SliderDAO {

    /**
     * Lấy danh sách Slider đang hoạt động (Active) hiển thị trên Trang chủ.
     */
    public List<Slider> getActiveSliders() {
        List<Slider> list = new ArrayList<>();
        String sql = "SELECT * FROM Sliders WHERE Status = 'Active' ORDER BY Id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy chi tiết slider theo ID.
     */
    public Slider getById(int id) {
        String sql = "SELECT * FROM Sliders WHERE Id = ?";
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
     * Quản lý danh sách Slider phân trang và tìm kiếm (Manager).
     */
    public List<Slider> getSliders(String status, String keyword, int page, int pageSize) {
        List<Slider> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Sliders WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Title LIKE ? OR BackLink LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY Id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
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
     * Đếm tổng số Slider phục vụ phân trang.
     */
    public int countSliders(String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Sliders WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Title LIKE ? OR BackLink LIKE ?)");
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
     * Thêm mới Slider.
     */
    public boolean insert(Slider s) {
        String sql = "INSERT INTO Sliders (Title, ImageUrl, BackLink, Status, Notes) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getTitle());
            ps.setString(2, s.getImageUrl());
            ps.setString(3, s.getBackLink());
            ps.setString(4, s.getStatus() != null ? s.getStatus() : "Active");
            ps.setString(5, s.getNotes());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật Slider.
     */
    public boolean update(Slider s) {
        String sql = "UPDATE Sliders SET Title = ?, ImageUrl = ?, BackLink = ?, Status = ?, Notes = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getTitle());
            ps.setString(2, s.getImageUrl());
            ps.setString(3, s.getBackLink());
            ps.setString(4, s.getStatus());
            ps.setString(5, s.getNotes());
            ps.setInt(6, s.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Bật/tắt trạng thái hiển thị (Active/Inactive).
     */
    public boolean toggleStatus(int id, String newStatus) {
        String sql = "UPDATE Sliders SET Status = ?, UpdatedDate = GETDATE() WHERE Id = ?";
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

    private Slider mapResultSet(ResultSet rs) throws SQLException {
        Slider s = new Slider();
        s.setId(rs.getInt("Id"));
        s.setTitle(rs.getString("Title"));
        s.setImageUrl(rs.getString("ImageUrl"));
        s.setBackLink(rs.getString("BackLink"));
        s.setStatus(rs.getString("Status"));
        s.setNotes(rs.getString("Notes"));
        s.setCreatedDate(rs.getTimestamp("CreatedDate"));
        s.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return s;
    }
}

