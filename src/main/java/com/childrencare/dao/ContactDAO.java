package com.childrencare.dao;

import com.childrencare.model.Contact;
import com.childrencare.model.ContactHistory;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Contacts và ContactHistories.
 */
public class ContactDAO {

    /**
     * Đồng bộ thông tin khách hàng từ Đặt lịch hoặc Feedback.
     * Tự động tạo bản ghi lịch sử thay đổi nếu có cập nhật thông tin.
     */
    public void syncContact(String fullName, String gender, String email, String mobile, String address, Integer updatedBy) {
        String sqlFind = "SELECT * FROM Contacts WHERE LOWER(Email) = LOWER(?)";
        String sqlInsert = "INSERT INTO Contacts (FullName, Gender, Email, Mobile, Address, Status) VALUES (?, ?, ?, ?, ?, 'Potential')";
        String sqlUpdate = "UPDATE Contacts SET FullName = ?, Gender = ?, Mobile = ?, Address = ?, UpdatedDate = GETDATE() WHERE Id = ?";
        String sqlHistory = "INSERT INTO ContactHistories (ContactId, FullName, Gender, Email, Mobile, Address, UpdatedBy) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement psFind = conn.prepareStatement(sqlFind)) {
            psFind.setString(1, email);
            try (ResultSet rs = psFind.executeQuery()) {
                if (rs.next()) {
                    int contactId = rs.getInt("Id");
                    String oldName = rs.getString("FullName");
                    String oldMobile = rs.getString("Mobile");
                    String oldAddress = rs.getString("Address");

                    // Nếu có thông tin mới thay đổi thì lưu lịch sử và cập nhật
                    boolean changed = !fullName.equals(oldName) || !mobile.equals(oldMobile) || (address != null && !address.equals(oldAddress));
                    if (changed) {
                        try (PreparedStatement psUp = conn.prepareStatement(sqlUpdate);
                             PreparedStatement psHis = conn.prepareStatement(sqlHistory)) {
                            psUp.setString(1, fullName);
                            psUp.setString(2, gender);
                            psUp.setString(3, mobile);
                            psUp.setString(4, address != null ? address : "");
                            psUp.setInt(5, contactId);
                            psUp.executeUpdate();

                            psHis.setInt(1, contactId);
                            psHis.setString(2, fullName);
                            psHis.setString(3, gender);
                            psHis.setString(4, email);
                            psHis.setString(5, mobile);
                            psHis.setString(6, address != null ? address : "");
                            if (updatedBy != null && updatedBy > 0) {
                                psHis.setInt(7, updatedBy);
                            } else {
                                psHis.setNull(7, java.sql.Types.INTEGER);
                            }
                            psHis.executeUpdate();
                        }
                    }
                } else {
                    // Thêm mới Contact
                    try (PreparedStatement psIn = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                        psIn.setString(1, fullName);
                        psIn.setString(2, gender);
                        psIn.setString(3, email);
                        psIn.setString(4, mobile);
                        psIn.setString(5, address != null ? address : "");
                        psIn.executeUpdate();
                        try (ResultSet genRs = psIn.getGeneratedKeys()) {
                            if (genRs.next()) {
                                int newContactId = genRs.getInt(1);
                                try (PreparedStatement psHis = conn.prepareStatement(sqlHistory)) {
                                    psHis.setInt(1, newContactId);
                                    psHis.setString(2, fullName);
                                    psHis.setString(3, gender);
                                    psHis.setString(4, email);
                                    psHis.setString(5, mobile);
                                    psHis.setString(6, address != null ? address : "");
                                    if (updatedBy != null && updatedBy > 0) {
                                        psHis.setInt(7, updatedBy);
                                    } else {
                                        psHis.setNull(7, java.sql.Types.INTEGER);
                                    }
                                    psHis.executeUpdate();
                                }
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy danh sách khách hàng phân trang cho Manager / Staff.
     */
    public List<Contact> getContacts(String status, String keyword, int page, int pageSize) {
        List<Contact> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Contacts WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (FullName LIKE ? OR Email LIKE ? OR Mobile LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
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
                    Contact c = new Contact();
                    c.setId(rs.getInt("Id"));
                    c.setFullName(rs.getString("FullName"));
                    c.setGender(rs.getString("Gender"));
                    c.setEmail(rs.getString("Email"));
                    c.setMobile(rs.getString("Mobile"));
                    c.setAddress(rs.getString("Address"));
                    c.setStatus(rs.getString("Status"));
                    c.setCreatedDate(rs.getTimestamp("CreatedDate"));
                    c.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countContacts(String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Contacts WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (FullName LIKE ? OR Email LIKE ? OR Mobile LIKE ?)");
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
     * Lấy chi tiết liên hệ theo ID.
     */
    public Contact getById(int id) {
        String sql = "SELECT * FROM Contacts WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Contact c = new Contact();
                    c.setId(rs.getInt("Id"));
                    c.setFullName(rs.getString("FullName"));
                    c.setGender(rs.getString("Gender"));
                    c.setEmail(rs.getString("Email"));
                    c.setMobile(rs.getString("Mobile"));
                    c.setAddress(rs.getString("Address"));
                    c.setStatus(rs.getString("Status"));
                    c.setCreatedDate(rs.getTimestamp("CreatedDate"));
                    c.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy danh sách lịch sử thay đổi của một Contact.
     */
    public List<ContactHistory> getHistoriesByContactId(int contactId) {
        List<ContactHistory> list = new ArrayList<>();
        String sql = "SELECT ch.*, u.FullName AS UpdatedByName " +
                     "FROM ContactHistories ch " +
                     "LEFT JOIN Users u ON ch.UpdatedBy = u.Id " +
                     "WHERE ch.ContactId = ? ORDER BY ch.Id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contactId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ContactHistory h = new ContactHistory();
                    h.setId(rs.getInt("Id"));
                    h.setContactId(rs.getInt("ContactId"));
                    h.setFullName(rs.getString("FullName"));
                    h.setGender(rs.getString("Gender"));
                    h.setEmail(rs.getString("Email"));
                    h.setMobile(rs.getString("Mobile"));
                    h.setAddress(rs.getString("Address"));
                    int uId = rs.getInt("UpdatedBy");
                    if (!rs.wasNull()) {
                        h.setUpdatedBy(uId);
                    }
                    h.setUpdatedByName(rs.getString("UpdatedByName"));
                    h.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}

