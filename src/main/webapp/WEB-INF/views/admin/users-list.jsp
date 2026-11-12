<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý người dùng (Users List) | Admin ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Quản Lý Người Dùng</h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalUsers} người dùng</p>
        </div>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addUserModal">
            ➕ Thêm Người Dùng Mới
        </button>
    </div>

    <c:if test="${not empty sessionScope.flashSuccess}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.flashSuccess}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="flashSuccess" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.flashError}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${sessionScope.flashError}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="flashError" scope="session"/>
    </c:if>

    <!-- Bộ lọc & Tìm kiếm -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin/users" method="get" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label small text-muted">Từ khóa</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tên, email, SĐT...">
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted">Vai trò (Role)</label>
                    <select class="form-select" name="roleId">
                        <option value="">-- Tất cả vai trò --</option>
                        <c:forEach var="r" items="${roles}">
                            <option value="${r.id}" ${selectedRoleId == r.id ? 'selected' : ''}>${r.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted">Giới tính</label>
                    <select class="form-select" name="gender">
                        <option value="">-- Tất cả --</option>
                        <option value="Male" ${selectedGender == 'Male' ? 'selected' : ''}>Nam</option>
                        <option value="Female" ${selectedGender == 'Female' ? 'selected' : ''}>Nữ</option>
                        <option value="Other" ${selectedGender == 'Other' ? 'selected' : ''}>Khác</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted">Trạng thái</label>
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="Active" ${selectedStatus == 'Active' ? 'selected' : ''}>Active</option>
                        <option value="Inactive" ${selectedStatus == 'Inactive' ? 'selected' : ''}>Inactive</option>
                        <option value="Unverified" ${selectedStatus == 'Unverified' ? 'selected' : ''}>Unverified</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-outline-primary w-100">🔍 Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng danh sách người dùng -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Họ và tên</th>
                        <th>Email</th>
                        <th>Điện thoại</th>
                        <th>Giới tính</th>
                        <th>Vai trò</th>
                        <th>Trạng thái</th>
                        <th class="text-end">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>#${u.id}</td>
                            <td class="fw-semibold">
                                <c:choose>
                                    <c:when test="${not empty u.avatarUrl}">
                                        <img src="${u.avatarUrl}" class="rounded-circle me-2" width="28" height="28" style="object-fit:cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <span class="me-2">👤</span>
                                    </c:otherwise>
                                </c:choose>
                                ${u.fullName}
                            </td>
                            <td>${u.email}</td>
                            <td>${u.mobile}</td>
                            <td>${u.gender}</td>
                            <td><span class="badge bg-secondary">${u.roleName}</span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${u.status == 'Active'}">
                                        <span class="badge bg-success">Active</span>
                                    </c:when>
                                    <c:when test="${u.status == 'Inactive'}">
                                        <span class="badge bg-danger">Inactive</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-warning text-dark">Unverified</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <button type="button" class="btn btn-sm btn-outline-primary" 
                                        data-bs-toggle="modal" data-bs-target="#editUserModal_${u.id}">
                                    ✏️ Sửa
                                </button>
                            </td>
                        </tr>

                        <!-- Modal Cập nhật User -->
                        <div class="modal fade" id="editUserModal_${u.id}" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form action="${pageContext.request.contextPath}/admin/users" method="post">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="userId" value="${u.id}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Cập nhật: ${u.fullName}</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-3">
                                                <label class="form-label text-muted">Email (Không đổi)</label>
                                                <input type="email" class="form-control" value="${u.email}" readonly disabled>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Vai trò (Role)</label>
                                                <select class="form-select" name="roleId" required>
                                                    <c:forEach var="r" items="${roles}">
                                                        <option value="${r.id}" ${u.roleId == r.id ? 'selected' : ''}>${r.name}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Trạng thái (Status)</label>
                                                <select class="form-select" name="status" required>
                                                    <option value="Active" ${u.status == 'Active' ? 'selected' : ''}>Active</option>
                                                    <option value="Inactive" ${u.status == 'Inactive' ? 'selected' : ''}>Inactive (Khóa)</option>
                                                    <option value="Unverified" ${u.status == 'Unverified' ? 'selected' : ''}>Unverified</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                            <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty users}">
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Không tìm thấy người dùng nào phù hợp.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Phân trang -->
        <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white d-flex justify-content-between align-items-center">
                <span class="small text-muted">Trang ${currentPage} / ${totalPages}</span>
                <ul class="pagination pagination-sm mb-0">
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/users?page=${p}&keyword=${keyword}&roleId=${selectedRoleId}&gender=${selectedGender}&status=${selectedStatus}">
                                ${p}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>
    </div>
</main>

<!-- Modal Thêm Người Dùng Mới -->
<div class="modal fade" id="addUserModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/users" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Thêm Người Dùng Mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="fullName" required>
                    </div>
                    <div class="row mb-3">
                        <div class="col-6">
                            <label class="form-label">Giới tính</label>
                            <select class="form-select" name="gender">
                                <option value="Male">Nam</option>
                                <option value="Female">Nữ</option>
                                <option value="Other">Khác</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Điện thoại <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" name="mobile" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email đăng nhập <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" name="email" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Vai trò <span class="text-danger">*</span></label>
                        <select class="form-select" name="roleId" required>
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.id}">${r.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Địa chỉ</label>
                        <input type="text" class="form-control" name="address">
                    </div>
                    <p class="text-muted small mb-0">Mật khẩu khởi tạo sẽ được hệ thống sinh ngẫu nhiên và hiển thị sau khi tạo.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Tạo Mới</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

