<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${post.title} | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="row g-4">
        <!-- Chi tiết bài viết -->
        <div class="col-lg-8">
            <article class="card shadow-sm border-0 rounded-3 p-4 p-md-5 bg-white">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb small">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Trang chủ</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/blogs" class="text-decoration-none">Bài viết</a></li>
                        <li class="breadcrumb-item active" aria-current="page">${post.categoryName}</li>
                    </ol>
                </nav>

                <h1 class="fw-bold mb-3 text-dark">${post.title}</h1>

                <div class="d-flex align-items-center gap-3 text-muted small border-bottom pb-3 mb-4">
                    <span>✍️ Tác giả: <strong>${post.authorName}</strong></span>
                    <span>📅 Ngày cập nhật: <fmt:formatDate value="${post.updatedDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                    <span class="badge bg-secondary">${post.categoryName}</span>
                </div>

                <div class="lead fw-semibold text-muted mb-4 fst-italic">
                    ${post.briefInfo}
                </div>

                <c:if test="${not empty post.thumbnail}">
                    <div class="text-center mb-4">
                        <img src="${post.thumbnail}" class="img-fluid rounded-3 shadow-sm" alt="${post.title}" style="max-height: 400px; object-fit: cover;">
                    </div>
                </c:if>

                <div class="article-content lh-lg">
                    ${post.description}
                </div>
            </article>
        </div>

        <!-- Sider -->
        <div class="col-lg-4">
            <!-- Tìm kiếm -->
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">🔍 Tìm Kiếm Bài Viết</h5>
                    <form action="${pageContext.request.contextPath}/blogs" method="get">
                        <div class="input-group">
                            <input type="text" class="form-control" name="keyword" placeholder="Nhập từ khóa...">
                            <button class="btn btn-primary" type="submit">Tìm</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Danh mục -->
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">📂 Danh Mục Bài Viết</h5>
                    <div class="list-group list-group-flush">
                        <c:forEach var="c" items="${categories}">
                            <a href="${pageContext.request.contextPath}/blogs?categoryId=${c.id}" class="list-group-item list-group-item-action">
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

