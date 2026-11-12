package com.childrencare.dao;

import com.childrencare.model.Service;
import com.childrencare.model.ServiceImage;
import com.childrencare.util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Services và ServiceImages.
 */
public class ServiceDAO {

    /**
     * Lấy danh sách dịch vụ nổi bật (Featured Services) hiển thị ở Trang chủ.
     */
    public List<Service> getFeaturedServices(int limit) {
        List<Service> list = new ArrayList<>();
        String sql = "SELECT TOP (?) s.*, st.Name AS CategoryName " +
                     "FROM Services s " +
                     "LEFT JOIN Settings st ON s.CategoryId = st.Id " +
                     "WHERE s.Status = 'Active' AND s.IsFeatured = 1 " +
                     "ORDER BY s.UpdatedDate DESC";
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
     * Lấy danh sách dịch vụ công khai (Services List) kèm phân trang, tìm kiếm, lọc danh mục.
     */
    public List<Service> getPublicServices(Integer categoryId, String keyword, int page, int pageSize) {
        List<Service> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, st.Name AS CategoryName " +
            "FROM Services s " +
            "LEFT JOIN Settings st ON s.CategoryId = st.Id " +
            "WHERE s.Status = 'Active'"
        );
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND s.CategoryId = ?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (s.Title LIKE ? OR s.BriefInfo LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY s.UpdatedDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
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
     * Đếm tổng số dịch vụ công khai phục vụ phân trang.
     */
    public int countPublicServices(Integer categoryId, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Services s WHERE s.Status = 'Active'");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND s.CategoryId = ?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (s.Title LIKE ? OR s.BriefInfo LIKE ?)");
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
     * Lấy chi tiết dịch vụ kèm bộ sưu tập ảnh ServiceImages.
     */
    public Service getById(int id) {
        String sql = "SELECT s.*, st.Name AS CategoryName " +
                     "FROM Services s " +
                     "LEFT JOIN Settings st ON s.CategoryId = st.Id " +
                     "WHERE s.Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Service service = mapResultSet(rs);
                    service.setImages(getImagesByServiceId(service.getId()));
                    return service;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Quản lý danh sách dịch vụ (Manager / Staff) có phân trang, tìm kiếm, lọc Status.
     */
    public List<Service> getManagerServices(String status, String keyword, int page, int pageSize) {
        List<Service> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, st.Name AS CategoryName " +
            "FROM Services s " +
            "LEFT JOIN Settings st ON s.CategoryId = st.Id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND s.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (s.Title LIKE ? OR s.BriefInfo LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append(" ORDER BY s.Id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
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
     * Đếm tổng số dịch vụ trong màn hình quản lý.
     */
    public int countManagerServices(String status, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Services s WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND s.Status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (s.Title LIKE ? OR s.BriefInfo LIKE ?)");
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
     * Thêm dịch vụ mới và trả về ID vừa sinh.
     */
    public int insert(Service s) {
        String sql = "INSERT INTO Services (Title, Thumbnail, CategoryId, BriefInfo, Description, NumberOfPerson, ListPrice, SalePrice, AvailableQuantity, IsFeatured, Status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, s.getTitle());
            ps.setString(2, s.getThumbnail());
            ps.setInt(3, s.getCategoryId());
            ps.setString(4, s.getBriefInfo());
            ps.setString(5, s.getDescription());
            ps.setInt(6, s.getNumberOfPerson());
            ps.setBigDecimal(7, s.getListPrice());
            ps.setBigDecimal(8, s.getSalePrice());
            ps.setInt(9, s.getAvailableQuantity());
            ps.setBoolean(10, s.isFeatured());
            ps.setString(11, s.getStatus() != null ? s.getStatus() : "Inactive");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Cập nhật thông tin dịch vụ.
     */
    public boolean update(Service s) {
        String sql = "UPDATE Services SET Title = ?, Thumbnail = ?, CategoryId = ?, BriefInfo = ?, Description = ?, " +
                     "NumberOfPerson = ?, ListPrice = ?, SalePrice = ?, AvailableQuantity = ?, IsFeatured = ?, Status = ?, UpdatedDate = GETDATE() " +
                     "WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getTitle());
            ps.setString(2, s.getThumbnail());
            ps.setInt(3, s.getCategoryId());
            ps.setString(4, s.getBriefInfo());
            ps.setString(5, s.getDescription());
            ps.setInt(6, s.getNumberOfPerson());
            ps.setBigDecimal(7, s.getListPrice());
            ps.setBigDecimal(8, s.getSalePrice());
            ps.setInt(9, s.getAvailableQuantity());
            ps.setBoolean(10, s.isFeatured());
            ps.setString(11, s.getStatus());
            ps.setInt(12, s.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Bật/tắt trạng thái (Active / Inactive).
     */
    public boolean toggleStatus(int id, String newStatus) {
        String sql = "UPDATE Services SET Status = ?, UpdatedDate = GETDATE() WHERE Id = ?";
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

    /**
     * Lấy danh sách ảnh đính kèm của một dịch vụ.
     */
    public List<ServiceImage> getImagesByServiceId(int serviceId) {
        List<ServiceImage> list = new ArrayList<>();
        String sql = "SELECT * FROM ServiceImages WHERE ServiceId = ? ORDER BY SortOrder ASC, Id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ServiceImage(
                        rs.getInt("Id"),
                        rs.getInt("ServiceId"),
                        rs.getString("ImageUrl"),
                        rs.getInt("SortOrder")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thêm ảnh đính kèm cho dịch vụ.
     */
    public boolean insertImage(ServiceImage img) {
        String sql = "INSERT INTO ServiceImages (ServiceId, ImageUrl, SortOrder) VALUES (?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, img.getServiceId());
            ps.setString(2, img.getImageUrl());
            ps.setInt(3, img.getSortOrder());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa ảnh đính kèm.
     */
    public boolean deleteImage(int imageId) {
        String sql = "DELETE FROM ServiceImages WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Giảm số lượng khả dụng AvailableQuantity khi đặt lịch thành công.
     */
    public boolean decreaseAvailableQuantity(int serviceId, int quantity) {
        String sql = "UPDATE Services SET AvailableQuantity = AvailableQuantity - ? WHERE Id = ? AND AvailableQuantity >= ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, serviceId);
            ps.setInt(3, quantity);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Hoàn lại số lượng khả dụng khi đơn bị hủy.
     */
    public boolean increaseAvailableQuantity(int serviceId, int quantity) {
        String sql = "UPDATE Services SET AvailableQuantity = AvailableQuantity + ? WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, serviceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Service mapResultSet(ResultSet rs) throws SQLException {
        Service s = new Service();
        s.setId(rs.getInt("Id"));
        s.setTitle(rs.getString("Title"));
        s.setThumbnail(rs.getString("Thumbnail"));
        s.setCategoryId(rs.getInt("CategoryId"));
        try {
            s.setCategoryName(rs.getString("CategoryName"));
        } catch (SQLException ignored) {}
        s.setBriefInfo(rs.getString("BriefInfo"));
        s.setDescription(rs.getString("Description"));
        s.setNumberOfPerson(rs.getInt("NumberOfPerson"));
        s.setListPrice(rs.getBigDecimal("ListPrice"));
        s.setSalePrice(rs.getBigDecimal("SalePrice"));
        s.setAvailableQuantity(rs.getInt("AvailableQuantity"));
        s.setFeatured(rs.getBoolean("IsFeatured"));
        s.setStatus(rs.getString("Status"));
        s.setCreatedDate(rs.getTimestamp("CreatedDate"));
        s.setUpdatedDate(rs.getTimestamp("UpdatedDate"));
        return s;
    }
}

