<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ lịch hẹn khám | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <h2 class="fw-bold text-primary mb-4">🛒 Giỏ Lịch Hẹn Khám</h2>

    <c:choose>
        <c:when test="${not empty cart.items and cart.totalItems > 0}">
            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card shadow-sm border-0 rounded-3">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Gói Dịch Vụ</th>
                                        <th>Đơn Giá</th>
                                        <th style="width: 120px;">Số Lượng</th>
                                        <th style="width: 120px;">Số Bé/Trẻ</th>
                                        <th>Thành Tiền</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${cart.items}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <img src="${item.serviceThumbnail}" class="rounded me-3" width="55" height="40" style="object-fit:cover;">
                                                    <div>
                                                        <a href="${pageContext.request.contextPath}/service-detail?id=${item.serviceId}" class="fw-bold text-dark text-decoration-none">
                                                            ${item.serviceTitle}
                                                        </a>
                                                        <div class="small text-muted">${item.serviceCategory}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="₫"/>
                                            </td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/cart" method="post" class="d-flex align-items-center">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="serviceId" value="${item.serviceId}">
                                                    <input type="hidden" name="numberOfPerson" value="${item.numberOfPerson}">
                                                    <input type="number" name="quantity" value="${item.quantity}" min="1" max="50" 
                                                           class="form-control form-control-sm text-center" onchange="this.form.submit()">
                                                </form>
                                            </td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/cart" method="post" class="d-flex align-items-center">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="serviceId" value="${item.serviceId}">
                                                    <input type="hidden" name="quantity" value="${item.quantity}">
                                                    <input type="number" name="numberOfPerson" value="${item.numberOfPerson}" min="1" max="10" 
                                                           class="form-control form-control-sm text-center" onchange="this.form.submit()">
                                                </form>
                                            </td>
                                            <td class="fw-bold text-danger">
                                                <fmt:formatNumber value="${item.totalCost}" type="currency" currencySymbol="₫"/>
                                            </td>
                                            <td class="text-end">
                                                <form action="${pageContext.request.contextPath}/cart" method="post" class="d-inline">
                                                    <input type="hidden" name="action" value="remove">
                                                    <input type="hidden" name="serviceId" value="${item.serviceId}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Xóa dịch vụ">🗑️</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <div class="card-footer bg-white d-flex justify-content-between py-3">
                            <a href="${pageContext.request.contextPath}/services" class="btn btn-outline-secondary">
                                ← Chọn Thêm Dịch Vụ
                            </a>
                            <form action="${pageContext.request.contextPath}/cart" method="post">
                                <input type="hidden" name="action" value="clear">
                                <button type="submit" class="btn btn-outline-danger btn-sm">Xóa Hết Giỏ</button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card shadow-sm border-0 rounded-3 p-4">
                        <h5 class="fw-bold mb-3">Tóm Tắt Đơn Đặt Lịch</h5>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted">Tổng số lượt:</span>
                            <span class="fw-bold">${cart.totalItems} lượt</span>
                        </div>
                        <div class="d-flex justify-content-between fs-5 fw-bold text-danger border-top pt-3 mb-4">
                            <span>Tổng thanh toán:</span>
                            <span><fmt:formatNumber value="${cart.totalPrice}" type="currency" currencySymbol="₫"/></span>
                        </div>
                        <a href="${pageContext.request.contextPath}/checkout" class="btn btn-primary w-100 py-2 fw-semibold">
                            Tiến Hành Đặt Lịch →
                        </a>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card shadow-sm border-0 rounded-3 p-5 text-center">
                <div class="fs-1 mb-3">🛒</div>
                <h4 class="fw-bold mb-2">Giỏ lịch hẹn của bạn đang trống</h4>
                <p class="text-muted mb-4">Hãy khám phá các gói dịch vụ chăm sóc và tiêm chủng phù hợp cho bé.</p>
                <div>
                    <a href="${pageContext.request.contextPath}/services" class="btn btn-primary px-4 py-2">Khám Phá Dịch Vụ Ngay</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

