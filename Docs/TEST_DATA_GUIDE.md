# 📋 HƯỚNG DẪN DỮ LIỆU TEST & TÀI KHOẢN ĐĂNG NHẬP (SWP391)

Tất cả các tài khoản thử nghiệm bên dưới đều sử dụng **Mật khẩu chung:** `123456`  
File dữ liệu mẫu: [`sql/data.sql`](file:///d:/WorkSpace/ChildrenCare/sql/data.sql)

---

## 👥 1. Bảng tài khoản đăng nhập theo từng Vai trò (Roles)

| Vai trò (Role) | Họ và tên | Email đăng nhập | Mật khẩu | Quyền hạn & Chức năng chính |
| :--- | :--- | :--- | :--- | :--- |
| **Admin** | Trần Đại Nghĩa | `admin@childrencare.com` | `123456` | Quản trị toàn hệ thống: Quản lý người dùng, cấu hình Settings, xem Dashboard doanh thu/thống kê |
| **Manager** | Nguyễn Thu Trang | `manager@childrencare.com` | `123456` | Quản lý Dịch vụ (CRUD), Quản lý Bài viết & Slider, Quản lý Khách hàng, Duyệt Feedback |
| **Doctor** | BS.CKII Trịnh Văn Minh | `doctor@childrencare.com` | `123456` | Xem lịch khám được giao, thực hiện Khám bệnh, Kê đơn thuốc |
| **Doctor (2)** | ThS.BS Lê Thị Mai | `doctor2@childrencare.com` | `123456` | Bác sĩ chuyên khoa Dinh dưỡng |
| **Nurse** | ĐD. Trần Thảo Vy | `nurse@childrencare.com` | `123456` | Xem danh sách đặt lịch, hỗ trợ điều phối khám |
| **Nurse (2)** | ĐD. Nguyễn Hải Yến | `nurse2@childrencare.com` | `123456` | Điều dưỡng phụ trách phòng tiêm |
| **Customer** | Phạm Hoàng Nam | `customer@childrencare.com` | `123456` | Khách hàng đã có lịch hẹn đã khám (`Success`) và lịch chờ (`Approved`), xem đơn thuốc |
| **Customer (2)** | Đặng Thu Thảo | `khachhang2@gmail.com` | `123456` | Khách hàng có lịch vừa đặt (`Submitted`) và lịch đã hủy (`Cancelled`) |
| **Test Unverified** | Người Dùng Mới | `unverified@childrencare.com` | `123456` | *Dùng test đăng nhập thất bại do chưa kích hoạt email* |
| **Test Inactive** | Người Dùng Bị Khóa | `inactive@childrencare.com` | `123456` | *Dùng test đăng nhập thất bại do tài khoản bị vô hiệu hóa* |

---

## 🧪 2. Kịch bản kiểm thử (Test Scenarios) theo từng luồng

### Kịch bản 1: Luồng Khách hàng (Customer)
1. Đăng nhập với tài khoản `customer@childrencare.com` / `123456`.
2. Truy cập menu **"Lịch hẹn của tôi"** (`/my-reservations`):
   - Thấy lịch hẹn **#1** trạng thái **`Success`** (đã khám xong, kèm chi tiết dịch vụ).
   - Thấy lịch hẹn **#2** trạng thái **`Approved`** (đã được duyệt).
3. Đặt lịch khám mới: Vào trang **Dịch vụ** (`/services`) > Chọn gói tiêm chủng > Thêm vào giỏ > Bấm Đặt lịch > Điền thông tin > Submit thành công.
4. Đánh giá: Vào trang **Góp ý & Đánh giá** (`/feedback`) để gửi đánh giá dịch vụ.

### Kịch bản 2: Luồng Quản lý (Manager)
1. Đăng nhập với `manager@childrencare.com` / `123456`.
2. Quản lý Dịch vụ (`/manager/services`): Thêm mới dịch vụ, sửa giá gốc/giá sale, bật tắt trạng thái Active/Inactive.
3. Quản lý Bài viết (`/manager/posts`): Xem danh sách bài viết, chỉnh sửa nội dung bài viết tin tức.
4. Quản lý Khách hàng (`/manager/customers`): Xem danh sách khách hàng tiềm năng và lịch sử liên hệ.
5. Duyệt Feedback (`/manager/feedbacks`): Duyệt hoặc ẩn các đánh giá của khách hàng.

### Kịch bản 3: Luồng Bác sĩ / Y tá (Staff)
1. Đăng nhập với `doctor@childrencare.com` / `123456`.
2. Vào trang **Lịch khám được phân công** (`/staff/reservations`).
3. Mở hồ sơ khám bệnh cho lịch hẹn (`/staff/examination?reservationId=1`):
   - Xem chẩn đoán: *"Viêm họng cấp thể nhẹ"*.
   - Xem đơn thuốc đã kê: Siro ho Astex, Men vi sinh BioGaia, Nước muối Physiodose.

### Kịch bản 4: Luồng Quản trị viên (Admin)
1. Đăng nhập với `admin@childrencare.com` / `123456`.
2. Xem **Dashboard** tổng quan (`/admin/dashboard`): Doanh thu, số lượng đặt lịch thành công, tỷ lệ tăng trưởng.
3. Quản lý Người dùng (`/admin/users`): Tìm kiếm, lọc theo Role (Doctor, Nurse, Manager, Customer), đổi trạng thái tài khoản.
4. Cấu hình Hệ thống (`/admin/settings`): Quản lý các danh mục (UserRole, PostCategory, ServiceCategory).

---

## 🚀 3. Cách nạp dữ liệu vào SQL Server
1. Mở **SQL Server Management Studio (SSMS)**.
2. Mở file [`sql/data.sql`](file:///d:/WorkSpace/ChildrenCare/sql/data.sql).
3. Nhấn **Execute (F5)** để nạp toàn bộ dữ liệu mẫu vào database `ChildrenCareDB`.

