# BỘ QUY TẮC PHÁT TRIỂN DỰ ÁN CHILDREN CARE SYSTEM (CCS)
> **Phiên bản:** 1.0  
> **Nền tảng:** Java Web (JSP, Servlet thuần, JSTL, JDBC)  
> **Cơ sở dữ liệu:** Microsoft SQL Server / MySQL  
> **Tiêu chuẩn chất lượng:** Mô hình MVC chuẩn & Triết lý Clean Code Ponytail

---

## I. NGUYÊN TẮC CỐT LÕI (CORE PRINCIPLES)

1. **Công nghệ bắt buộc:**
   - Sử dụng **Java Servlet & JSP thuần** (Java EE / Jakarta EE), **KHÔNG** sử dụng C#, ASP.NET Core hay Spring Boot.
   - Thao tác CSDL bằng **JDBC thuần với `PreparedStatement`** (ngăn chặn triệt để SQL Injection), đóng tài nguyên bằng `try-with-resources`.
   - Giao diện: JSP kết hợp JSTL (`c:forEach`, `c:if`, `fmt:...`) và EL (`${...}`). Các trang JSP quản trị và riêng tư phải nằm trong `/WEB-INF/views/` để ngăn chặn truy cập trực tiếp từ trình duyệt.

2. **Kiến trúc chuẩn MVC (Model - View - Controller):**
   - **Model (`com.childrencare.model` / `dao`):**
     - *Entity / Beans:* Các lớp Java POJO ánh xạ bảng CSDL với thuộc tính private, getter/setter, constructor.
     - *DAO (Data Access Object):* Chịu trách nhiệm thực thi các truy vấn SQL (CRUD), ánh xạ `ResultSet` thành Object/List.
   - **Controller (`com.childrencare.controller`):**
     - Các Java Servlet kế thừa `HttpServlet`, ánh xạ qua `@WebServlet("/url")`.
     - Chỉ làm nhiệm vụ điều phối: nhận request, validate tham số đầu vào, gọi DAO/Service xử lý nghiệp vụ, đặt dữ liệu vào `request.setAttribute()`, và điều hướng (`RequestDispatcher.forward()` hoặc `response.sendRedirect()`).
     - **Tuyệt đối không** viết mã HTML trong Servlet hay viết truy vấn SQL trực tiếp trong Controller.
   - **View (`/webapp/WEB-INF/views/` và `/webapp/`):**
     - Chỉ làm nhiệm vụ hiển thị dữ liệu từ Model/Request Attribute.
     - **Tuyệt đối không** viết mã Java scriptlet (`<% ... %>`) trong JSP; sử dụng JSTL và EL.
   - **Filter / Middleware (`com.childrencare.filter`):**
     - `EncodingFilter`: Đảm bảo `UTF-8` cho toàn bộ request/response.
     - `AuthenticationFilter`: Bắt buộc đăng nhập cho các URL yêu cầu xác thực.
     - `AuthorizationFilter`: Kiểm tra Role của người dùng (Customer, Doctor, Nurse, Manager, Admin) ngay tại server-side; chặn truy cập trái phép với HTTP 403.

---

## II. TRIẾT LÝ CLEAN CODE THEO SKILL PONYTAIL (LAZY SENIOR DEV MODE)

> *"The best code is the code never written - Đoạn code tốt nhất là đoạn code không cần phải viết."*

Tất cả thành viên khi code chức năng phải tuân thủ nghiêm ngặt thang 7 bậc lựa chọn giải pháp của **Ponytail**:

1. **YAGNI (You Aren't Gonna Need It):** Tính năng, trường dữ liệu hoặc sự linh hoạt này có thực sự cần thiết theo tài liệu không? Nếu không ai yêu cầu, tuyệt đối **không viết**.
2. **Tái sử dụng (Reuse):** Luôn tìm kiếm và tái sử dụng các hàm tiện ích (`DBContext`, hàm phân trang, hàm hash password, format tiền tệ) đã có sẵn trong codebase trước khi viết mới.
3. **Thư viện chuẩn (Standard Library):** Tận dụng tối đa các thư viện có sẵn của Java SE/EE (JDBC, Collection API, Java Time API, JSTL) thay vì tự chế lại bánh xe hoặc cài thêm thư viện bên ngoài không cần thiết.
4. **Một dòng code rõ ràng:** Nếu có thể giải quyết logic bằng 1 dòng code dễ đọc, dễ hiểu, hãy viết 1 dòng.
5. **Tối giản thiết kế (No Over-engineering):**
   - Không tạo các tầng trừu tượng (Abstract Factory, Generic Base Service, Repository Pattern phức tạp) khi không có yêu cầu.
   - Giữ nguyên cấu trúc phân tầng đơn giản: `JSP <-> Servlet <-> DAO <-> Database`.
   - Giữ dữ liệu ở định dạng nguyên bản mà nền tảng cung cấp.
6. **Ranh giới an toàn tuyệt đối (Không bao giờ được cắt bớt để "lười"):**
   - **Validate ở Server-side:** Bắt buộc kiểm tra định dạng và độ dài dữ liệu đầu vào (Họ tên, SĐT 10 số, Email, giá tiền, khoảng ngày) ở Servlet trước khi gọi DAO.
   - **Bảo mật:** Dùng `PreparedStatement` cho 100% câu truy vấn SQL; mã hóa mật khẩu trước khi lưu DB; sanitize nội dung HTML chống XSS.
   - **Xóa mềm (Soft Delete):** Không xóa cứng dữ liệu nghiệp vụ quan trọng; "Delete" được hiểu là cập nhật `Status = Inactive` hoặc `Hidden`.
7. **Quy ước Shortcut:** Khi phải dùng giải pháp tạm thời hoặc giới hạn kỹ thuật, bắt buộc ghi chú theo cú pháp:
   ```java
   // shortcut: <giới hạn hiện tại>, <khi nào cần nâng cấp>
   ```

---

## III. PHÂN CÔNG 5 PHẦN THEO ĐẶC TẢ CRUD VÀ REQUIREMENTS (5 THÀNH VIÊN)

Dựa trên tài liệu đặc tả `ChildrenCare_Dac_ta_CRUD.md` và danh sách 35 chức năng trong `ChildrenCare_Functions.xlsx`:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        THỨ TỰ TRIỂN KHAI GỢI Ý                         │
│                                                                        │
│   [Phần 1: Nền tảng & Admin] (Làm trước: DBContext, User, Setting)     │
│             │                                                          │
│             ├───────────────┬───────────────┐                          │
│             ▼               ▼               ▼                          │
│     [Phần 2: Nội dung]  [Phần 3: Dịch vụ]   │                          │
│     (Post, Slider)      (Service)           │                          │
│                             │               │                          │
│                             ▼               │                          │
│                     [Phần 4: Đặt lịch]      │                          │
│                     (Reservation, Cart)     │                          │
│                             │               │                          │
│                             ▼               ▼                          │
│                     [Phần 5: Khách hàng, Phản hồi, Khám bệnh, Dashboard]│
└────────────────────────────────────────────────────────────────────────┘
```

---

### PHẦN 1. NỀN TẢNG VÀ QUẢN TRỊ HỆ THỐNG
- **Người phụ trách:** Thành viên 1
- **Phụ thuộc:** Không (Thực hiện đầu tiên để cung cấp nền móng cho cả nhóm).
- **Thực thể Model chính:** `User`, `Setting` (Role, Category, AdminMenu).
- **Các màn hình phụ trách (10 màn hình):**
  1. `[10] User Login`: Đăng nhập hệ thống (Email + Password), thông báo lỗi bảo mật chung, lưu session, điều hướng theo Role.
  2. `[11] User Register`: Đăng ký tài khoản (Họ tên, giới tính, email, sđt, địa chỉ), trạng thái ban đầu `Unverified`, tạo token và gửi email xác thực.
  3. `[12] Reset Password`: Quên mật khẩu, gửi email kèm reset token có thời hạn, trang đổi mật khẩu mới.
  4. `[13] Change Password`: Đổi mật khẩu cho người dùng đang đăng nhập (kiểm tra mật khẩu cũ).
  5. `[14] User Profile`: Xem và chỉnh sửa thông tin cá nhân, cập nhật avatar (không cho sửa email).
  6. `[15] User Authorization`: Bộ lọc phân quyền (Filter RBAC), điều hướng menu động theo Role (Setting `AdminMenu`), chặn URL trái phép (403).
  7. `[32] Users List` (Admin): Quản lý danh sách người dùng, phân trang, lọc theo Gender/Role/Status, tìm kiếm theo tên/email/phone.
  8. `[33] User Details` (Admin): Xem chi tiết người dùng, thêm mới nhân viên (sinh mật khẩu ngẫu nhiên gửi mail), cập nhật Role và Status.
  9. `[34] Settings List` (Admin): Quản lý danh mục và cấu hình hệ thống, phân trang, lọc theo Type/Status, tìm theo Name/Value.
  10. `[35] Setting Details` (Admin): Thêm mới, xem chi tiết, sửa cấu hình (không sửa Value của Role mặc định), xóa mềm (`Status = Inactive`).
- **Nhiệm vụ kỹ thuật bổ sung:**
  - Viết lớp kết nối CSDL chung `DBContext.java` cho cả nhóm.
  - Viết `SecurityUtils.java` (băm mật khẩu SHA-256/BCrypt, sinh token).
  - Viết bộ lọc `EncodingFilter` và `AuthFilter`.
  - Khởi tạo dữ liệu mẫu (Seed Data) cho 5 Role mặc định và các Setting danh mục.

---

### PHẦN 2. NỘI DUNG VÀ TRANG CHỦ
- **Người phụ trách:** Thành viên 2
- **Phụ thuộc:** Phần 1 (Cần bảng `User` và `Setting` loại `PostCategory`).
- **Thực thể Model chính:** `Post`, `Slider`.
- **Các màn hình phụ trách (7 màn hình):**
  1. `[1] Home Page` (Public): Trang chủ hiển thị Slider đang hoạt động, danh sách bài viết nổi bật (Hot Posts), dịch vụ nổi bật (Featured Services), sidebar bài viết mới nhất và liên hệ.
  2. `[2] Blogs List` (Public): Danh sách bài viết công khai, chỉ hiện bài `Published`, sắp xếp theo `UpdatedDate` giảm dần, phân trang, tìm kiếm từ khóa, lọc theo danh mục bài viết.
  3. `[3] Blog Details` (Public): Chi tiết bài viết (tiêu đề, tác giả, ngày cập nhật, danh mục, nội dung chi tiết HTML đã sanitize), sidebar bài viết liên quan.
  4. `[18] Posts List` (Manager): Quản lý danh sách bài viết, phân trang, lọc theo Category/Author/Status, tìm theo Title, các nút chuyển đổi hiển thị/ẩn (Show/Hide), xem, sửa, tạo mới.
  5. `[19] Post Details` (Manager): Xem, thêm mới hoặc chỉnh sửa bài viết (Thumbnail, Title, Category, BriefInfo, Description HTML, cờ `IsFeatured`, `Status`). Tác giả tự gán theo tài khoản đăng nhập.
  6. `[20] Sliders List` (Manager): Quản lý danh sách ảnh trượt trang chủ, phân trang, lọc Status, tìm theo Title/BackLink, bật/tắt hiển thị.
  7. `[21] Slider Details` (Manager): Thêm mới, xem và cập nhật thông tin slider (Ảnh, Tiêu đề, BackLink, Ghi chú, Status).

---

### PHẦN 3. DỊCH VỤ CHĂM SÓC TRẺ EM
- **Người phụ trách:** Thành viên 3
- **Phụ thuộc:** Phần 1 (Cần bảng `Setting` loại `ServiceCategory`).
- **Thực thể Model chính:** `Service`, `ServiceImage`.
- **Các màn hình phụ trách (4 màn hình):**
  1. `[4] Services List` (Public): Danh sách dịch vụ khám/chăm sóc, chỉ hiện dịch vụ `Active`, sắp xếp theo ngày cập nhật, phân trang, tìm kiếm, lọc theo Category. Hiển thị thumbnail, tên, mô tả ngắn, giá gốc, giá khuyến mãi; nút "Buy" (đưa vào giỏ) và nút "Feedback".
  2. `[5] Service Details` (Public): Chi tiết dịch vụ gồm tiêu đề, danh mục, bộ sưu tập ảnh đính kèm (`ServiceImage`), giá niêm yết, giá bán, nội dung chi tiết HTML; nút đặt lịch/mua và đánh giá.
  3. `[22] Services List` (Manager & Staff): Quản lý danh sách gói dịch vụ, phân trang, lọc Status, tìm kiếm, sắp xếp theo giá/tên/danh mục, các nút Show/Hide/Edit/Add. Nhân viên y tế (Doctor/Nurse) chỉ có quyền xem (Read-only).
  4. `[23] Service Details` (Manager): Màn hình tạo mới, xem hoặc cập nhật gói dịch vụ (Tiêu đề, danh mục, giá niêm yết, giá bán `<= ListPrice`, số người mặc định, số lượng khả dụng `AvailableQuantity`, cờ `IsFeatured`, `Status`). Quản lý thêm/xóa/đổi thứ tự các ảnh đính kèm `ServiceImage`.

---

### PHẦN 4. ĐẶT LỊCH KHÁM VÀ GIỎ DỊCH VỤ (RESERVATION)
- **Người phụ trách:** Thành viên 4
- **Phụ thuộc:** Phần 1 và Phần 3 (Cần `User` và `Service`).
- **Thực thể Model chính:** `Reservation`, `ReservationItem`.
- **Các màn hình phụ trách (7 màn hình):**
  1. `[6] Reservation Details` (Giỏ đặt lịch): Quản lý danh sách dịch vụ đã chọn (Id, tên, giá, số lượng `Quantity`, số người `NumberOfPerson`, tổng tiền). Cho phép thay đổi số lượng, số người, xóa dòng, tự động cập nhật tổng tiền; giữ giỏ qua session/cookie (khách) hoặc DB (đã đăng nhập). Cập nhật giá theo giá mới nhất của hệ thống.
  2. `[7] Reservation Contact`: Hiển thị lại danh sách dịch vụ và form thông tin người nhận (Họ tên, giới tính, email, sđt, địa chỉ, ghi chú, thời gian khám `CheckupTime`). Tự động điền thông tin nếu đã đăng nhập.
  3. `[8] Reservation Completion`: Xử lý hoàn tất đặt lịch:
     - Chuyển `Status` sang `Submitted`.
     - Giảm trừ `AvailableQuantity` của từng dịch vụ tương ứng.
     - Tự động gán nhân viên y tế (Doctor/Nurse) theo vòng xoay hoặc theo khách chọn.
     - Gửi email xác nhận kèm thông tin hướng dẫn thanh toán.
     - Đồng bộ thông tin người nhận sang bảng `Contact` (Phần 5).
  4. `[16] My Reservations` (Customer): Danh sách lịch hẹn của khách hàng đăng nhập, phân trang, hiển thị mã đặt, ngày đặt, dịch vụ, giờ khám, tổng tiền, trạng thái.
  5. `[17] Reservation Information` (Customer): Chi tiết lịch hẹn; cho phép chỉnh sửa dịch vụ hoặc hủy lịch (`Status = Cancelled`) và hoàn trả `AvailableQuantity` khi lịch còn ở trạng thái `Submitted`.
  6. `[28] Reservations List` (Staff & Manager): Quản lý danh sách đặt lịch, phân trang, lọc theo khoảng ngày, trạng thái, nhân viên phụ trách; tìm theo mã hoặc tên khách. Bác sĩ/Y tá chỉ thấy lịch được phân công cho mình; Manager thấy toàn bộ.
  7. `[29] Reservation Details` (Staff & Manager): Chi tiết đơn đặt lịch và danh sách dịch vụ. Manager có quyền đổi trạng thái và gán/chuyển giao cho nhân viên khác.

---

### PHẦN 5. KHÁCH HÀNG, PHẢN HỒI, KHÁM BỆNH VÀ BÁO CÁO
- **Người phụ trách:** Thành viên 5
- **Phụ thuộc:** Phần 1, Phần 3, Phần 4 (Cần `User`, `Service`, `Reservation`).
- **Thực thể Model chính:** `Contact`, `ContactHistory`, `Feedback`, `FeedbackImage`, `MedicalExamination`, `Prescription`, `PrescriptionItem`.
- **Các màn hình phụ trách (7 màn hình):**
  1. `[9] Feedback` (Public): Form gửi đánh giá chung hoặc đánh giá cho một dịch vụ cụ thể (Họ tên, email, sđt, số sao 1-5, nội dung phản hồi, tối đa 5 ảnh đính kèm `FeedbackImage`). Tự động cập nhật vào `Contact`.
  2. `[24] Customers List` (Manager & Staff): Danh sách liên hệ/khách hàng marketing, lọc theo trạng thái (`Contact`, `Potential`, `Customer`), tìm theo họ tên, email, phone. Staff chỉ được xem.
  3. `[25] Customer Details` (Manager & Staff): Xem chi tiết thông tin khách hàng, cho phép Manager chỉnh sửa thông tin. Hiển thị bảng lịch sử thay đổi `ContactHistory` (Ai sửa, sửa lúc nào, giá trị cũ).
  4. `[26] Feedbacks List` (Manager & Staff): Quản lý phản hồi khách hàng, phân trang, lọc theo sao, dịch vụ, trạng thái; tìm theo tên hoặc nội dung.
  5. `[27] Feedback Details` (Manager): Xem đầy đủ nội dung phản hồi và ảnh đính kèm; cho phép duyệt ẩn/hiện (`Status = Published / Hidden`).
  6. `[30] Medical Examination` (Staff): Quản lý hồ sơ khám bệnh:
     - Hiển thị lịch sử khám theo lịch hẹn được phân công.
     - **Bác sĩ (Doctor):** Ghi chép chẩn đoán bệnh (`MedicalExamination`), tạo đơn thuốc (`Prescription`) và thêm các dòng thuốc chi tiết (`PrescriptionItem`: tên thuốc, liều lượng, số lượng, hướng dẫn sử dụng).
     - **Y tá (Nurse):** Chỉ có quyền tra cứu, xem lịch sử và đơn thuốc (không được kê đơn).
  7. `[31] Admin Dashboard & Reservation Dashboard`:
     - Thống kê tổng số đặt lịch mới theo trạng thái (Success, Cancelled, Submitted).
     - Thống kê doanh thu (tổng và theo danh mục dịch vụ).
     - Thống kê khách hàng mới và đánh giá trung bình.
     - Biểu đồ xu hướng đặt lịch theo ngày trong 7 ngày gần nhất (cho phép chọn khoảng ngày).

---

## IV. QUY TRÌNH KIỂM THỬ VÀ CHECKLIST NGHIỆM THU

Trước khi bàn giao một chức năng, mỗi thành viên phải tự kiểm tra:
1. **Kiểm tra luồng MVC:** Có Servlet riêng điều phối không? Có DAO riêng truy vấn DB không? Giao diện JSP có sạch mã scriptlet không?
2. **Kiểm tra SQL & Lỗi:** 100% câu truy vấn dùng `PreparedStatement` chưa? Có bị leak connection không?
3. **Kiểm tra Validate:** Nhập sai định dạng (email sai, phone thiếu số, giá tiền âm) hệ thống có chặn và báo lỗi rõ ràng không?
4. **Kiểm tra Phân quyền:** Thử gõ trực tiếp URL của Manager/Admin bằng tài khoản Customer hoặc Guest xem có bị chặn 403 không?
5. **Tiêu chuẩn Ponytail:** Đoạn code vừa viết đã là phiên bản ngắn gọn, tối giản nhất đáp ứng đúng yêu cầu chưa? Có class/interface nào thừa thãi không cần thiết không?

