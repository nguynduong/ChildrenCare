<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý lịch hẹn khám | Staff & Manager ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">
                ${sessionScope.currentUser.roleId >= 4 ? 'Quản Lý Toàn Bộ Lịch Đặt Khám' : 'Lịch Khám Được Phân Công Cho Bạn'}
            </h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalReservations} lịch hẹn</p>
        </div>
    </div>

    <!-- Bộ lọc & Tìm kiếm -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/staff/reservations" method="get" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label small text-muted">Từ khóa</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tên khách, SĐT, Email...">
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted">Từ ngày</label>
                    <input type="date" class="form-control" name="fromDate" value="${fromDate}">
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted">Đến ngày</label>
                    <input type="date" class="form-control" name="toDate" value="${toDate}">
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted">Trạng thái</label>
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="Submitted" ${selectedStatus == 'Submitted' ? 'selected' : ''}>Submitted</option>
                        <option value="Success" ${selectedStatus == 'Success' ? 'selected' : ''}>Success</option>
                        <option value="Cancelled" ${selectedStatus == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                    </select>
                </div>

                <c:if test="${sessionScope.currentUser.roleId >= 4}">
                    <div class="col-md-2">
                        <label class="form-label small text-muted">Nhân viên</label>
                        <select class="form-select" name="staffId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="st" items="${allStaff}">
                                <option value="${st.id}" ${selectedStaffId == st.id ? 'selected' : ''}>${st.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </c:if>

                <div class="${sessionScope.currentUser.roleId >= 4 ? 'col-md-1' : 'col-md-3'} d-flex align-items-end">
                    <button type="submit" class="btn btn-outline-primary w-100">🔍 Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng danh sách đặt lịch -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Mã Đơn</th>
                        <th>Khách Hàng</th>
                        <th>Điện Thoại</th>
                        <th>Dịch Vụ</th>
                        <th>Thời Gian Khám</th>
                        <th>Tổng Chi Phí</th>
                        <th>Bác Sĩ / Y Tá</th>
                        <th>Trạng Thái</th>
                        <th class="text-end">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${reservations}">
                        <tr>
                            <td class="fw-bold">#${r.id}</td>
                            <td>
                                <div class="fw-semibold">${r.receiverFullName}</div>
                                <div class="small text-muted">${r.receiverEmail}</div>
                            </td>
                            <td>${r.receiverMobile}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty r.items}">
                                        ${r.items[0].serviceTitle}
                                        <c:if test="${r.items.size() > 1}">
                                            <span class="badge bg-secondary">+${r.items.size() - 1}</span>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="fw-semibold text-primary">
                                <fmt:formatDate value="${r.checkupTime}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td class="fw-bold text-danger">
                                <fmt:formatNumber value="${r.totalCost}" type="currency" currencySymbol="₫"/>
                            </td>
                            <td>${not empty r.assignedStaffName ? r.assignedStaffName : '<span class="text-muted">Chưa gán</span>'}</td>
                            <td>
                                <span class="badge ${r.status == 'Submitted' ? 'bg-warning text-dark' : (r.status == 'Success' ? 'bg-success' : 'bg-danger')}">
                                    ${r.status}
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="${pageContext.request.contextPath}/staff/reservation-detail?id=${r.id}" class="btn btn-sm btn-outline-primary">
                                    Chi tiết
                                </a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty reservations}">
                        <tr>
                            <td colspan="9" class="text-center py-4 text-muted">Không tìm thấy lịch hẹn nào.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white d-flex justify-content-between align-items-center">
                <span class="small text-muted">Trang ${currentPage} / ${totalPages}</span>
                <ul class="pagination pagination-sm mb-0">
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/staff/reservations?page=${p}&status=${selectedStatus}&keyword=${keyword}&fromDate=${fromDate}&toDate=${toDate}&staffId=${selectedStaffId}">
                                ${p}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

