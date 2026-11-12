<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách bài viết | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="row g-4">
        <!-- Danh sách bài viết (Blogs List) -->
        <div class="col-lg-8">
            <h2 class="fw-bold text-primary mb-4">Cẩm Nang Sức Khỏe Cho Bé</h2>

            <div class="row g-4">
                <c:forEach var="p" items="${posts}">
                    <div class="col-md-6">
                        <div class="card h-100 shadow-sm border-0 rounded-3">
                            <img src="${p.thumbnail}" class="card-img-top" alt="${p.title}" style="height: 180px; object-fit: cover;">
                            <div class="card-body d-flex flex-column">
                                <span class="badge bg-secondary mb-2 align-self-start">${p.categoryName}</span>
                                <h5 class="card-title fw-bold">
                                    <a href="${pageContext.request.contextPath}/blog-detail?id=${p.id}" class="text-dark text-decoration-none">
                                        ${p.title}
                                    </a>
                                </h5>
                                <p class="card-text text-muted small flex-grow-1">${p.briefInfo}</p>
                                <div class="d-flex justify-content-between align-items-center small text-muted mt-3">
                                    <span>✍️ ${p.authorName}</span>
                                    <span><fmt:formatDate value="${p.updatedDate}" pattern="dd/MM/yyyy"/></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty posts}">
                    <div class="col-12">
                        <div class="alert alert-info text-center py-4">
                            Không tìm thấy bài viết nào phù hợp với điều kiện tìm kiếm.
                        </div>
                    </div>
                </c:if>
            </div>

            <!-- Phân trang -->
            <c:if test="${totalPages > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <c:forEach begin="1" end="${totalPages}" var="pageIndex">
                            <li class="page-item ${pageIndex == currentPage ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/blogs?page=${pageIndex}&categoryId=${selectedCategoryId}&keyword=${keyword}">
                                    ${pageIndex}
                                </a>
                            </li>
                        </c:forEach>
                    </ul>
                </nav>
            </c:if>
        </div>

        <!-- Sider: Tìm kiếm, Danh mục, Bài viết mới nhất -->
        <div class="col-lg-4">
            <!-- Ô tìm kiếm bài viết -->
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">🔍 Tìm Kiếm Bài Viết</h5>
                    <form action="${pageContext.request.contextPath}/blogs" method="get">
                        <div class="input-group">
                            <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Nhập từ khóa...">
                            <button class="btn btn-primary" type="submit">Tìm</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Danh mục bài viết -->
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">📂 Danh Mục Bài Viết</h5>
                    <div class="list-group list-group-flush">
                        <a href="${pageContext.request.contextPath}/blogs" 
                           class="list-group-item list-group-item-action ${empty selectedCategoryId ? 'fw-bold text-primary' : ''}">
                            Tất cả chuyên mục
                        </a>
                        <c:forEach var="c" items="${categories}">
                            <a href="${pageContext.request.contextPath}/blogs?categoryId=${c.id}" 
                               class="list-group-item list-group-item-action ${selectedCategoryId == c.id ? 'fw-bold text-primary' : ''}">
                                ${c.name}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <!-- Bài viết mới nhất -->
            <div class="card shadow-sm border-0 rounded-3">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">📰 Bài Viết Mới Nhất</h5>
                    <div class="list-group list-group-flush">
                        <c:forEach var="lp" items="${latestPosts}">
                            <a href="${pageContext.request.contextPath}/blog-detail?id=${lp.id}" class="list-group-item list-group-item-action px-0 py-2 border-bottom">
                                <div class="fw-semibold text-truncate">${lp.title}</div>
                                <small class="text-muted"><fmt:formatDate value="${lp.updatedDate}" pattern="dd/MM/yyyy"/></small>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

