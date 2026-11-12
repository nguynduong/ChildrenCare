<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách khách hàng (Customers/Contacts) | ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Khách Hàng & Liên Hệ Tiếp Thị</h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalContacts} khách hàng</p>
        </div>
    </div>

    <!-- Bộ lọc & Tìm kiếm -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/manager/customers" method="get" class="row g-3">
                <div class="col-md-6">
                    <label class="form-label small text-muted">Từ khóa</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tên khách hàng, email, số điện thoại...">
                </div>
                <div class="col-md-4">
                    <label class="form-label small text-muted">Trạng thái khách hàng</label>
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="Contact" ${selectedStatus == 'Contact' ? 'selected' : ''}>Contact (Mới liên hệ)</option>
                        <option value="Potential" ${selectedStatus == 'Potential' ? 'selected' : ''}>Potential (Tiềm năng)</option>
                        <option value="Customer" ${selectedStatus == 'Customer' ? 'selected' : ''}>Customer (Đã khám bệnh)</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-outline-primary w-100">🔍 Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng danh sách Contacts -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Họ và Tên</th>
                        <th>Email</th>
                        <th>Số Điện Thoại</th>
                        <th>Giới Tính</th>
                        <th>Địa Chỉ</th>
                        <th>Phân Loại</th>
                        <th class="text-end">Chi Tiết</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${contacts}">
                        <tr>
                            <td>#${c.id}</td>
                            <td class="fw-semibold">${c.fullName}</td>
                            <td>${c.email}</td>
                            <td>${c.mobile}</td>
                            <td>${c.gender}</td>
                            <td style="max-width:200px;"><div class="text-truncate">${c.address}</div></td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.status == 'Customer'}">
                                        <span class="badge bg-success">Customer</span>
                                    </c:when>
                                    <c:when test="${c.status == 'Potential'}">
                                        <span class="badge bg-warning text-dark">Potential</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">Contact</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <a href="${pageContext.request.contextPath}/manager/customer-detail?id=${c.id}" class="btn btn-sm btn-outline-primary">
                                    Lịch sử thay đổi
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty contacts}">
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Không tìm thấy khách hàng nào.</td>
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
                            <a class="page-link" href="${pageContext.request.contextPath}/manager/customers?page=${p}&status=${selectedStatus}&keyword=${keyword}">
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

