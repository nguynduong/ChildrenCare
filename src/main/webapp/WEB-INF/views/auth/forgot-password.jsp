<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu | Children Care System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-auto py-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow border-0 rounded-3">
                <div class="card-body p-4 p-sm-5">
                    <h3 class="card-title text-center fw-bold mb-3 text-primary">Quên Mật Khẩu</h3>
                    <p class="text-muted text-center small mb-4">
                        Nhập địa chỉ email đăng ký của bạn. Chúng tôi sẽ gửi liên kết để bạn đặt lại mật khẩu mới.
                    </p>

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

                    <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                        <div class="mb-4">
                            <label for="email" class="form-label">Email tài khoản</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   placeholder="name@example.com" required autofocus>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold">Gửi yêu cầu đặt lại</button>
                    </form>

                    <hr class="my-4">
                    <div class="text-center">
                        <a href="${pageContext.request.contextPath}/login" class="small text-decoration-none fw-bold">← Quay lại Đăng nhập</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

