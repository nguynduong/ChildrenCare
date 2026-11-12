<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Children Care Center - Chăm sóc sức khỏe nhi khoa hàng đầu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<!-- Carousel Sliders -->
<c:if test="${not empty sliders}">
    <section class="container my-4">
        <div id="homeCarousel" class="carousel slide rounded-4 overflow-hidden shadow-sm" data-bs-ride="carousel">
            <div class="carousel-indicators">
                <c:forEach var="s" items="${sliders}" varStatus="loop">
                    <button type="button" data-bs-target="#homeCarousel" data-bs-slide-to="${loop.index}" 
                            class="${loop.first ? 'active' : ''}"></button>
                </c:forEach>
            </div>
            <div class="carousel-inner" style="max-height: 420px;">
                <c:forEach var="s" items="${sliders}" varStatus="loop">
                    <div class="carousel-item ${loop.first ? 'active' : ''}">
                        <a href="${s.backLink}">
                            <img src="${s.imageUrl}" class="d-block w-100" alt="${s.title}" style="object-fit:cover; height:420px;">
                            <div class="carousel-caption d-none d-md-block bg-dark bg-opacity-50 rounded-3 p-3">
                                <h5>${s.title}</h5>
                                <p class="small mb-0">${s.notes}</p>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
            <button class="carousel-control-prev" type="button" data-bs-target="#homeCarousel" data-bs-slide="prev">
                <span class="carousel-control-prev-icon"></span>
            </button>
            <button class="carousel-control-next" type="button" data-bs-target="#homeCarousel" data-bs-slide="next">
                <span class="carousel-control-next-icon"></span>
            </button>
        </div>
    </section>
</c:if>

<main class="container mb-5">
    <div class="row g-4">
        <!-- Main Content: Featured Services & Hot Posts -->
        <div class="col-lg-8">
            <!-- Dịch vụ nổi bật -->
            <section class="mb-5">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="fw-bold text-primary mb-0">🌟 Gói Dịch Vụ Nổi Bật</h3>
                    <a href="${pageContext.request.contextPath}/services" class="btn btn-sm btn-outline-primary">Xem tất cả →</a>
                </div>
                <div class="row g-3">
                    <c:forEach var="srv" items="${featuredServices}">
                        <div class="col-md-6">
                            <div class="card h-100 shadow-sm border-0 rounded-3 hover-shadow">
                                <img src="${srv.thumbnail}" class="card-img-top" alt="${srv.title}" style="height: 180px; object-fit: cover;">
                                <div class="card-body d-flex flex-column">
                                    <span class="badge bg-primary-subtle text-primary mb-2 align-self-start">${srv.categoryName}</span>
                                    <h5 class="card-title fw-bold">
                                        <a href="${pageContext.request.contextPath}/service-detail?id=${srv.id}" class="text-dark text-decoration-none">
                                            ${srv.title}
                                        </a>
                                    </h5>
                                    <p class="card-text text-muted small flex-grow-1">${srv.briefInfo}</p>
                                    <div class="d-flex justify-content-between align-items-baseline mb-3">
                                        <div>
                                            <span class="fs-5 fw-bold text-danger">
                                                <fmt:formatNumber value="${srv.salePrice}" type="currency" currencySymbol="₫"/>
                                            </span>
                                            <c:if test="${srv.salePrice < srv.listPrice}">
                                                <small class="text-decoration-line-through text-muted ms-2">
                                                    <fmt:formatNumber value="${srv.listPrice}" type="currency" currencySymbol="₫"/>
                                                </small>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a href="${pageContext.request.contextPath}/service-detail?id=${srv.id}" class="btn btn-outline-primary btn-sm flex-fill">Chi tiết</a>
                                        <form action="${pageContext.request.contextPath}/cart" method="post" class="flex-fill">
                                            <input type="hidden" name="action" value="add">
                                            <input type="hidden" name="serviceId" value="${srv.id}">
                                            <button type="submit" class="btn btn-primary btn-sm w-100">🛒 Đặt lịch</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>

            <!-- Bài viết nổi bật (Hot Posts) -->
            <section>
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="fw-bold text-primary mb-0">🔥 Bài Viết & Kiến Thức Nhi Khoa</h3>
                    <a href="${pageContext.request.contextPath}/blogs" class="btn btn-sm btn-outline-primary">Xem thêm bài viết →</a>
                </div>
                <div class="row g-3">
                    <c:forEach var="p" items="${hotPosts}">
                        <div class="col-md-6">
                            <div class="card h-100 shadow-sm border-0 rounded-3">
                                <img src="${p.thumbnail}" class="card-img-top" alt="${p.title}" style="height: 160px; object-fit: cover;">
                                <div class="card-body d-flex flex-column">
                                    <span class="badge bg-secondary mb-2 align-self-start">${p.categoryName}</span>
                                    <h6 class="card-title fw-bold">
                                        <a href="${pageContext.request.contextPath}/blog-detail?id=${p.id}" class="text-dark text-decoration-none">
                                            ${p.title}
                                        </a>
                                    </h6>
                                    <p class="card-text text-muted small flex-grow-1">${p.briefInfo}</p>
                                    <div class="small text-muted mt-2">
                                        <span>✍️ ${p.authorName}</span> • 
                                        <span><fmt:formatDate value="${p.updatedDate}" pattern="dd/MM/yyyy"/></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </div>

        <!-- Sider: Bài viết mới nhất & Thông tin liên hệ -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold text-primary mb-3">📰 Bài Viết Mới Nhất</h5>
                    <div class="list-group list-group-flush">
                        <c:forEach var="lp" items="${latestPosts}">
                            <a href="${pageContext.request.contextPath}/blog-detail?id=${lp.id}" class="list-group-item list-group-item-action px-0 py-2 border-bottom">
                                <div class="fw-semibold text-truncate mb-1">${lp.title}</div>
                                <small class="text-muted"><fmt:formatDate value="${lp.updatedDate}" pattern="dd/MM/yyyy"/></small>
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0 rounded-3 bg-primary text-white p-3">
                <div class="card-body">
                    <h5 class="fw-bold mb-2">📞 Cần Tư Vấn Khám Bệnh?</h5>
                    <p class="small mb-3">Đội ngũ y bác sĩ và chuyên gia dinh dưỡng sẵn sàng hỗ trợ mẹ và bé 24/7.</p>
                    <a href="tel:19006868" class="btn btn-light fw-bold text-primary w-100">Gọi Hotline: 1900 6868</a>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

