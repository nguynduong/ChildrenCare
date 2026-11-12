<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết khách hàng #${contact.id} | ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Khách Hàng: ${contact.fullName}</h2>
            <span class="text-muted small">Mã định danh: #${contact.id} • Phân loại: <strong>${contact.status}</strong></span>
        </div>
        <a href="${pageContext.request.contextPath}/manager/customers" class="btn btn-outline-secondary">
            ← Quay lại danh sách
        </a>
    </div>

    <!-- Thông tin hiện tại -->
    <div class="card shadow-sm border-0 rounded-3 p-4 bg-white mb-4">
        <h5 class="fw-bold text-secondary mb-3">👤 Thông Tin Hiện Tại</h5>
        <div class="row g-3">
            <div class="col-md-4">
                <span class="small text-muted d-block">Họ và tên:</span>
                <span class="fw-semibold">${contact.fullName}</span>
            </div>
            <div class="col-md-4">
                <span class="small text-muted d-block">Email:</span>
                <span class="fw-semibold">${contact.email}</span>
            </div>
            <div class="col-md-4">
                <span class="small text-muted d-block">Số điện thoại:</span>
                <span class="fw-semibold">${contact.mobile}</span>
            </div>
            <div class="col-md-4">
                <span class="small text-muted d-block">Giới tính:</span>
                <span class="fw-semibold">${contact.gender}</span>
            </div>
            <div class="col-md-8">
                <span class="small text-muted d-block">Địa chỉ:</span>
                <span class="fw-semibold">${contact.address}</span>
            </div>
        </div>
    </div>

    <!-- Bảng lịch sử thay đổi ContactHistory -->
    <div class="card shadow-sm border-0 rounded-3 p-4 bg-white">
        <h5 class="fw-bold text-secondary mb-3">📜 Lịch Sử Thay Đổi Thông Tin (Contact History)</h5>
        <div class="table-responsive">
            <table class="table table-bordered align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Thời Gian Sửa</th>
                        <th>Họ và Tên</th>
                        <th>Email</th>
                        <th>Số Điện Thoại</th>
                        <th>Giới Tính</th>
                        <th>Địa Chỉ</th>
                        <th>Người Cập Nhật</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="h" items="${histories}">
                        <tr>
                            <td><fmt:formatDate value="${h.updatedDate}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                            <td class="fw-semibold">${h.fullName}</td>
                            <td>${h.email}</td>
                            <td>${h.mobile}</td>
                            <td>${h.gender}</td>
                            <td>${h.address}</td>
                            <td>${not empty h.updatedByName ? h.updatedByName : '<span class="text-muted">Hệ thống tự động</span>'}</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty histories}">
                        <tr>
                            <td colspan="7" class="text-center py-3 text-muted">Chưa có thay đổi nào được ghi nhận.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

