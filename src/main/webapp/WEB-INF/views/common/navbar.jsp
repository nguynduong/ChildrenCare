<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<header class="border-bottom bg-white shadow-sm sticky-top">
    <nav class="navbar navbar-expand-lg navbar-light container">
        <a class="navbar-brand fw-bold text-primary fs-4" href="${pageContext.request.contextPath}/home">
            👶 ChildrenCare
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="mainNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'home' ? 'active fw-bold text-primary' : ''}" 
                       href="${pageContext.request.contextPath}/home">Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'services' ? 'active fw-bold text-primary' : ''}" 
                       href="${pageContext.request.contextPath}/services">Dịch vụ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'blogs' ? 'active fw-bold text-primary' : ''}" 
                       href="${pageContext.request.contextPath}/blogs">Bài viết</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${activePage == 'feedback' ? 'active fw-bold text-primary' : ''}" 
                       href="${pageContext.request.contextPath}/feedback">Góp ý & Đánh giá</a>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-3">
                <!-- Giỏ hàng (Cart) -->
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-primary position-relative">
                    🛒 Giỏ lịch hẹn
                    <c:if test="${not empty sessionScope.cart and sessionScope.cart.totalItems > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                            ${sessionScope.cart.totalItems}
                        </span>
                    </c:if>
                </a>

                <!-- User Session Menu -->
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <div class="dropdown">
                            <button class="btn btn-secondary dropdown-toggle d-flex align-items-center gap-2" 
                                    type="button" id="userMenuBtn" data-bs-toggle="dropdown">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.currentUser.avatarUrl}">
                                        <img src="${sessionScope.currentUser.avatarUrl}" alt="Avatar" 
                                             class="rounded-circle" width="28" height="28" style="object-fit:cover;">
                                    </c:when>
                                    <c:otherwise>
                                        👤
                                    </c:otherwise>
                                </c:choose>
                                <span>${sessionScope.currentUser.fullName}</span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end shadow">
                                <li class="dropdown-header">Vai trò: <strong>${sessionScope.currentUser.roleName}</strong></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">Hồ sơ cá nhân</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/change-password">Đổi mật khẩu</a></li>
                                
                                <!-- Menu dành riêng cho Customer -->
                                <c:if test="${sessionScope.currentUser.roleId == 1}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/my-reservations">Lịch hẹn của tôi</a></li>
                                </c:if>

                                <!-- Menu dành riêng cho Staff (Doctor/Nurse) -->
                                <c:if test="${sessionScope.currentUser.roleId == 2 or sessionScope.currentUser.roleId == 3}">
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/staff/reservations">Lịch khám được giao</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/staff/medical-examination">Hồ sơ khám & đơn thuốc</a></li>
                                </c:if>

                                <!-- Menu dành riêng cho Manager -->
                                <c:if test="${sessionScope.currentUser.roleId == 4}">
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/reservations">Quản lý đặt lịch</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/services">Quản lý dịch vụ</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/posts">Quản lý bài viết</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/sliders">Quản lý sliders</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/customers">Quản lý khách hàng</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/manager/feedbacks">Quản lý phản hồi</a></li>
                                </c:if>

                                <!-- Menu dành riêng cho Admin -->
                                <c:if test="${sessionScope.currentUser.roleId == 5}">
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển (Dashboard)</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/users">Quản lý người dùng</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/settings">Cấu hình hệ thống (Settings)</a></li>
                                </c:if>

                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-primary">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Đăng ký</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>
</header>

