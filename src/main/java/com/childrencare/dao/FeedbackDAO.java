package com.childrencare.dao;

import com.childrencare.model.Feedback;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Feedbacks và FeedbackImages.
 */
public class FeedbackDAO {

    /**
     * Gửi phản hồi mới kèm danh sách ảnh đính kèm.
     */
    public boolean insertFeedback(Feedback fb) {
        String sqlFeedback = "INSERT INTO Feedbacks (FullName, Gender, Email, Mobile, ServiceId, RatedStar, Content, Status) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlImg = "INSERT INTO FeedbackImages (FeedbackId, ImageUrl) VALUES (?, ?)";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            int feedbackId;

            try (PreparedStatement ps = conn.prepareStatement(sqlFeedback, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, fb.getFullName());
                ps.setString(2, fb.getGender());
                ps.setString(3, fb.getEmail());
                ps.setString(4, fb.getMobile());
                if (fb.getServiceId() != null && fb.getServiceId() > 0) {
                    ps.setInt(5, fb.getServiceId());
                } else {
                    ps.setNull(5, java.sql.Types.INTEGER);
                }
                ps.setInt(6, fb.getRatedStar());
                ps.setString(7, fb.getContent());
                ps.setString(8, fb.getStatus() != null ? fb.getStatus() : "Published");

                int affected = ps.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        feedbackId = rs.getInt(1);
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (fb.getImages() != null && !fb.getImages().isEmpty()) {
                try (PreparedStatement psImg = conn.prepareStatement(sqlImg)) {
                    for (String imgUrl : fb.getImages()) {
                        psImg.setInt(1, feedbackId);
                        psImg.setString(2, imgUrl);
                        psImg.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Danh sách phản hồi cho Manager / Staff (phân trang, lọc theo sao, dịch vụ, trạng thái, tìm kiếm).
     */
    public List<Feedback> getFeedbacks(Integer serviceId, Integer ratedStar, String status, String keyword, int page, int pageSize) {
        List<Feedback> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT f.*, s.Title AS ServiceTitle " +
            "FROM Feedbacks f " +
            "LEFT JOIN Services s ON f.ServiceId = s.Id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (serviceId != null && serviceId > 0) {
            sql.append(" AND f.ServiceId = ?");
            params.add(serviceId);
        }
        if (ratedStar != null && ratedStar > 0) {
            sql.append(" AND f.RatedStar = ?");
            params.add(ratedStar);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND f.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (f.FullName LIKE ? OR f.Content LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY f.Id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback fb = mapResultSet(rs);
                    fb.setImages(getImagesByFeedbackId(fb.getId()));
                    list.add(fb);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countFeedbacks(Integer serviceId, Integer ratedStar, String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Feedbacks f WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (serviceId != null && serviceId > 0) {
            sql.append(" AND f.ServiceId = ?");
            params.add(serviceId);
        }
        if (ratedStar != null && ratedStar > 0) {
            sql.append(" AND f.RatedStar = ?");
            params.add(ratedStar);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND f.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (f.FullName LIKE ? OR f.Content LIKE ?)");
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

    public Feedback getById(int id) {
        String sql = "SELECT f.*, s.Title AS ServiceTitle FROM Feedbacks f LEFT JOIN Services s ON f.ServiceId = s.Id WHERE f.Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Feedback fb = mapResultSet(rs);
                    fb.setImages(getImagesByFeedbackId(fb.getId()));
                    return fb;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean toggleStatus(int id, String newStatus) {
        String sql = "UPDATE Feedbacks SET Status = ? WHERE Id = ?";
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

    private List<String> getImagesByFeedbackId(int feedbackId) {
        List<String> images = new ArrayList<>();
        String sql = "SELECT ImageUrl FROM FeedbackImages WHERE FeedbackId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    images.add(rs.getString("ImageUrl"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return images;
    }

    private Feedback mapResultSet(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setId(rs.getInt("Id"));
        f.setFullName(rs.getString("FullName"));
        f.setGender(rs.getString("Gender"));
        f.setEmail(rs.getString("Email"));
        f.setMobile(rs.getString("Mobile"));
        int sId = rs.getInt("ServiceId");
        if (!rs.wasNull()) {
            f.setServiceId(sId);
        }
        try {
            f.setServiceTitle(rs.getString("ServiceTitle"));
        } catch (SQLException ignored) {}
        f.setRatedStar(rs.getInt("RatedStar"));
        f.setContent(rs.getString("Content"));
        f.setStatus(rs.getString("Status"));
        f.setCreatedDate(rs.getTimestamp("CreatedDate"));
        return f;
    }
}

