package com.childrencare.dao;

import com.childrencare.model.Setting;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Settings.
 * Hỗ trợ lấy danh mục theo Type, phân trang, tìm kiếm và CRUD.
 */
public class SettingDAO {

    /**
     * Lấy danh sách setting đang hoạt động (Active) theo loại (UserRole, PostCategory, ServiceCategory).
     */
    public List<Setting> getActiveByType(String type) {
        List<Setting> list = new ArrayList<>();
        String sql = "SELECT Id, Type, Name, Value, Description, Status FROM Settings WHERE Type = ? AND Status = 'Active' ORDER BY Name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type);
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
     * Lấy chi tiết setting theo ID.
     */
    public Setting getById(int id) {
        String sql = "SELECT Id, Type, Name, Value, Description, Status FROM Settings WHERE Id = ?";
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
     * Tìm kiếm và phân trang danh sách setting (dành cho Admin).
     */
    public List<Setting> getSettings(String type, String status, String keyword, int page, int pageSize) {
        List<Setting> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT Id, Type, Name, Value, Description, Status FROM Settings WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND Type = ?");
            params.add(type);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Name LIKE ? OR Value LIKE ?)");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        sql.append(" ORDER BY Type ASC, Id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
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
     * Đếm tổng số bản ghi phục vụ phân trang.
     */
    public int countSettings(String type, String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Settings WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (type != null && !type.trim().isEmpty()) {
            sql.append(" AND Type = ?");
            params.add(type);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Name LIKE ? OR Value LIKE ?)");
            params.add("%" + keyword.trim() + "%");
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
     * Thêm mới một Setting.
     */
    public boolean insert(Setting s) {
        String sql = "INSERT INTO Settings (Type, Name, Value, Description, Status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getType());
            ps.setString(2, s.getName());
            ps.setString(3, s.getValue());
            ps.setString(4, s.getDescription());
            ps.setString(5, s.getStatus() != null ? s.getStatus() : "Active");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật một Setting.
     */
    public boolean update(Setting s) {
        String sql = "UPDATE Settings SET Type = ?, Name = ?, Value = ?, Description = ?, Status = ? WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getType());
            ps.setString(2, s.getName());
            ps.setString(3, s.getValue());
            ps.setString(4, s.getDescription());
            ps.setString(5, s.getStatus());
            ps.setInt(6, s.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa mềm (Soft delete) Setting bằng cách đổi trạng thái sang Inactive.
     */
    public boolean toggleStatus(int id, String newStatus) {
        String sql = "UPDATE Settings SET Status = ? WHERE Id = ?";
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

    private Setting mapResultSet(ResultSet rs) throws SQLException {
        return new Setting(
                rs.getInt("Id"),
                rs.getString("Type"),
                rs.getString("Name"),
                rs.getString("Value"),
                rs.getString("Description"),
                rs.getString("Status")
        );
    }
}

