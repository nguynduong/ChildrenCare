<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ khám bệnh & Đơn thuốc | Staff ChildrenCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold text-primary mb-1">Hồ Sơ Khám Bệnh & Đơn Thuốc Điện Tử</h2>
            <span class="text-muted small">Mã đặt lịch: #${reservation.id} • Bệnh nhi: <strong>${reservation.receiverFullName}</strong></span>
        </div>
        <a href="${pageContext.request.contextPath}/staff/reservation-detail?id=${reservation.id}" class="btn btn-outline-secondary">
            ← Quay lại chi tiết lịch
        </a>
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

    <c:choose>
        <%-- 1. Nếu đã có hồ sơ khám bệnh -> Hiển thị kết quả & Đơn thuốc (Read-only) --%>
        <c:when test="${not empty exam}">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white mb-4">
                <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                    <h5 class="fw-bold text-success mb-0">✅ Buổi Khám Đã Hoàn Tất</h5>
                    <span class="text-muted small">
                        Ngày khám: <fmt:formatDate value="${exam.examinationDate}" pattern="dd/MM/yyyy HH:mm"/> • Bác sĩ: <strong>${exam.doctorName}</strong>
                    </span>
                </div>
                <div class="mb-3">
                    <label class="small text-muted d-block">Ghi chú chẩn đoán tổng quan:</label>
                    <div class="p-3 bg-light rounded">${exam.notes}</div>
                </div>

                <c:if test="${not empty exam.prescription}">
                    <h5 class="fw-bold text-primary mt-4 mb-3">💊 Đơn Thuốc Được Kê</h5>
                    <p class="mb-2"><strong>Chẩn đoán chi tiết:</strong> ${exam.prescription.diagnosis}</p>
                    <p class="text-muted small mb-3"><strong>Lời dặn:</strong> ${exam.prescription.note}</p>

                    <div class="table-responsive">
                        <table class="table table-bordered align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>#</th>
                                    <th>Tên Thuốc</th>
                                    <th>Liều Dùng</th>
                                    <th>Số Lượng</th>
                                    <th>Cách Dùng / Hướng Dẫn</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${exam.prescription.items}" varStatus="loop">
                                    <tr>
                                        <td>${loop.index + 1}</td>
                                        <td class="fw-bold">${item.medicineName}</td>
                                        <td>${item.dosage}</td>
                                        <td>${item.quantity}</td>
                                        <td>${item.usage}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </div>
        </c:when>

        <%-- 2. Nếu chưa khám và là Bác Sĩ (Role 2) -> Cho phép ghi kết quả và kê đơn --%>
        <c:when test="${sessionScope.currentUser.roleId == 2 or sessionScope.currentUser.roleId >= 4}">
            <div class="card shadow-sm border-0 rounded-3 p-4 bg-white">
                <h4 class="fw-bold text-primary mb-3">🩺 Ghi Nhận Kết Quả & Kê Đơn Thuốc</h4>
                <form action="${pageContext.request.contextPath}/staff/medical-examination" method="post">
                    <input type="hidden" name="reservationId" value="${reservation.id}">

                    <div class="mb-3">
                        <label class="form-label fw-bold">Ghi chú lâm sàng / Tình trạng khám <span class="text-danger">*</span></label>
                        <textarea class="form-control" name="examNotes" rows="3" placeholder="Triệu chứng, nhiệt độ, kết quả nghe tim phổi..." required></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Chẩn đoán bệnh (Diagnosis) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="diagnosis" placeholder="Ví dụ: Viêm họng cấp, sốt mọc răng..." required>
                    </div>

                    <div class="mb-4">
                        <label class="form-label">Lời dặn bác sĩ</label>
                        <textarea class="form-control" name="presNote" rows="2" placeholder="Tái khám sau 3 ngày, uống nhiều nước ấm..."></textarea>
                    </div>

                    <h5 class="fw-bold text-secondary mb-3">💊 Danh Mục Thuốc Kê Đơn</h5>
                    <div id="medicineList">
                        <div class="row g-2 mb-2 medicine-row">
                            <div class="col-md-4">
                                <input type="text" class="form-control" name="medicineName" placeholder="Tên thuốc (VD: Hapacol 150mg)" required>
                            </div>
                            <div class="col-md-3">
                                <input type="text" class="form-control" name="dosage" placeholder="Liều dùng (VD: 1 gói/lần)" required>
                            </div>
                            <div class="col-md-2">
                                <input type="number" class="form-control" name="quantity" value="10" min="1" required>
                            </div>
                            <div class="col-md-3">
                                <input type="text" class="form-control" name="usage" placeholder="Cách dùng (Sáng 1 gói sau ăn)">
                            </div>
                        </div>
                    </div>

                    <button type="button" class="btn btn-outline-secondary btn-sm mb-4" onclick="addMedicineRow()">
                        ➕ Thêm dòng thuốc
                    </button>

                    <div class="d-flex justify-content-end">
                        <button type="submit" class="btn btn-success px-5 py-2 fw-bold">
                            Hoàn Tất Buổi Khám & Lưu Đơn Thuốc
                        </button>
                    </div>
                </form>
            </div>
        </c:when>

        <%-- 3. Trường hợp Y tá (Role 3) xem khi chưa khám --%>
        <c:otherwise>
            <div class="card shadow-sm border-0 rounded-3 p-5 text-center bg-white">
                <h5 class="text-muted">Chưa có kết quả khám bệnh từ Bác sĩ phụ trách.</h5>
                <p class="small text-muted mb-0">Y tá chỉ có quyền tra cứu đơn thuốc sau khi Bác sĩ đã hoàn tất buổi khám.</p>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<script>
function addMedicineRow() {
    const container = document.getElementById('medicineList');
    const row = document.createElement('div');
    row.className = 'row g-2 mb-2 medicine-row';
    row.innerHTML = `
        <div class="col-md-4">
            <input type="text" class="form-control" name="medicineName" placeholder="Tên thuốc" required>
        </div>
        <div class="col-md-3">
            <input type="text" class="form-control" name="dosage" placeholder="Liều dùng" required>
        </div>
        <div class="col-md-2">
            <input type="number" class="form-control" name="quantity" value="1" min="1" required>
        </div>
        <div class="col-md-3">
            <input type="text" class="form-control" name="usage" placeholder="Cách dùng">
        </div>
    `;
    container.appendChild(row);
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>

