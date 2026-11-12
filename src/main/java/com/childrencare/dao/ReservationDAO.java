package com.childrencare.dao;

import com.childrencare.model.Reservation;
import com.childrencare.model.ReservationItem;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Reservations và ReservationItems.
 */
public class ReservationDAO {

    /**
     * Tạo đơn đặt lịch mới kèm danh sách ReservationItems trong một Transaction an toàn.
     */
    public int createReservation(Reservation res) {
        String sqlReservation = "INSERT INTO Reservations (UserId, ReservedDate, CheckupTime, ReceiverFullName, ReceiverGender, " +
                                "ReceiverEmail, ReceiverMobile, ReceiverAddress, Notes, TotalCost, Status, AssignedStaffId) " +
                                "VALUES (?, GETDATE(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String sqlItem = "INSERT INTO ReservationItems (ReservationId, ServiceId, UnitPrice, Quantity, NumberOfPerson, TotalCost) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";

        String sqlDecrease = "UPDATE Services SET AvailableQuantity = AvailableQuantity - ? WHERE Id = ? AND AvailableQuantity >= ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false); // Bắt đầu Transaction

            int reservationId;
            try (PreparedStatement ps = conn.prepareStatement(sqlReservation, Statement.RETURN_GENERATED_KEYS)) {
                if (res.getUserId() != null && res.getUserId() > 0) {
                    ps.setInt(1, res.getUserId());
                } else {
                    ps.setNull(1, java.sql.Types.INTEGER);
                }
                ps.setTimestamp(2, res.getCheckupTime());
                ps.setString(3, res.getReceiverFullName());
                ps.setString(4, res.getReceiverGender());
                ps.setString(5, res.getReceiverEmail());
                ps.setString(6, res.getReceiverMobile());
                ps.setString(7, res.getReceiverAddress());
                ps.setString(8, res.getNotes());
                ps.setBigDecimal(9, res.getTotalCost());
                ps.setString(10, res.getStatus() != null ? res.getStatus() : "Submitted");
                if (res.getAssignedStaffId() != null && res.getAssignedStaffId() > 0) {
                    ps.setInt(11, res.getAssignedStaffId());
                } else {
                    ps.setNull(11, java.sql.Types.INTEGER);
                }

                int affected = ps.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return -1;
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        reservationId = rs.getInt(1);
                    } else {
                        conn.rollback();
                        return -1;
                    }
                }
            }

            // Chèn từng ReservationItem và trừ AvailableQuantity
            try (PreparedStatement psItem = conn.prepareStatement(sqlItem);
                 PreparedStatement psDec = conn.prepareStatement(sqlDecrease)) {
                for (ReservationItem item : res.getItems()) {
                    psItem.setInt(1, reservationId);
                    psItem.setInt(2, item.getServiceId());
                    psItem.setBigDecimal(3, item.getUnitPrice());
                    psItem.setInt(4, item.getQuantity());
                    psItem.setInt(5, item.getNumberOfPerson());
                    psItem.setBigDecimal(6, item.getTotalCost());
                    psItem.executeUpdate();

                    // Trừ kho
                    psDec.setInt(1, item.getQuantity());
                    psDec.setInt(2, item.getServiceId());
                    psDec.setInt(3, item.getQuantity());
                    psDec.executeUpdate();
                }
            }

            conn.commit(); // Hoàn tất Transaction
            return reservationId;
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }

    /**
     * Lấy chi tiết lịch hẹn kèm danh sách các dịch vụ.
     */
    public Reservation getById(int id) {
        String sql = "SELECT r.*, u.FullName AS AssignedStaffName " +
                     "FROM Reservations r " +
                     "LEFT JOIN Users u ON r.AssignedStaffId = u.Id " +
                     "WHERE r.Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Reservation res = mapResultSet(rs);
                    res.setItems(getItemsByReservationId(id));
                    return res;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy danh sách dịch vụ trong một đơn đặt lịch.
     */
    public List<ReservationItem> getItemsByReservationId(int reservationId) {
        List<ReservationItem> list = new ArrayList<>();
        String sql = "SELECT ri.*, s.Title AS ServiceTitle, s.Thumbnail AS ServiceThumbnail, st.Name AS ServiceCategory " +
                     "FROM ReservationItems ri " +
                     "LEFT JOIN Services s ON ri.ServiceId = s.Id " +
                     "LEFT JOIN Settings st ON s.CategoryId = st.Id " +
                     "WHERE ri.ReservationId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReservationItem item = new ReservationItem();
                    item.setId(rs.getInt("Id"));
                    item.setReservationId(rs.getInt("ReservationId"));
                    item.setServiceId(rs.getInt("ServiceId"));
                    item.setServiceTitle(rs.getString("ServiceTitle"));
                    item.setServiceThumbnail(rs.getString("ServiceThumbnail"));
                    item.setServiceCategory(rs.getString("ServiceCategory"));
                    item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setNumberOfPerson(rs.getInt("NumberOfPerson"));
                    item.setTotalCost(rs.getBigDecimal("TotalCost"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lịch hẹn của khách hàng đang đăng nhập (My Reservations).
     */
    public List<Reservation> getCustomerReservations(int userId, int page, int pageSize) {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName AS AssignedStaffName " +
                     "FROM Reservations r " +
                     "LEFT JOIN Users u ON r.AssignedStaffId = u.Id " +
                     "WHERE r.UserId = ? ORDER BY r.Id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Reservation r = mapResultSet(rs);
                    r.setItems(getItemsByReservationId(r.getId()));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countCustomerReservations(int userId) {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
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
     * Hủy đơn đặt lịch khi còn ở trạng thái Submitted (Customer) và hoàn lại số lượng khả dụng.
     */
    public boolean cancelReservation(int reservationId) {
        String sqlCheck = "SELECT Status FROM Reservations WHERE Id = ?";
        String sqlCancel = "UPDATE Reservations SET Status = 'Cancelled', UpdatedDate = GETDATE() WHERE Id = ? AND Status = 'Submitted'";
        String sqlReturn = "UPDATE s SET s.AvailableQuantity = s.AvailableQuantity + ri.Quantity " +
                           "FROM Services s " +
                           "INNER JOIN ReservationItems ri ON s.Id = ri.ServiceId " +
                           "WHERE ri.ReservationId = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psCancel = conn.prepareStatement(sqlCancel);
                 PreparedStatement psReturn = conn.prepareStatement(sqlReturn)) {
                psCancel.setInt(1, reservationId);
                int affected = psCancel.executeUpdate();
                if (affected > 0) {
                    psReturn.setInt(1, reservationId);
                    psReturn.executeUpdate();
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                    return false;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Danh sách đặt lịch cho Staff & Manager có lọc theo ngày, trạng thái, nhân viên, tìm kiếm.
     */
    public List<Reservation> getStaffReservations(Integer staffId, String fromDate, String toDate, String status, String keyword, int page, int pageSize) {
        List<Reservation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, u.FullName AS AssignedStaffName " +
            "FROM Reservations r " +
            "LEFT JOIN Users u ON r.AssignedStaffId = u.Id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (staffId != null && staffId > 0) {
            sql.append(" AND r.AssignedStaffId = ?");
            params.add(staffId);
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.CheckupTime >= ?");
            params.add(fromDate + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.CheckupTime <= ?");
            params.add(toDate + " 23:59:59");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND r.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (r.ReceiverFullName LIKE ? OR r.ReceiverEmail LIKE ? OR r.ReceiverMobile LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY r.Id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Reservation r = mapResultSet(rs);
                    r.setItems(getItemsByReservationId(r.getId()));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countStaffReservations(Integer staffId, String fromDate, String toDate, String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Reservations r WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (staffId != null && staffId > 0) {
            sql.append(" AND r.AssignedStaffId = ?");
            params.add(staffId);
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.CheckupTime >= ?");
            params.add(fromDate + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.CheckupTime <= ?");
            params.add(toDate + " 23:59:59");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND r.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (r.ReceiverFullName LIKE ? OR r.ReceiverEmail LIKE ? OR r.ReceiverMobile LIKE ?)");
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
     * Cập nhật trạng thái đơn đặt lịch (Manager / Staff).
     */
    public boolean updateStatus(int reservationId, String newStatus) {
        String sql = "UPDATE Reservations SET Status = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Manager gán nhân viên phụ trách.
     */
    public boolean assignStaff(int reservationId, int staffId) {
        String sql = "UPDATE Reservations SET AssignedStaffId = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Reservation mapResultSet(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getInt("Id"));
        int userId = rs.getInt("UserId");
        if (!rs.wasNull()) {
            r.setUserId(userId);
        }
        r.setReservedDate(rs.getTimestamp("ReservedDate"));
        r.setCheckupTime(rs.getTimestamp("CheckupTime"));
        r.setReceiverFullName(rs.getString("ReceiverFullName"));
        r.setReceiverGender(rs.getString("ReceiverGender"));
        r.setReceiverEmail(rs.getString("ReceiverEmail"));
        r.setReceiverMobile(rs.getString("ReceiverMobile"));
        r.setReceiverAddress(rs.getString("ReceiverAddress"));
        r.setNotes(rs.getString("Notes"));
        r.setTotalCost(rs.getBigDecimal("TotalCost"));
        r.setStatus(rs.getString("Status"));
        int staffId = rs.getInt("AssignedStaffId");
        if (!rs.wasNull()) {
            r.setAssignedStaffId(staffId);
        }
        try {
            r.setAssignedStaffName(rs.getString("AssignedStaffName"));
        } catch (SQLException ignored) {}
        r.setCreatedDate(rs.getTimestamp("CreatedDate"));
        r.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return r;
    }
}

