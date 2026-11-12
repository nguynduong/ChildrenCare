<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Góp ý & Đánh giá | Children Care Center</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow-sm border-0 rounded-4 p-4 p-md-5 bg-white">
                <h2 class="fw-bold text-primary mb-2">Góp Ý & Đánh Giá Dịch Vụ</h2>
                <p class="text-muted mb-4">Mọi phản hồi từ phụ huynh đều giúp chúng tôi hoàn thiện chất lượng chăm sóc và phục vụ các bé tốt hơn.</p>

                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        ${errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        ${successMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/feedback" method="post">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Họ và tên của bạn <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="fullName" 
                                   value="${not empty sessionScope.currentUser ? sessionScope.currentUser.fullName : ''}" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Giới tính</label>
                            <select class="form-select" name="gender">
                                <option value="Male" ${sessionScope.currentUser.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                <option value="Female" ${sessionScope.currentUser.gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                <option value="Other" ${sessionScope.currentUser.gender == 'Other' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Địa chỉ Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" name="email" 
                                   value="${not empty sessionScope.currentUser ? sessionScope.currentUser.email : ''}" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại liên hệ <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" name="mobile" 
                                   value="${not empty sessionScope.currentUser ? sessionScope.currentUser.mobile : ''}" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Gói dịch vụ đã trải nghiệm (Tùy chọn)</label>
                        <select class="form-select" name="serviceId">
                            <option value="">-- Đánh giá chung toàn hệ thống --</option>
                            <c:forEach var="s" items="${services}">
                                <option value="${s.id}" ${selectedService.id == s.id ? 'selected' : ''}>${s.title}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Mức độ hài lòng của bạn</label>
                        <div class="d-flex gap-4">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="ratedStar" id="star5" value="5" checked>
                                <label class="form-check-label" for="star5">⭐⭐⭐⭐⭐ Rất hài lòng</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="ratedStar" id="star4" value="4">
                                <label class="form-check-label" for="star4">⭐⭐⭐⭐ Hài lòng</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="ratedStar" id="star3" value="3">
                                <label class="form-check-label" for="star3">⭐⭐⭐ Bình thường</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="ratedStar" id="star2" value="2">
                                <label class="form-check-label" for="star2">⭐⭐ Chưa tốt</label>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Nội dung chia sẻ / Góp ý chi tiết <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="content" rows="4" placeholder="Cảm nhận của bạn về bác sĩ, thái độ phục vụ của y tá, cơ sở vật chất..." required></textarea>
                    </div>

                    <div class="mb-4">
                        <label class="form-label">URL Ảnh đính kèm (nếu có)</label>
                        <input type="text" class="form-control" name="imageUrl" placeholder="https://example.com/feedback-image.jpg">
                    </div>

                    <button type="submit" class="btn btn-primary px-5 py-2 fw-semibold">
                        Gửi Đánh Giá Của Bạn
                    </button>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

