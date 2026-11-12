<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý dịch vụ (Services) | ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Quản Lý Gói Dịch Vụ Y Tế</h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalServices} dịch vụ</p>
        </div>
        <c:if test="${sessionScope.currentUser.roleId == 4 or sessionScope.currentUser.roleId == 5}">
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                ➕ Thêm Gói Dịch Vụ Mới
            </button>
        </c:if>
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
            <form action="${pageContext.request.contextPath}/manager/services" method="get" class="row g-3">
                <div class="col-md-6">
                    <label class="form-label small text-muted">Từ khóa</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tìm theo tên dịch vụ, mô tả...">
                </div>
                <div class="col-md-4">
                    <label class="form-label small text-muted">Trạng thái</label>
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="Active" ${selectedStatus == 'Active' ? 'selected' : ''}>Active (Hiện)</option>
                        <option value="Inactive" ${selectedStatus == 'Inactive' ? 'selected' : ''}>Inactive (Ẩn)</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-outline-primary w-100">🔍 Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng danh sách dịch vụ -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Ảnh</th>
                        <th>Tên dịch vụ</th>
                        <th>Danh mục</th>
                        <th>Giá niêm yết</th>
                        <th>Giá bán (Sale)</th>
                        <th>Khả dụng</th>
                        <th>Nổi bật</th>
                        <th>Trạng thái</th>
                        <th class="text-end">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${services}">
                        <tr>
                            <td>#${s.id}</td>
                            <td>
                                <img src="${s.thumbnail}" alt="Thumb" class="rounded" width="50" height="40" style="object-fit:cover;">
                            </td>
                            <td class="fw-semibold" style="max-width:200px;">
                                <div class="text-truncate">${s.title}</div>
                            </td>
                            <td><span class="badge bg-secondary">${s.categoryName}</span></td>
                            <td><fmt:formatNumber value="${s.listPrice}" type="currency" currencySymbol="₫"/></td>
                            <td class="fw-bold text-danger"><fmt:formatNumber value="${s.salePrice}" type="currency" currencySymbol="₫"/></td>
                            <td>${s.availableQuantity}</td>
                            <td>
                                <c:if test="${s.featured}">
                                    <span class="badge bg-warning text-dark">🔥 Hot</span>
                                </c:if>
                            </td>
                            <td>
                                <span class="badge ${s.status == 'Active' ? 'bg-success' : 'bg-danger'}">
                                    ${s.status}
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="${pageContext.request.contextPath}/service-detail?id=${s.id}" target="_blank" class="btn btn-sm btn-outline-secondary me-1">👁️</a>
                                
                                <c:if test="${sessionScope.currentUser.roleId == 4 or sessionScope.currentUser.roleId == 5}">
                                    <button type="button" class="btn btn-sm btn-outline-primary me-1" 
                                            data-bs-toggle="modal" data-bs-target="#editServiceModal_${s.id}">
                                        ✏️
                                    </button>
                                    <form action="${pageContext.request.contextPath}/manager/services" method="post" class="d-inline">
                                        <input type="hidden" name="action" value="toggle">
                                        <input type="hidden" name="id" value="${s.id}">
                                        <input type="hidden" name="newStatus" value="${s.status == 'Active' ? 'Inactive' : 'Active'}">
                                        <button type="submit" class="btn btn-sm ${s.status == 'Active' ? 'btn-outline-danger' : 'btn-outline-success'}">
                                            ${s.status == 'Active' ? 'Ẩn' : 'Hiện'}
                                        </button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>

                        <!-- Modal Cập nhật Service -->
                        <div class="modal fade" id="editServiceModal_${s.id}" tabindex="-1">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <form action="${pageContext.request.contextPath}/manager/services" method="post">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="id" value="${s.id}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Sửa Gói Dịch Vụ #${s.id}</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-3">
                                                <label class="form-label">Tên dịch vụ <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="title" value="${s.title}" required>
                                            </div>
                                            <div class="row mb-3">
                                                <div class="col-md-6">
                                                    <label class="form-label">Danh mục <span class="text-danger">*</span></label>
                                                    <select class="form-select" name="categoryId" required>
                                                        <c:forEach var="c" items="${categories}">
                                                            <option value="${c.id}" ${s.categoryId == c.id ? 'selected' : ''}>${c.name}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label">Trạng thái</label>
                                                    <select class="form-select" name="status">
                                                        <option value="Active" ${s.status == 'Active' ? 'selected' : ''}>Active</option>
                                                        <option value="Inactive" ${s.status == 'Inactive' ? 'selected' : ''}>Inactive</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="row mb-3">
                                                <div class="col-md-4">
                                                    <label class="form-label">Giá niêm yết (Gốc) <span class="text-danger">*</span></label>
                                                    <input type="number" class="form-control" name="listPrice" value="${s.listPrice}" required>
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="form-label">Giá khuyến mãi (Sale) <span class="text-danger">*</span></label>
                                                    <input type="number" class="form-control" name="salePrice" value="${s.salePrice}" required>
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="form-label">Số lượng khả dụng <span class="text-danger">*</span></label>
                                                    <input type="number" class="form-control" name="availableQuantity" value="${s.availableQuantity}" required>
                                                </div>
                                            </div>
                                            <div class="row mb-3">
                                                <div class="col-md-6">
                                                    <label class="form-label">Số người mặc định <span class="text-danger">*</span></label>
                                                    <input type="number" class="form-control" name="numberOfPerson" value="${s.numberOfPerson}" required>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label">URL Thumbnail</label>
                                                    <input type="text" class="form-control" name="thumbnail" value="${s.thumbnail}">
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Mô tả ngắn <span class="text-danger">*</span></label>
                                                <textarea class="form-control" name="briefInfo" rows="2" required>${s.briefInfo}</textarea>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Mô tả chi tiết (HTML) <span class="text-danger">*</span></label>
                                                <textarea class="form-control" name="description" rows="5" required>${s.description}</textarea>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="isFeatured" id="feat_srv_${s.id}" ${s.featured ? 'checked' : ''}>
                                                <label class="form-check-label" for="feat_srv_${s.id}">
                                                    Đặt làm dịch vụ nổi bật (Trang chủ)
                                                </label>
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
                    <c:if test="${empty services}">
                        <tr>
                            <td colspan="10" class="text-center py-4 text-muted">Không tìm thấy gói dịch vụ nào.</td>
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
                            <a class="page-link" href="${pageContext.request.contextPath}/manager/services?page=${p}&status=${selectedStatus}&keyword=${keyword}">
                                ${p}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>
    </div>
</main>

<!-- Modal Thêm Service Mới -->
<div class="modal fade" id="addServiceModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/manager/services" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Thêm Gói Dịch Vụ Mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Tên dịch vụ <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title" required>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Danh mục <span class="text-danger">*</span></label>
                            <select class="form-select" name="categoryId" required>
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.id}">${c.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Trạng thái</label>
                            <select class="form-select" name="status">
                                <option value="Active">Active (Công khai)</option>
                                <option value="Inactive">Inactive (Ẩn)</option>
                            </select>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label class="form-label">Giá niêm yết (Gốc) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="listPrice" placeholder="500000" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Giá khuyến mãi (Sale) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="salePrice" placeholder="450000" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Số lượng khả dụng <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="availableQuantity" value="50" required>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Số người mặc định <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" name="numberOfPerson" value="1" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">URL Thumbnail</label>
                            <input type="text" class="form-control" name="thumbnail" placeholder="https://example.com/thumb.jpg">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả ngắn <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="briefInfo" rows="2" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả chi tiết (HTML) <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="description" rows="5" placeholder="<p>Quy trình khám...</p>" required></textarea>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="isFeatured" id="add_feat_srv">
                        <label class="form-check-label" for="add_feat_srv">
                            Đặt làm dịch vụ nổi bật (Trang chủ)
                        </label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu Gói Dịch Vụ</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

