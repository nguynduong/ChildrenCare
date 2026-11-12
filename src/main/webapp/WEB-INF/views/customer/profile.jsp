<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân | Children Care System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            <div class="card shadow-sm border-0 rounded-3">
                <div class="card-body p-4 p-md-5">
                    <h3 class="card-title fw-bold text-primary mb-4">Hồ Sơ Cá Nhân</h3>

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

                    <form action="${pageContext.request.contextPath}/profile" method="post">
                        <div class="mb-3 text-center">
                            <c:choose>
                                <c:when test="${not empty user.avatarUrl}">
                                    <img src="${user.avatarUrl}" alt="Avatar" class="rounded-circle mb-2" width="100" height="100" style="object-fit:cover;">
                                </c:when>
                                <c:otherwise>
                                    <div class="rounded-circle bg-secondary text-white d-inline-flex align-items-center justify-content-center mb-2" style="width:100px; height:100px; font-size:40px;">
                                        👤
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <label for="avatarUrl" class="form-label small text-muted">URL Ảnh đại diện</label>
                                <input type="text" class="form-control form-control-sm text-center" id="avatarUrl" name="avatarUrl" 
                                       value="${user.avatarUrl}" placeholder="https://example.com/avatar.jpg">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label text-muted">Địa chỉ Email (Không được sửa)</label>
                            <input type="email" class="form-control bg-light" value="${user.email}" readonly disabled>
                        </div>

                        <div class="mb-3">
                            <label for="fullName" class="form-label">Họ và tên</label>
                            <input type="text" class="form-control" id="fullName" name="fullName" value="${user.fullName}" required>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Giới tính</label>
                                <select class="form-select" name="gender">
                                    <option value="Male" ${user.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                    <option value="Female" ${user.gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                    <option value="Other" ${user.gender == 'Other' ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="mobile" class="form-label">Số điện thoại</label>
                                <input type="tel" class="form-control" id="mobile" name="mobile" value="${user.mobile}" required>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="address" class="form-label">Địa chỉ</label>
                            <input type="text" class="form-control" id="address" name="address" value="${user.address}">
                        </div>

                        <div class="d-flex justify-content-between align-items-center">
                            <a href="${pageContext.request.contextPath}/change-password" class="text-decoration-none">Đổi mật khẩu?</a>
                            <button type="submit" class="btn btn-primary px-4 fw-semibold">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

