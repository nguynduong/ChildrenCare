package com.childrencare.dao;

import com.childrencare.model.User;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Users.
 */
public class UserDAO {

    /**
     * Tìm tài khoản theo Email (dùng cho đăng nhập, kiểm tra trùng lặp).
     */
    public User getByEmail(String email) {
        String sql = "SELECT u.*, s.Name AS RoleName " +
                     "FROM Users u " +
                     "LEFT JOIN Settings s ON u.RoleId = s.Id " +
                     "WHERE LOWER(u.Email) = LOWER(?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
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
     * Tìm tài khoản theo ID.
     */
    public User getById(int id) {
        String sql = "SELECT u.*, s.Name AS RoleName " +
                     "FROM Users u " +
                     "LEFT JOIN Settings s ON u.RoleId = s.Id " +
                     "WHERE u.Id = ?";
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
     * Thêm tài khoản mới (dùng khi khách đăng ký hoặc Admin tạo).
     */
    public boolean insert(User user) {
        String sql = "INSERT INTO Users (FullName, Gender, Email, Mobile, Address, AvatarUrl, PasswordHash, RoleId, Status, VerifyToken, VerifyTokenExpiry) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getGender());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getMobile());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getAvatarUrl());
            ps.setString(7, user.getPasswordHash());
            ps.setInt(8, user.getRoleId());
            ps.setString(9, user.getStatus() != null ? user.getStatus() : "Unverified");
            ps.setString(10, user.getVerifyToken());
            ps.setTimestamp(11, user.getVerifyTokenExpiry());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật thông tin Profile (không sửa Email và Password).
     */
    public boolean updateProfile(User user) {
        String sql = "UPDATE Users SET FullName = ?, Gender = ?, Mobile = ?, Address = ?, AvatarUrl = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getGender());
            ps.setString(3, user.getMobile());
            ps.setString(4, user.getAddress());
            ps.setString(5, user.getAvatarUrl());
            ps.setInt(6, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật mật khẩu mới.
     */
    public boolean updatePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE Users SET PasswordHash = ?, ResetToken = NULL, ResetTokenExpiry = NULL, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xác thực email kích hoạt tài khoản bằng token.
     */
    public boolean verifyEmail(String token) {
        String sql = "UPDATE Users SET Status = 'Active', VerifyToken = NULL, VerifyTokenExpiry = NULL, UpdatedDate = GETDATE() " +
                     "WHERE VerifyToken = ? AND VerifyTokenExpiry > GETDATE()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lưu token quên mật khẩu và hạn sử dụng.
     */
    public boolean saveResetToken(String email, String token, Timestamp expiry) {
        String sql = "UPDATE Users SET ResetToken = ?, ResetTokenExpiry = ?, UpdatedDate = GETDATE() WHERE LOWER(Email) = LOWER(?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, expiry);
            ps.setString(3, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Đổi mật khẩu dựa trên ResetToken hợp lệ.
     */
    public boolean resetPasswordWithToken(String token, String newPasswordHash) {
        String sql = "UPDATE Users SET PasswordHash = ?, ResetToken = NULL, ResetTokenExpiry = NULL, UpdatedDate = GETDATE() " +
                     "WHERE ResetToken = ? AND ResetTokenExpiry > GETDATE()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setString(2, token);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Admin cập nhật Role và Status của User.
     */
    public boolean adminUpdateUser(int userId, int roleId, String status) {
        String sql = "UPDATE Users SET RoleId = ?, Status = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setString(2, status);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Tìm kiếm và phân trang danh sách Users (Admin).
     */
    public List<User> getUsers(String gender, Integer roleId, String status, String keyword, int page, int pageSize) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.*, s.Name AS RoleName FROM Users u " +
            "LEFT JOIN Settings s ON u.RoleId = s.Id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (gender != null && !gender.trim().isEmpty()) {
            sql.append(" AND u.Gender = ?");
            params.add(gender);
        }
        if (roleId != null && roleId > 0) {
            sql.append(" AND u.RoleId = ?");
            params.add(roleId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND u.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Mobile LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY u.Id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
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
     * Đếm tổng số người dùng theo bộ lọc phục vụ phân trang.
     */
    public int countUsers(String gender, Integer roleId, String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Users u WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (gender != null && !gender.trim().isEmpty()) {
            sql.append(" AND u.Gender = ?");
            params.add(gender);
        }
        if (roleId != null && roleId > 0) {
            sql.append(" AND u.RoleId = ?");
            params.add(roleId);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND u.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Mobile LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
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
     * Lấy danh sách nhân viên y tế đang hoạt động (Doctor hoặc Nurse) để phân công lịch hẹn.
     */
    public List<User> getActiveStaffByRole(int roleId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.*, s.Name AS RoleName FROM Users u " +
                     "LEFT JOIN Settings s ON u.RoleId = s.Id " +
                     "WHERE u.RoleId = ? AND u.Status = 'Active' ORDER BY u.FullName ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
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

    private User mapResultSet(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("Id"));
        u.setFullName(rs.getString("FullName"));
        u.setGender(rs.getString("Gender"));
        u.setEmail(rs.getString("Email"));
        u.setMobile(rs.getString("Mobile"));
        u.setAddress(rs.getString("Address"));
        u.setAvatarUrl(rs.getString("AvatarUrl"));
        u.setPasswordHash(rs.getString("PasswordHash"));
        u.setRoleId(rs.getInt("RoleId"));
        try {
            u.setRoleName(rs.getString("RoleName"));
        } catch (SQLException ignored) {
        }
        u.setStatus(rs.getString("Status"));
        u.setVerifyToken(rs.getString("VerifyToken"));
        u.setVerifyTokenExpiry(rs.getTimestamp("VerifyTokenExpiry"));
        u.setResetToken(rs.getString("ResetToken"));
        u.setResetTokenExpiry(rs.getTimestamp("ResetTokenExpiry"));
        u.setCreatedDate(rs.getTimestamp("CreatedDate"));
        u.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return u;
    }
}

