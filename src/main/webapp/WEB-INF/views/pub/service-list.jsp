<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách dịch vụ | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="row g-4">
        <!-- Danh sách dịch vụ (Services List) -->
        <div class="col-lg-8">
            <h2 class="fw-bold text-primary mb-4">Các Gói Dịch Vụ Khám & Chăm Sóc</h2>

            <div class="row g-4">
                <c:forEach var="srv" items="${services}">
                    <div class="col-md-6">
                        <div class="card h-100 shadow-sm border-0 rounded-3">
                            <img src="${srv.thumbnail}" class="card-img-top" alt="${srv.title}" style="height: 190px; object-fit: cover;">
                            <div class="card-body d-flex flex-column">
                                <span class="badge bg-primary-subtle text-primary mb-2 align-self-start">${srv.categoryName}</span>
                                <h5 class="card-title fw-bold">
                                    <a href="${pageContext.request.contextPath}/service-detail?id=${srv.id}" class="text-dark text-decoration-none">
                                        ${srv.title}
                                    </a>
                                </h5>
                                <p class="card-text text-muted small flex-grow-1">${srv.briefInfo}</p>
                                
                                <div class="mb-3">
                                    <span class="fs-5 fw-bold text-danger">
                                        <fmt:formatNumber value="${srv.salePrice}" type="currency" currencySymbol="₫"/>
                                    </span>
                                    <c:if test="${srv.salePrice < srv.listPrice}">
                                        <small class="text-decoration-line-through text-muted ms-2">
                                            <fmt:formatNumber value="${srv.listPrice}" type="currency" currencySymbol="₫"/>
                                        </small>
                                    </c:if>
                                </div>

                                <div class="d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/service-detail?id=${srv.id}" class="btn btn-outline-primary btn-sm flex-fill">Chi tiết</a>
                                    <a href="${pageContext.request.contextPath}/feedback?serviceId=${srv.id}" class="btn btn-outline-secondary btn-sm">💬 Đánh giá</a>
                                    <form action="${pageContext.request.contextPath}/cart" method="post" class="flex-fill">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="serviceId" value="${srv.id}">
                                        <button type="submit" class="btn btn-primary btn-sm w-100">🛒 Mua/Đặt</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty services}">
                    <div class="col-12">
                        <div class="alert alert-info text-center py-4">
                            Không tìm thấy dịch vụ nào phù hợp với bộ lọc.
                        </div>
                    </div>
                </c:if>
            </div>

            <!-- Phân trang -->
            <c:if test="${totalPages > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <li class="page-item ${p == currentPage ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/services?page=${p}&categoryId=${selectedCategoryId}&keyword=${keyword}">
                                    ${p}
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>
        </div>

        <!-- Sider: Tìm kiếm & Lọc danh mục dịch vụ -->
        <div class="col-lg-4">
            <!-- Tìm kiếm -->
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">🔍 Tìm Kiếm Dịch Vụ</h5>
                    <form action="${pageContext.request.contextPath}/services" method="get">
                        <div class="input-group">
                            <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tên gói, mô tả...">
                            <button class="btn btn-primary" type="submit">Tìm</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Danh mục dịch vụ -->
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">🏷️ Danh Mục Dịch Vụ</h5>
                    <div class="list-group list-group-flush">
                        <a href="${pageContext.request.contextPath}/services" 
                           class="list-group-item list-group-item-action ${empty selectedCategoryId ? 'fw-bold text-primary' : ''}">
                            Tất cả gói dịch vụ
                        </a>
                        <c:forEach var="cat" items="${categories}">
                            <a href="${pageContext.request.contextPath}/services?categoryId=${cat.id}" 
                               class="list-group-item list-group-item-action ${selectedCategoryId == cat.id ? 'fw-bold text-primary' : ''}">
                                ${cat.name}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <!-- Hotline tư vấn -->
            <div class="card shadow-sm border-0 rounded-3 bg-white p-3 border-start border-primary border-4">
                <h6 class="fw-bold text-primary mb-1">Cần hỗ trợ tư vấn chọn gói?</h6>
                <p class="small text-muted mb-2">Đội ngũ điều dưỡng sẽ hướng dẫn mẹ chọn gói khám phù hợp nhất theo tháng tuổi của bé.</p>
                <div class="fw-bold text-danger fs-5">Hotline: 1900 6868</div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

