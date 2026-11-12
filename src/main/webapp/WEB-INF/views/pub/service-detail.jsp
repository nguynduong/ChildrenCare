<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${service.title} | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home" class="text-decoration-none">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/services" class="text-decoration-none">Dịch vụ</a></li>
            <li class="breadcrumb-item active" aria-current="page">${service.title}</li>
        </ol>
    </nav>

    <div class="row g-4">
        <!-- Chi tiết dịch vụ & Thư viện ảnh -->
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white mb-4">
                <div class="row g-4">
                    <!-- Ảnh chính & Gallery -->
                    <div class="col-md-6">
                        <img id="mainImage" src="${service.thumbnail}" class="img-fluid rounded-3 shadow-sm mb-3 w-100" 
                             alt="${service.title}" style="height: 280px; object-fit: cover;">
                        
                        <c:if test="${not empty service.images}">
                            <div class="d-flex gap-2 overflow-auto pb-2">
                                <img src="${service.thumbnail}" class="rounded border p-1" width="60" height="60" 
                                     style="object-fit:cover; cursor:pointer;" onclick="document.getElementById('mainImage').src=this.src;">
                                <c:forEach var="img" items="${service.images}">
                                    <img src="${img.imageUrl}" class="rounded border p-1" width="60" height="60" 
                                         style="object-fit:cover; cursor:pointer;" onclick="document.getElementById('mainImage').src=this.src;">
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>

                    <!-- Thông tin tóm tắt & Mua -->
                    <div class="col-md-6 d-flex flex-column">
                        <span class="badge bg-primary-subtle text-primary mb-2 align-self-start">${service.categoryName}</span>
                        <h2 class="fw-bold mb-3">${service.title}</h2>
                        
                        <div class="mb-3">
                            <span class="fs-3 fw-bold text-danger">
                                <fmt:formatNumber value="${service.salePrice}" type="currency" currencySymbol="₫"/>
                            </span>
                            <c:if test="${service.salePrice < service.listPrice}">
                                <span class="text-decoration-line-through text-muted ms-2 fs-5">
                                    <fmt:formatNumber value="${service.listPrice}" type="currency" currencySymbol="₫"/>
                                </span>
                            </c:if>
                        </div>

                        <p class="text-muted small mb-3">${service.briefInfo}</p>
                        
                        <ul class="list-unstyled small text-muted mb-4">
                            <li>👥 Phục vụ mặc định: <strong>${service.numberOfPerson} trẻ/lượt</strong></li>
                            <li>📦 Khả dụng hiện tại: <strong>${service.availableQuantity} lượt khám</strong></li>
                        </ul>

                        <div class="mt-auto d-flex gap-2">
                            <form action="${pageContext.request.contextPath}/cart" method="post" class="flex-grow-1">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="serviceId" value="${service.id}">
                                <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">
                                    🛒 Thêm Vào Giỏ Đặt Lịch
                                </button>
                            </form>
                            <a href="${pageContext.request.contextPath}/feedback?serviceId=${service.id}" class="btn btn-outline-secondary py-2">
                                💬 Đánh giá
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Mô tả chi tiết HTML -->
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white">
                <h4 class="fw-bold text-primary mb-3">Mô Tả Chi Tiết Gói Khám</h4>
                <div class="lh-lg">
                    ${service.description}
                </div>
            </div>
        </div>

        <!-- Sider: Danh mục dịch vụ khác -->
        <div class="col-lg-4">
            <div class="card shadow-sm border-0 rounded-3 mb-4">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">🏷️ Gói Dịch Vụ Theo Chuyên Mục</h5>
                    <div class="list-group list-group-flush">
                        <c:forEach var="c" items="${categories}">
                            <a href="${pageContext.request.contextPath}/services?categoryId=${c.id}" class="list-group-item list-group-item-action">
                                ${c.name}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0 rounded-3 bg-light p-3">
                <h6 class="fw-bold text-primary">Quy trình khám tại ChildrenCare:</h6>
                <ol class="small text-muted ps-3 mb-0">
                    <li>Đặt lịch trực tuyến & nhận xác nhận qua Email</li>
                    <li>Đến trung tâm theo khung giờ hẹn đã đăng ký</li>
                    <li>Bác sĩ chuyên khoa thăm khám trực tiếp</li>
                    <li>Nhận kết quả chẩn đoán và đơn thuốc điện tử</li>
                </ol>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

