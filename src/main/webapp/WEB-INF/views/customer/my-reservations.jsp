<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch hẹn của tôi | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Lịch Hẹn Của Tôi</h2>
            <p class="text-muted small mb-0">Theo dõi lịch khám bệnh và lịch tiêm của bé</p>
        </div>
        <a href="${pageContext.request.contextPath}/services" class="btn btn-outline-primary">
            ➕ Đặt Thêm Lịch Hẹn
        </a>
    </div>

    <c:if test="${not empty sessionScope.flashSuccess}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.flashSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="flashSuccess" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.flashError}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${sessionScope.flashError}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="flashError" scope="session"/>
    </c:if>

    <div class="card shadow-sm border-0 rounded-3">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Mã Đặt</th>
                        <th>Ngày Tạo Đơn</th>
                        <th>Dịch Vụ Chính</th>
                        <th>Thời Gian Khám</th>
                        <th>Tổng Tiền</th>
                        <th>Bác Sĩ</th>
                        <th>Trạng Thái</th>
                        <th class="text-end">Chi Tiết</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${reservations}">
                        <tr>
                            <td class="fw-bold">
                                <a href="${pageContext.request.contextPath}/customer/reservation-detail?id=${r.id}" class="text-decoration-none">
                                    #${r.id}
                                </a>
                            </td>
                            <td><fmt:formatDate value="${r.reservedDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty r.items}">
                                        ${r.items[0].serviceTitle}
                                        <c:if test="${r.items.size() > 1}">
                                            <span class="badge bg-secondary">+${r.items.size() - 1} gói</span>
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
                            <td>${not empty r.assignedStaffName ? r.assignedStaffName : 'Đang phân công'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status == 'Submitted'}">
                                        <span class="badge bg-warning text-dark">Submitted (Chờ khám)</span>
                                    </c:when>
                                    <c:when test="${r.status == 'Success'}">
                                        <span class="badge bg-success">Success (Đã khám)</span>
                                    </c:when>
                                    <c:when test="${r.status == 'Cancelled'}">
                                        <span class="badge bg-danger">Cancelled (Đã hủy)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">${r.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <a href="${pageContext.request.contextPath}/customer/reservation-detail?id=${r.id}" class="btn btn-sm btn-outline-primary">
                                    Xem chi tiết
                                </a>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty reservations}">
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                Bạn chưa có lịch hẹn khám nào. <a href="${pageContext.request.contextPath}/services">Đặt lịch ngay</a>.
                            </td>
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
                            <a class="page-link" href="${pageContext.request.contextPath}/customer/my-reservations?page=${p}">
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

