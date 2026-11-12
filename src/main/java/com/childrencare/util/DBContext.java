package com.childrencare.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Quản lý kết nối cơ sở dữ liệu SQL Server cho toàn bộ hệ thống.
 * Tuân thủ Clean Code Ponytail: Đơn giản, dùng JDBC chuẩn, đọc cấu hình từ file properties.
 */
public class DBContext {

    private static String url;
    private static String username;
    private static String password;

    static {
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("database.properties")) {
            Properties prop = new Properties();
            if (input != null) {
                prop.load(input);
                Class.forName(prop.getProperty("db.driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver"));
                url = prop.getProperty("db.url");
                username = prop.getProperty("db.username");
                password = prop.getProperty("db.password");
            } else {
                // shortcut: fallback default nếu không tìm thấy file cấu hình
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                url = "jdbc:sqlserver://localhost:1433;databaseName=ChildrenCareDB;encrypt=true;trustServerCertificate=true";
                username = "sa";
                password = "123";
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Mở một kết nối mới tới cơ sở dữ liệu.
     * Người gọi bắt buộc sử dụng trong try-with-resources để tự động đóng kết nối.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}

