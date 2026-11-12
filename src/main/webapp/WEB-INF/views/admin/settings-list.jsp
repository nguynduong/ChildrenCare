<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cấu hình hệ thống (Settings) | Admin ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Cấu Hình Hệ Thống & Danh Mục</h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalSettings} mục cấu hình</p>
        </div>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSettingModal">
            ➕ Thêm Cấu Hình Mới
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

    <!-- Bộ lọc -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/admin/settings" method="get" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label small text-muted">Từ khóa (Tên / Giá trị)</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tìm theo tên hoặc giá trị...">
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted">Loại (Type)</label>
                    <select class="form-select" name="type">
                        <option value="">-- Tất cả loại --</option>
                        <option value="UserRole" ${selectedType == 'UserRole' ? 'selected' : ''}>UserRole</option>
                        <option value="PostCategory" ${selectedType == 'PostCategory' ? 'selected' : ''}>PostCategory</option>
                        <option value="ServiceCategory" ${selectedType == 'ServiceCategory' ? 'selected' : ''}>ServiceCategory</option>
                        <option value="AdminMenu" ${selectedType == 'AdminMenu' ? 'selected' : ''}>AdminMenu</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted">Trạng thái</label>
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="Active" ${selectedStatus == 'Active' ? 'selected' : ''}>Active</option>
                        <option value="Inactive" ${selectedStatus == 'Inactive' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-outline-primary w-100">🔍 Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng cấu hình -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Loại (Type)</th>
                        <th>Tên hiển thị (Name)</th>
                        <th>Giá trị (Value)</th>
                        <th>Mô tả</th>
                        <th>Trạng thái</th>
                        <th class="text-end">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${settings}">
                        <tr>
                            <td>#${s.id}</td>
                            <td><span class="badge bg-info text-dark">${s.type}</span></td>
                            <td class="fw-semibold">${s.name}</td>
                            <td><code>${s.value}</code></td>
                            <td class="text-muted small">${s.description}</td>
                            <td>
                                <span class="badge ${s.status == 'Active' ? 'bg-success' : 'bg-danger'}">
                                    ${s.status}
                                </span>
                            </td>
                            <td class="text-end">
                                <button type="button" class="btn btn-sm btn-outline-primary me-1" 
                                        data-bs-toggle="modal" data-bs-target="#editSettingModal_${s.id}">
                                    ✏️ Sửa
                                </button>
                                <form action="${pageContext.request.contextPath}/admin/settings" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${s.id}">
                                    <input type="hidden" name="newStatus" value="${s.status == 'Active' ? 'Inactive' : 'Active'}">
                                    <button type="submit" class="btn btn-sm ${s.status == 'Active' ? 'btn-outline-danger' : 'btn-outline-success'}">
                                        ${s.status == 'Active' ? 'Ẩn' : 'Hiện'}
                                    </button>
                                </form>
                            </td>
                        </tr>

                        <!-- Modal Cập nhật Setting -->
                        <div class="modal fade" id="editSettingModal_${s.id}" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form action="${pageContext.request.contextPath}/admin/settings" method="post">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="id" value="${s.id}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Cập nhật Setting #${s.id}</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-3">
                                                <label class="form-label">Loại (Type)</label>
                                                <select class="form-select" name="type" required>
                                                    <option value="PostCategory" ${s.type == 'PostCategory' ? 'selected' : ''}>PostCategory</option>
                                                    <option value="ServiceCategory" ${s.type == 'ServiceCategory' ? 'selected' : ''}>ServiceCategory</option>
                                                    <option value="UserRole" ${s.type == 'UserRole' ? 'selected' : ''}>UserRole</option>
                                                    <option value="AdminMenu" ${s.type == 'AdminMenu' ? 'selected' : ''}>AdminMenu</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Tên hiển thị (Name) <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="name" value="${s.name}" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Giá trị (Value) <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="value" value="${s.value}" 
                                                       ${s.type == 'UserRole' ? 'readonly disabled' : ''} required>
                                                <c:if test="${s.type == 'UserRole'}">
                                                    <span class="form-text small text-muted">Role mặc định của hệ thống không được sửa Value.</span>
                                                </c:if>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Mô tả</label>
                                                <textarea class="form-control" name="description" rows="2">${s.description}</textarea>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Trạng thái</label>
                                                <select class="form-select" name="status">
                                                    <option value="Active" ${s.status == 'Active' ? 'selected' : ''}>Active</option>
                                                    <option value="Inactive" ${s.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
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
                    <c:if test="${empty settings}">
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy cấu hình nào.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white d-flex justify-content-between align-items-center">
                <span class="small text-muted">Trang ${currentPage} / ${totalPages}</span>
                <ul class="pagination pagination-sm mb-0">
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin/settings?page=${p}&keyword=${keyword}&type=${selectedType}&status=${selectedStatus}">
                                ${p}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>
    </div>
</main>

<!-- Modal Thêm Setting Mới -->
<div class="modal fade" id="addSettingModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/settings" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Thêm Cấu Hình Mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Loại (Type) <span class="text-danger">*</span></label>
                        <select class="form-select" name="type" required>
                            <option value="PostCategory">PostCategory (Danh mục bài viết)</option>
                            <option value="ServiceCategory">ServiceCategory (Danh mục dịch vụ)</option>
                            <option value="UserRole">UserRole (Vai trò người dùng)</option>
                            <option value="AdminMenu">AdminMenu (Menu quản trị)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Tên hiển thị (Name) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="name" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Giá trị (Value) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="value" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" name="description" rows="2"></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Trạng thái</label>
                        <select class="form-select" name="status">
                            <option value="Active">Active</option>
                            <option value="Inactive">Inactive</option>
                        </select>
                    </div>
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

