<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng điều khiển quản trị (Dashboard) | Admin ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Bảng Điều Khiển Quản Trị Hệ Thống (Dashboard)</h2>
            <p class="text-muted small mb-0">Tổng quan thống kê kinh doanh, đặt lịch và khách hàng</p>
        </div>
        <div class="d-flex gap-2">
            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-primary btn-sm">👥 Người Dùng</a>
            <a href="${pageContext.request.contextPath}/admin/settings" class="btn btn-outline-secondary btn-sm">⚙️ Cấu Hình</a>
        </div>
    </div>

    <!-- 4 Thẻ KPI chính -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card shadow-sm border-0 rounded-3 p-3 bg-white border-start border-success border-4">
                <div class="text-muted small">Tổng Doanh Thu (Đã Khám)</div>
                <div class="fs-4 fw-bold text-success">
                    <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="₫"/>
                </div>
                <div class="small text-muted mt-1">Từ các lịch hẹn thành công</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm border-0 rounded-3 p-3 bg-white border-start border-warning border-4">
                <div class="text-muted small">Lịch Hẹn Chờ Khám</div>
                <div class="fs-4 fw-bold text-warning">
                    ${stats['Submitted']}
                </div>
                <div class="small text-muted mt-1">Trạng thái Submitted</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm border-0 rounded-3 p-3 bg-white border-start border-primary border-4">
                <div class="text-muted small">Đã Khám Thành Công</div>
                <div class="fs-4 fw-bold text-primary">
                    ${stats['Success']}
                </div>
                <div class="small text-muted mt-1">Trạng thái Success</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card shadow-sm border-0 rounded-3 p-3 bg-white border-start border-danger border-4">
                <div class="text-muted small">Lịch Hẹn Đã Hủy</div>
                <div class="fs-4 fw-bold text-danger">
                    ${stats['Cancelled']}
                </div>
                <div class="small text-muted mt-1">Trạng thái Cancelled</div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <!-- Doanh thu theo danh mục dịch vụ -->
        <div class="col-lg-6">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white h-100">
                <h5 class="fw-bold text-secondary mb-3">📊 Doanh Thu Theo Danh Mục Dịch Vụ</h5>
                <c:choose>
                    <c:when test="${not empty revenueByCategory}">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Chuyên Mục Gói Khám</th>
                                        <th class="text-end">Doanh Thu Thu Được</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="entry" items="${revenueByCategory}">
                                        <tr>
                                            <td class="fw-semibold">${entry.key}</td>
                                            <td class="text-end fw-bold text-success">
                                                <fmt:formatNumber value="${entry.value}" type="currency" currencySymbol="₫"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted text-center py-4 mb-0">Chưa có dữ liệu doanh thu hoàn tất.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Xu hướng đặt lịch 7 ngày gần nhất & Đánh giá sao -->
        <div class="col-lg-6">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white mb-4">
                <h5 class="fw-bold text-secondary mb-3">📈 Xu Hướng Đặt Lịch Trong Tuần (7 Ngày Gần Nhất)</h5>
                <c:choose>
                    <c:when test="${not empty trend7Days}">
                        <div class="d-flex justify-content-between align-items-end pt-3" style="height: 140px;">
                            <c:forEach var="trend" items="${trend7Days}">
                                <div class="text-center d-flex flex-column align-items-center" style="width: 12%;">
                                    <span class="small fw-bold text-primary mb-1">${trend.value}</span>
                                    <div class="bg-primary rounded-top w-100" style="height: ${trend.value * 25 + 10}px; max-height: 90px;"></div>
                                    <span class="small text-muted mt-2" style="font-size: 11px;">${trend.key}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted text-center py-3 mb-0">Chưa có lịch đặt nào trong 7 ngày qua.</p>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Đánh giá sao & Khách hàng -->
            <div class="row g-3">
                <div class="col-6">
                    <div class="card shadow-sm border-0 rounded-3 p-3 bg-white text-center">
                        <div class="text-muted small">Điểm Đánh Giá TB</div>
                        <div class="fs-3 fw-bold text-warning">${avgRating} ⭐</div>
                        <div class="small text-muted">Từ phản hồi của phụ huynh</div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card shadow-sm border-0 rounded-3 p-3 bg-white text-center">
                        <div class="text-muted small">Tổng Khách Hàng</div>
                        <div class="fs-3 fw-bold text-primary">${totalContacts} 👥</div>
                        <div class="small text-muted">Bao gồm liên hệ tiếp thị</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

