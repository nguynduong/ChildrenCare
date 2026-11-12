package com.childrencare.util;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import org.mindrot.jbcrypt.BCrypt;

/**
 * Các hàm tiện ích bảo mật: Băm mật khẩu, kiểm tra mật khẩu, sinh token ngẫu nhiên.
 */
public class SecurityUtils {

    private static final SecureRandom secureRandom = new SecureRandom();

    /**
     * Băm mật khẩu bằng BCrypt (an toàn, kèm salt ngẫu nhiên).
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            return null;
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(10));
    }

    /**
     * Kiểm tra mật khẩu thô có khớp với chuỗi đã băm không.
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            // Hỗ trợ trường hợp mật khẩu cũ băm SHA-256 (nếu có)
            return hashSHA256(plainPassword).equalsIgnoreCase(hashedPassword);
        }
    }

    /**
     * Băm SHA-256 đơn giản (dự phòng).
     */
    public static String hashSHA256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Lỗi băm SHA-256", e);
        }
    }

    /**
     * Sinh token ngẫu nhiên an toàn dùng cho xác thực email và reset password.
     */
    public static String generateRandomToken(int length) {
        byte[] randomBytes = new byte[length];
        secureRandom.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }
}

