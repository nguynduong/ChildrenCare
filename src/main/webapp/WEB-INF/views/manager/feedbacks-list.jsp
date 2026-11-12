<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý phản hồi (Feedbacks) | Manager ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Quản Lý Phản Hồi Khách Hàng</h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalFeedbacks} đánh giá</p>
        </div>
    </div>

    <!-- Bộ lọc & Tìm kiếm -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/manager/feedbacks" method="get" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label small text-muted">Từ khóa</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tên khách, nội dung...">
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted">Gói dịch vụ</label>
                    <select class="form-select" name="serviceId">
                        <option value="">-- Tất cả dịch vụ --</option>
                        <c:forEach var="s" items="${services}">
                            <option value="${s.id}" ${selectedServiceId == s.id ? 'selected' : ''}>${s.title}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted">Số sao</label>
                    <select class="form-select" name="ratedStar">
                        <option value="">-- Tất cả --</option>
                        <option value="5" ${selectedRatedStar == 5 ? 'selected' : ''}>5 Sao ⭐⭐⭐⭐⭐</option>
                        <option value="4" ${selectedRatedStar == 4 ? 'selected' : ''}>4 Sao ⭐⭐⭐⭐</option>
                        <option value="3" ${selectedRatedStar == 3 ? 'selected' : ''}>3 Sao ⭐⭐⭐</option>
                        <option value="2" ${selectedRatedStar == 2 ? 'selected' : ''}>2 Sao ⭐⭐</option>
                        <option value="1" ${selectedRatedStar == 1 ? 'selected' : ''}>1 Sao ⭐</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted">Trạng thái</label>
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="Published" ${selectedStatus == 'Published' ? 'selected' : ''}>Published (Hiện)</option>
                        <option value="Hidden" ${selectedStatus == 'Hidden' ? 'selected' : ''}>Hidden (Ẩn)</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-outline-primary w-100">🔍 Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng danh sách Feedback -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Khách Hàng</th>
                        <th>Dịch Vụ</th>
                        <th>Đánh Giá</th>
                        <th>Nội Dung</th>
                        <th>Ngày Gửi</th>
                        <th>Trạng Thái</th>
                        <th class="text-end">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="f" items="${feedbacks}">
                        <tr>
                            <td>#${f.id}</td>
                            <td>
                                <div class="fw-semibold">${f.fullName}</div>
                                <div class="small text-muted">${f.email} • ${f.mobile}</div>
                            </td>
                            <td>${not empty f.serviceTitle ? f.serviceTitle : '<span class="text-muted">Đánh giá chung</span>'}</td>
                            <td>
                                <span class="text-warning fw-bold">${f.ratedStar} ⭐</span>
                            </td>
                            <td style="max-width:250px;">
                                <div class="text-truncate">${f.content}</div>
                            </td>
                            <td><fmt:formatDate value="${f.createdDate}" pattern="dd/MM/yyyy"/></td>
                            <td>
                                <span class="badge ${f.status == 'Published' ? 'bg-success' : 'bg-danger'}">
                                    ${f.status}
                                </span>
                            </td>
                            <td class="text-end">
                                <form action="${pageContext.request.contextPath}/manager/feedbacks" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${f.id}">
                                    <input type="hidden" name="newStatus" value="${f.status == 'Published' ? 'Hidden' : 'Published'}">
                                    <button type="submit" class="btn btn-sm ${f.status == 'Published' ? 'btn-outline-danger' : 'btn-outline-success'}">
                                        ${f.status == 'Published' ? 'Ẩn' : 'Hiện'}
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty feedbacks}">
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Không có phản hồi nào phù hợp.</td>
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
                            <a class="page-link" href="${pageContext.request.contextPath}/manager/feedbacks?page=${p}&serviceId=${selectedServiceId}&ratedStar=${selectedRatedStar}&status=${selectedStatus}&keyword=${keyword}">
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

