<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>404 - Không tìm thấy trang | Children Care</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center min-vh-100">
    <div class="container text-center py-5">
        <h1 class="display-1 fw-bold text-warning">404</h1>
        <h2 class="h4 mb-3">Không tìm thấy trang yêu cầu!</h2>
        <p class="text-muted mb-4">Đường dẫn bạn truy cập có thể đã bị thay đổi hoặc không tồn tại trên hệ thống.</p>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary px-4">Về trang chủ</a>
    </div>
</body>
</html>

