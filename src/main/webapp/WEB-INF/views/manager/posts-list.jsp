<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý bài viết (Posts) | Manager ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Quản Lý Bài Viết (Posts)</h2>
            <p class="text-muted small mb-0">Tổng cộng: ${totalPosts} bài viết</p>
        </div>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addPostModal">
            ➕ Viết Bài Mới
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
            <form action="${pageContext.request.contextPath}/manager/posts" method="get" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label small text-muted">Tiêu đề bài viết</label>
                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tìm theo tiêu đề...">
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted">Danh mục</label>
                    <select class="form-select" name="categoryId">
                        <option value="">-- Tất cả danh mục --</option>
                        <c:forEach var="c" items="${categories}">
                            <option value="${c.id}" ${selectedCategoryId == c.id ? 'selected' : ''}>${c.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted">Trạng thái</label>
                    <select class="form-select" name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="Published" ${selectedStatus == 'Published' ? 'selected' : ''}>Published (Hiện)</option>
                        <option value="Hidden" ${selectedStatus == 'Hidden' ? 'selected' : ''}>Hidden (Ẩn)</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-outline-primary w-100">🔍 Lọc</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bảng danh sách bài viết -->
    <div class="card shadow-sm border-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Hình ảnh</th>
                        <th>Tiêu đề</th>
                        <th>Danh mục</th>
                        <th>Tác giả</th>
                        <th>Nổi bật</th>
                        <th>Trạng thái</th>
                        <th class="text-end">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${posts}">
                        <tr>
                            <td>#${p.id}</td>
                            <td>
                                <img src="${p.thumbnail}" alt="Thumb" class="rounded" width="50" height="35" style="object-fit:cover;">
                            </td>
                            <td class="fw-semibold" style="max-width: 250px;">
                                <div class="text-truncate">${p.title}</div>
                            </td>
                            <td><span class="badge bg-secondary">${p.categoryName}</span></td>
                            <td>${p.authorName}</td>
                            <td>
                                <c:if test="${p.featured}">
                                    <span class="badge bg-warning text-dark">🔥 Hot</span>
                                </c:if>
                            </td>
                            <td>
                                <span class="badge ${p.status == 'Published' ? 'bg-success' : 'bg-danger'}">
                                    ${p.status}
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="${pageContext.request.contextPath}/blog-detail?id=${p.id}" target="_blank" class="btn btn-sm btn-outline-secondary me-1">👁️</a>
                                <button type="button" class="btn btn-sm btn-outline-primary me-1" 
                                        data-bs-toggle="modal" data-bs-target="#editPostModal_${p.id}">
                                    ✏️
                                </button>
                                <form action="${pageContext.request.contextPath}/manager/posts" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${p.id}">
                                    <input type="hidden" name="newStatus" value="${p.status == 'Published' ? 'Hidden' : 'Published'}">
                                    <button type="submit" class="btn btn-sm ${p.status == 'Published' ? 'btn-outline-danger' : 'btn-outline-success'}">
                                        ${p.status == 'Published' ? 'Ẩn' : 'Hiện'}
                                    </button>
                                </form>
                            </td>
                        </tr>

                        <!-- Modal Cập nhật Post -->
                        <div class="modal fade" id="editPostModal_${p.id}" tabindex="-1">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <form action="${pageContext.request.contextPath}/manager/posts" method="post">
                                        <input type="hidden" name="action" value="update">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Sửa Bài Viết #${p.id}</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-3">
                                                <label class="form-label">Tiêu đề bài viết <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" name="title" value="${p.title}" required>
                                            </div>
                                            <div class="row mb-3">
                                                <div class="col-md-6">
                                                    <label class="form-label">Danh mục <span class="text-danger">*</span></label>
                                                    <select class="form-select" name="categoryId" required>
                                                        <c:forEach var="c" items="${categories}">
                                                            <option value="${c.id}" ${p.categoryId == c.id ? 'selected' : ''}>${c.name}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label">Trạng thái</label>
                                                    <select class="form-select" name="status">
                                                        <option value="Published" ${p.status == 'Published' ? 'selected' : ''}>Published</option>
                                                        <option value="Hidden" ${p.status == 'Hidden' ? 'selected' : ''}>Hidden</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">URL Ảnh Thumbnail</label>
                                                <input type="text" class="form-control" name="thumbnail" value="${p.thumbnail}">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Mô tả tóm tắt (Brief Info) <span class="text-danger">*</span></label>
                                                <textarea class="form-control" name="briefInfo" rows="2" required>${p.briefInfo}</textarea>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label">Nội dung chi tiết (HTML) <span class="text-danger">*</span></label>
                                                <textarea class="form-control" name="description" rows="5" required>${p.description}</textarea>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="isFeatured" id="feat_${p.id}" ${p.featured ? 'checked' : ''}>
                                                <label class="form-check-label" for="feat_${p.id}">
                                                    Đặt làm bài viết nổi bật (Hot Post ở trang chủ)
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
                    <c:if test="${empty posts}">
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">Không tìm thấy bài viết nào.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <c:if test="${totalPages > 1}">
            <div class="card-footer bg-white d-flex justify-content-between align-items-center">
                <span class="small text-muted">Trang ${currentPage} / ${totalPages}</span>
                <ul class="pagination pagination-sm mb-0">
                    <c:forEach begin="1" end="${totalPages}" var="pageIndex">
                        <li class="page-item ${pageIndex == currentPage ? 'active' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/manager/posts?page=${pageIndex}&categoryId=${selectedCategoryId}&status=${selectedStatus}&keyword=${keyword}">
                                ${pageIndex}
                            </a>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </c:if>
    </div>
</main>

<!-- Modal Thêm Post Mới -->
<div class="modal fade" id="addPostModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/manager/posts" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Viết Bài Mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Tiêu đề bài viết <span class="text-danger">*</span></label>
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
                                <option value="Published">Published (Công khai)</option>
                                <option value="Hidden">Hidden (Ẩn)</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">URL Ảnh Thumbnail</label>
                        <input type="text" class="form-control" name="thumbnail" placeholder="https://example.com/image.jpg">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mô tả tóm tắt (Brief Info) <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="briefInfo" rows="2" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Nội dung chi tiết (HTML) <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="description" rows="5" placeholder="<p>Nội dung bài viết...</p>" required></textarea>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="isFeatured" id="add_feat">
                        <label class="form-check-label" for="add_feat">
                            Đặt làm bài viết nổi bật (Hot Post ở trang chủ)
                        </label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-primary">Lưu Bài Viết</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

