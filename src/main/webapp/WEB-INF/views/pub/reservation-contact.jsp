<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin đặt lịch (Reservation Contact) | ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <h2 class="fw-bold text-primary mb-4">Thông Tin Người Nhận & Đặt Lịch Hẹn</h2>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- Form thông tin người nhận -->
        <div class="col-lg-7">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white">
                <h5 class="fw-bold mb-3 text-secondary">Thông Tin Phụ Huynh / Người Đăng Ký</h5>
                
                <form action="${pageContext.request.contextPath}/checkout" method="post">
                    <div class="mb-3">
                        <label for="receiverFullName" class="form-label">Họ và tên người liên hệ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="receiverFullName" name="receiverFullName" 
                               value="${not empty receiverFullName ? receiverFullName : currentUser.fullName}" required>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Giới tính</label>
                            <select class="form-select" name="receiverGender">
                                <option value="Male" ${(receiverGender == 'Male' or currentUser.gender == 'Male') ? 'selected' : ''}>Nam</option>
                                <option value="Female" ${(receiverGender == 'Female' or currentUser.gender == 'Female') ? 'selected' : ''}>Nữ</option>
                                <option value="Other" ${(receiverGender == 'Other' or currentUser.gender == 'Other') ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="receiverMobile" class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" id="receiverMobile" name="receiverMobile" 
                                   value="${not empty receiverMobile ? receiverMobile : currentUser.mobile}" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="receiverEmail" class="form-label">Địa chỉ Email nhận xác nhận <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="receiverEmail" name="receiverEmail" 
                               value="${not empty receiverEmail ? receiverEmail : currentUser.email}" required>
                        <span class="form-text small text-muted">Hướng dẫn chuẩn bị và xác nhận lịch hẹn sẽ được gửi về email này.</span>
                    </div>

                    <div class="mb-3">
                        <label for="receiverAddress" class="form-label">Địa chỉ</label>
                        <input type="text" class="form-control" id="receiverAddress" name="receiverAddress" 
                               value="${not empty receiverAddress ? receiverAddress : currentUser.address}">
                    </div>

                    <div class="mb-3">
                        <label for="checkupTime" class="form-label fw-bold text-primary">Thời gian đến khám dự kiến <span class="text-danger">*</span></label>
                        <input type="datetime-local" class="form-control" id="checkupTime" name="checkupTime" 
                               value="${checkupTime}" required>
                        <span class="form-text small text-muted">Giờ làm việc của trung tâm: 07:30 - 18:00 các ngày trong tuần.</span>
                    </div>

                    <div class="mb-4">
                        <label for="notes" class="form-label">Ghi chú (Tình trạng của bé, triệu chứng...)</label>
                        <textarea class="form-control" id="notes" name="notes" rows="3" placeholder="Bé mấy tháng tuổi, tiền sử dị ứng thuốc...">${notes}</textarea>
                    </div>

                    <div class="d-flex justify-content-between align-items-center">
                        <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary">
                            ← Thay Đổi Gói Dịch Vụ
                        </a>
                        <button type="submit" class="btn btn-success px-4 py-2 fw-semibold">
                            ✅ Xác Nhận Đặt Lịch
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Tóm tắt dịch vụ đã chọn -->
        <div class="col-lg-5">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white">
                <h5 class="fw-bold mb-3 text-secondary">Dịch Vụ Đã Chọn</h5>
                <div class="list-group list-group-flush mb-3">
                    <c:forEach var="item" items="${cart.items}">
                        <div class="list-group-item px-0 py-2 d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="mb-0 fw-bold">${item.serviceTitle}</h6>
                                <small class="text-muted">${item.quantity} lượt × ${item.numberOfPerson} trẻ</small>
                            </div>
                            <span class="fw-bold text-danger">
                                <fmt:formatNumber value="${item.totalCost}" type="currency" currencySymbol="₫"/>
                            </span>
                        </div>
                    </c:forEach>
                </div>
                <div class="d-flex justify-content-between fs-5 fw-bold text-danger border-top pt-3">
                    <span>Tổng cộng:</span>
                    <span><fmt:formatNumber value="${cart.totalPrice}" type="currency" currencySymbol="₫"/></span>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

