<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản | Children Care System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-auto py-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow border-0 rounded-3">
                <div class="card-body p-4 p-sm-5">
                    <h3 class="card-title text-center fw-bold mb-4 text-primary">Tạo Tài Khoản Mới</h3>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="post">
                        <div class="mb-3">
                            <label for="fullName" class="form-label">Họ và tên <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="fullName" name="fullName" 
                                   value="${fullName}" placeholder="Nguyễn Văn A" required>
                        </div>

                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Giới tính <span class="text-danger">*</span></label>
                                <select class="form-select" name="gender">
                                    <option value="Male" ${gender == 'Male' ? 'selected' : ''}>Nam</option>
                                    <option value="Female" ${gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                    <option value="Other" ${gender == 'Other' ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="mobile" class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                                <input type="tel" class="form-control" id="mobile" name="mobile" 
                                       value="${mobile}" placeholder="0912345678" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="email" class="form-label">Địa chỉ Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="${email}" placeholder="name@example.com" required>
                        </div>

                        <div class="mb-3">
                            <label for="address" class="form-label">Địa chỉ liên hệ</label>
                            <input type="text" class="form-control" id="address" name="address" 
                                   value="${address}" placeholder="Số nhà, đường, quận/huyện...">
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Mật khẩu <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Tối thiểu 8 ký tự, 1 hoa, 1 thường, 1 số" required>
                        </div>

                        <div class="mb-4">
                            <label for="confirmPassword" class="form-label">Xác nhận mật khẩu <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                   placeholder="Nhập lại mật khẩu" required>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">Đăng ký</button>
                    </form>

                    <hr class="my-4">
                    <div class="text-center">
                        <span class="text-muted small">Đã có tài khoản?</span>
                        <a href="${pageContext.request.contextPath}/login" class="small text-decoration-none fw-bold">Đăng nhập</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

