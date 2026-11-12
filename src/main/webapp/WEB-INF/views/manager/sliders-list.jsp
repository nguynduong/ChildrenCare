<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Sliders | Manager ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Quản Lý Sliders Banner</h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalSliders} sliders</p>
        </div>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addSliderModal">
            ➕ Thêm Slider Mới
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
            <form action="${pageContext.request.contextPath}/manager/sliders" method="get" class="row g-3">
                <div class="col-md-6">
                    <label class="form-label small text-muted">Từ khóa (Tiêu đề hoặc Backlink)</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tìm theo tiêu đề hoặc liên kết...">
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

    <!-- Bảng danh sách slider -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Hình ảnh</th>
                        <th>Tiêu đề</th>
                        <th>Liên kết (BackLink)</th>
                        <th>Ghi chú</th>
                        <th>Trạng thái</th>
                        <th class="text-end">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${sliders}">
                        <tr>
                            <td>#${s.id}</td>
                            <td>
                                <img src="${s.imageUrl}" alt="Banner" class="rounded" width="80" height="40" style="object-fit:cover;">
                            </td>
                            <td class="fw-semibold">${s.title}</td>
                            <td><a href="${s.backLink}" target="_blank" class="small text-truncate d-inline-block" style="max-width:200px;">${s.backLink}</a></td>
                            <td class="text-muted small">${s.notes}</td>
                            <td>
                                <span class="badge ${s.status == 'Active' ? 'bg-success' : 'bg-danger'}">
                                    ${s.status}
                                </span>
                            </td>
                            <td class="text-end">
                                <button type="button" class="btn btn-sm btn-outline-primary me-1" 
                                        data-bs-toggle="modal" data-bs-target="#editSliderModal_${s.id}">
                                    ✏️
                                </button>
                                <form action="${pageContext.request.contextPath}/manager/sliders" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${s.id}">
                                    <input type="hidden" name="newStatus" value="${s.status == 'Active' ? 'Inactive' : 'Active'}">
                                    <button type="submit" class="btn btn-sm ${s.status == 'Active' ? 'btn-outline-danger' : 'btn-outline-success'}">
                                        ${s.status == 'Active' ? 'Ẩn' : 'Hiện'}
                                    </button>
                                </form>
                            </td>
                        </tr>

                        <!-- Modal Cập nhật Slider -->
                        <div class="modal fade" id="editSliderModal_${s.id}" tabindex="-1">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form action="${pageContext.request.contextPath}/manager/sliders" method="post">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="id" value="${s.id}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Sửa Slider #${s.id}</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-3">
                                                <label class="form-label">Tiêu đề slider <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="title" value="${s.title}" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">URL Hình ảnh banner <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="imageUrl" value="${s.imageUrl}" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Liên kết chuyển tiếp (Backlink) <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="backLink" value="${s.backLink}" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Trạng thái</label>
                                                <select class="form-select" name="status">
                                                    <option value="Active" ${s.status == 'Active' ? 'selected' : ''}>Active (Hiển thị)</option>
                                                    <option value="Inactive" ${s.status == 'Inactive' ? 'selected' : ''}>Inactive (Ẩn)</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Ghi chú</label>
                                                <textarea class="form-control" name="notes" rows="2">${s.notes}</textarea>
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
                    <c:if test="${empty sliders}">
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted">Không tìm thấy slider nào.</td>
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
                            <a class="page-link" href="${pageContext.request.contextPath}/manager/sliders?page=${p}&status=${selectedStatus}&keyword=${keyword}">
                                ${p}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>
    </div>
</main>

<!-- Modal Thêm Slider Mới -->
<div class="modal fade" id="addSliderModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/manager/sliders" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Thêm Slider Mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Tiêu đề slider <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">URL Hình ảnh banner <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="imageUrl" placeholder="https://example.com/banner.jpg" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Liên kết chuyển tiếp (Backlink) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="backLink" placeholder="/services hoặc https://..." required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Trạng thái</label>
                        <select class="form-select" name="status">
                            <option value="Active">Active (Hiển thị)</option>
                            <option value="Inactive">Inactive (Ẩn)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Ghi chú</label>
                        <textarea class="form-control" name="notes" rows="2"></textarea>
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

