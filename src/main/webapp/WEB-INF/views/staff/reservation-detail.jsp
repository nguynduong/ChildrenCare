<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xử lý lịch hẹn #${reservation.id} | Staff ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Xử Lý Lịch Hẹn #${reservation.id}</h2>
            <span class="text-muted small">Thời gian đặt: <fmt:formatDate value="${reservation.reservedDate}" pattern="dd/MM/yyyy HH:mm"/></span>
        </div>
        <a href="${pageContext.request.contextPath}/staff/reservations" class="btn btn-outline-secondary">
            ← Quay lại danh sách
        </a>
    </div>

    <c:if test="${not empty sessionScope.flashSuccess}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.flashSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="flashSuccess" scope="session"/>
    </c:if>

    <div class="row g-4 mb-4">
        <!-- Thông tin chi tiết lịch hẹn -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white mb-4">
                <h5 class="fw-bold text-secondary mb-3">👤 Thông Tin Bệnh Nhi & Phụ Huynh</h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="small text-muted">Họ tên người nhận:</label>
                        <div class="fw-semibold">${reservation.receiverFullName}</div>
                    </div>
                    <div class="col-md-6">
                        <label class="small text-muted">Giới tính:</label>
                        <div class="fw-semibold">${reservation.receiverGender}</div>
                    </div>
                    <div class="col-md-6">
                        <label class="small text-muted">Số điện thoại:</label>
                        <div class="fw-semibold">${reservation.receiverMobile}</div>
                    </div>
                    <div class="col-md-6">
                        <label class="small text-muted">Email:</label>
                        <div class="fw-semibold">${reservation.receiverEmail}</div>
                    </div>
                    <div class="col-12">
                        <label class="small text-muted">Địa chỉ:</label>
                        <div class="fw-semibold">${reservation.receiverAddress}</div>
                    </div>
                    <div class="col-12">
                        <label class="small text-muted">Ghi chú triệu chứng:</label>
                        <div class="fst-italic text-secondary">${not empty reservation.notes ? reservation.notes : 'Không có ghi chú'}</div>
                    </div>
                </div>
            </div>

            <!-- Bảng dịch vụ trong lịch hẹn -->
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white">
                <h5 class="fw-bold text-secondary mb-3">📋 Danh Sách Gói Dịch Vụ</h5>
                <div class="table-responsive">
                    <table class="table table-bordered align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Tên Dịch Vụ</th>
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
                                    <td><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫"/></td>
                                    <td>${item.quantity}</td>
                                    <td>${item.numberOfPerson}</td>
                                    <td class="fw-bold text-danger">
                                        <fmt:formatNumber value="${item.totalCost}" type="currency" currencySymbol="₫"/>
                                    </td>
                                </tr>
                            </c:forEach>
                            <tr>
                                <td colspan="4" class="text-end fw-bold">Tổng Chi Phí:</td>
                                <td class="fw-bold text-danger fs-5">
                                    <fmt:formatNumber value="${reservation.totalCost}" type="currency" currencySymbol="₫"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Bảng điều khiển tác vụ (Phân công & Đổi trạng thái) -->
        <div class="col-lg-4">
            <!-- Trạng thái đơn -->
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white mb-4">
                <h5 class="fw-bold mb-3">⚡ Trạng Thái Lịch Khám</h5>
                <div class="mb-3">
                    <span class="badge fs-6 ${reservation.status == 'Submitted' ? 'bg-warning text-dark' : (reservation.status == 'Success' ? 'bg-success' : 'bg-danger')}">
                        ${reservation.status}
                    </span>
                </div>

                <form action="${pageContext.request.contextPath}/staff/reservations" method="post">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" name="reservationId" value="${reservation.id}">
                    <div class="mb-3">
                        <label class="form-label small text-muted">Cập nhật trạng thái:</label>
                        <select class="form-select" name="status">
                            <option value="Submitted" ${reservation.status == 'Submitted' ? 'selected' : ''}>Submitted (Chờ khám)</option>
                            <option value="Success" ${reservation.status == 'Success' ? 'selected' : ''}>Success (Đã khám xong)</option>
                            <option value="Cancelled" ${reservation.status == 'Cancelled' ? 'selected' : ''}>Cancelled (Hủy bỏ)</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Cập Nhật Trạng Thái</button>
                </form>

                <!-- Nếu là Bác sĩ và đơn ở trạng thái Submitted/Success, có nút sang Khám Bệnh & Kê Đơn -->
                <c:if test="${sessionScope.currentUser.roleId == 2 or sessionScope.currentUser.roleId == 4 or sessionScope.currentUser.roleId == 5}">
                    <hr class="my-3">
                    <a href="${pageContext.request.contextPath}/staff/medical-examination?reservationId=${reservation.id}" class="btn btn-success w-100">
                        🩺 Khám Bệnh & Kê Đơn Thuốc →
                    </a>
                </c:if>
            </div>

            <!-- Phân công nhân viên (Chỉ Manager/Admin có quyền đổi) -->
            <c:if test="${sessionScope.currentUser.roleId >= 4}">
                <div class="card shadow-sm border-0 rounded-3 p-4 bg-white">
                    <h5 class="fw-bold mb-3">👨‍⚕️ Phân Công Nhân Sự</h5>
                    <div class="mb-3">
                        <div class="small text-muted">Nhân sự hiện tại:</div>
                        <div class="fw-bold">${not empty reservation.assignedStaffName ? reservation.assignedStaffName : 'Chưa phân công'}</div>
                    </div>
                    <form action="${pageContext.request.contextPath}/staff/reservations" method="post">
                        <input type="hidden" name="action" value="assignStaff">
                        <input type="hidden" name="reservationId" value="${reservation.id}">
                        <div class="mb-3">
                            <label class="form-label small text-muted">Gán cho Bác sĩ / Y tá khác:</label>
                            <select class="form-select" name="staffId" required>
                                <c:forEach var="st" items="${allStaff}">
                                    <option value="${st.id}" ${reservation.assignedStaffId == st.id ? 'selected' : ''}>
                                        ${st.fullName} (${st.roleName})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-outline-primary w-100">Lưu Phân Công</button>
                    </form>
                </div>
            </c:if>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

