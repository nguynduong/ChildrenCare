<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lịch thành công | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow border-0 rounded-4 p-4 p-md-5 text-center bg-white mb-4">
                <div class="display-3 text-success mb-3">🎉</div>
                <h2 class="fw-bold text-success mb-2">Đặt Lịch Hẹn Thành Công!</h2>
                <p class="text-muted mb-4">
                    Mã số đặt lịch: <strong class="text-primary fs-5">#${reservation.id}</strong>. 
                    Chúng tôi đã gửi email xác nhận và hướng dẫn chuẩn bị tới: <strong>${reservation.receiverEmail}</strong>.
                </p>

                <div class="card bg-light border-0 p-3 text-start mb-4">
                    <h6 class="fw-bold text-secondary mb-2">Chi tiết lịch hẹn:</h6>
                    <ul class="list-unstyled small text-muted mb-0">
                        <li>👤 Người liên hệ: <strong>${reservation.receiverFullName}</strong> (${reservation.receiverMobile})</li>
                        <li>🕒 Thời gian khám dự kiến: <strong><fmt:formatDate value="${reservation.checkupTime}" pattern="dd/MM/yyyy HH:mm"/></strong></li>
                        <li>👨‍⚕️ Bác sĩ phụ trách: <strong>${not empty reservation.assignedStaffName ? reservation.assignedStaffName : 'Đang phân công'}</strong></li>
                        <li>💰 Tổng chi phí: <strong class="text-danger"><fmt:formatNumber value="${reservation.totalCost}" type="currency" currencySymbol="₫"/></strong></li>
                    </ul>
                </div>

                <div class="card bg-info-subtle border-0 p-3 text-start mb-4">
                    <h6 class="fw-bold text-primary mb-2">💳 Hướng dẫn thanh toán & Đến khám:</h6>
                    <p class="small text-muted mb-1">• Phụ huynh có thể thanh toán trực tiếp tại quầy lễ tân hoặc chuyển khoản qua mã QR tại trung tâm.</p>
                    <p class="small text-muted mb-0">• Vui lòng đưa bé đến trước giờ hẹn 10 - 15 phút để điều dưỡng hỗ trợ đo chiều cao, cân nặng và kiểm tra thân nhiệt.</p>
                </div>

                <div class="d-flex justify-content-center gap-3">
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-primary px-4">Về Trang Chủ</a>
                    <c:if test="${not empty sessionScope.currentUser}">
                        <a href="${pageContext.request.contextPath}/customer/my-reservations" class="btn btn-primary px-4">Xem Lịch Hẹn Của Tôi</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

