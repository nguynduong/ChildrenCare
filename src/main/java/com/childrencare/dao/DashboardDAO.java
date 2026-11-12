package com.childrencare.dao;

import com.childrencare.util.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Data Access Object tổng hợp dữ liệu thống kê cho Bảng điều khiển (Dashboard).
 */
public class DashboardDAO {

    /**
     * Thống kê số lượng đặt lịch theo trạng thái (Success, Cancelled, Submitted).
     */
    public Map<String, Integer> getReservationStats() {
        Map<String, Integer> map = new HashMap<>();
        map.put("Submitted", 0);
        map.put("Success", 0);
        map.put("Cancelled", 0);

        String sql = "SELECT Status, COUNT(*) AS Cnt FROM Reservations GROUP BY Status";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("Status"), rs.getInt("Cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Tổng doanh thu từ các đơn đặt lịch thành công (Success).
     */
    public BigDecimal getTotalRevenue() {
        String sql = "SELECT SUM(TotalCost) FROM Reservations WHERE Status = 'Success'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                BigDecimal val = rs.getBigDecimal(1);
                return val != null ? val : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Doanh thu theo từng danh mục dịch vụ.
     */
    public Map<String, BigDecimal> getRevenueByCategory() {
        Map<String, BigDecimal> map = new LinkedHashMap<>();
        String sql = "SELECT st.Name AS CategoryName, SUM(ri.TotalCost) AS Revenue " +
                     "FROM ReservationItems ri " +
                     "INNER JOIN Reservations r ON ri.ReservationId = r.Id " +
                     "INNER JOIN Services s ON ri.ServiceId = s.Id " +
                     "INNER JOIN Settings st ON s.CategoryId = st.Id " +
                     "WHERE r.Status = 'Success' " +
                     "GROUP BY st.Name ORDER BY Revenue DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("CategoryName"), rs.getBigDecimal("Revenue"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    /**
     * Điểm đánh giá sao trung bình của hệ thống.
     */
    public double getAverageRating() {
        String sql = "SELECT AVG(CAST(RatedStar AS FLOAT)) FROM Feedbacks WHERE Status = 'Published'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return Math.round(rs.getDouble(1) * 10.0) / 10.0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 5.0;
    }

    /**
     * Xu hướng số lượng đặt lịch trong 7 ngày gần nhất.
     */
    public Map<String, Integer> getReservationTrend7Days() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT CONVERT(VARCHAR(10), ReservedDate, 103) AS DayStr, COUNT(*) AS TotalCount " +
                     "FROM Reservations " +
                     "WHERE ReservedDate >= DATEADD(day, -7, GETDATE()) " +
                     "GROUP BY CONVERT(VARCHAR(10), ReservedDate, 103) " +
                     "ORDER BY MIN(ReservedDate) ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("DayStr"), rs.getInt("TotalCount"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }
}

