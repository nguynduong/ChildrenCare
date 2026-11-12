<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết lịch hẹn #${reservation.id} | ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/my-reservations" class="text-decoration-none">Lịch hẹn của tôi</a></li>
            <li class="breadcrumb-item active" aria-current="page">Chi tiết #${reservation.id}</li>
        </ol>
    </nav>

    <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5 bg-white mb-4">
        <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-4">
            <div>
                <h3 class="fw-bold text-primary mb-1">Chi Tiết Lịch Hẹn #${reservation.id}</h3>
                <span class="text-muted small">Ngày đặt: <fmt:formatDate value="${reservation.reservedDate}" pattern="dd/MM/yyyy HH:mm"/></span>
            </div>
            <div>
                <span class="badge fs-6 ${reservation.status == 'Submitted' ? 'bg-warning text-dark' : (reservation.status == 'Success' ? 'bg-success' : 'bg-danger')}">
                    ${reservation.status}
                </span>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <h5 class="fw-bold text-secondary mb-3">👤 Thông Tin Người Liên Hệ</h5>
                <ul class="list-unstyled mb-0">
                    <li class="mb-2">Họ và tên: <strong>${reservation.receiverFullName}</strong></li>
                    <li class="mb-2">Giới tính: <strong>${reservation.receiverGender}</strong></li>
                    <li class="mb-2">Số điện thoại: <strong>${reservation.receiverMobile}</strong></li>
                    <li class="mb-2">Email: <strong>${reservation.receiverEmail}</strong></li>
                    <li class="mb-2">Địa chỉ: <strong>${reservation.receiverAddress}</strong></li>
                </ul>
            </div>
            <div class="col-md-6">
                <h5 class="fw-bold text-secondary mb-3">🕒 Thời Gian & Nhân Sự Phụ Trách</h5>
                <ul class="list-unstyled mb-0">
                    <li class="mb-2">Thời gian khám dự kiến: <strong class="text-primary"><fmt:formatDate value="${reservation.checkupTime}" pattern="dd/MM/yyyy HH:mm"/></strong></li>
                    <li class="mb-2">Nhân sự phụ trách: <strong>${not empty reservation.assignedStaffName ? reservation.assignedStaffName : 'Đang điều phối'}</strong></li>
                    <li class="mb-2">Ghi chú triệu chứng: <em>${not empty reservation.notes ? reservation.notes : 'Không có'}</em></li>
                </ul>
            </div>
        </div>

        <h5 class="fw-bold text-secondary mb-3">📋 Danh Sách Gói Dịch Vụ Đã Đặt</h5>
        <div class="table-responsive mb-4">
            <table class="table table-bordered align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Tên Dịch Vụ</th>
                        <th>Chuyên Mục</th>
                        <th>Đơn Giá</th>
                        <th>Số Lượng</th>
                        <th>Số Trẻ</th>
                        <th>Thành Tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${reservation.items}">
                        <tr>
                            <td class="fw-bold">${item.serviceTitle}</td>
                            <td>${item.serviceCategory}</td>
                            <td><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫"/></td>
                            <td>${item.quantity}</td>
                            <td>${item.numberOfPerson}</td>
                            <td class="fw-bold text-danger">
                                <fmt:formatNumber value="${item.totalCost}" type="currency" currencySymbol="₫"/>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr>
                        <td colspan="5" class="text-end fw-bold fs-5 text-dark">Tổng cộng:</td>
                        <td class="fw-bold fs-5 text-danger">
                            <fmt:formatNumber value="${reservation.totalCost}" type="currency" currencySymbol="₫"/>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="d-flex justify-content-between align-items-center">
            <a href="${pageContext.request.contextPath}/customer/my-reservations" class="btn btn-outline-secondary">
                ← Quay lại danh sách
            </a>

            <!-- Cho phép hủy nếu còn ở trạng thái Submitted -->
            <c:if test="${reservation.status == 'Submitted'}">
                <form action="${pageContext.request.contextPath}/customer/my-reservations" method="post" 
                      onsubmit="return confirm('Bạn có chắc chắn muốn hủy lịch hẹn khám này không?');">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="reservationId" value="${reservation.id}">
                    <button type="submit" class="btn btn-danger">
                        ❌ Hủy Lịch Hẹn
                    </button>
                </form>
            </c:if>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

