**CHILDREN CARE SYSTEM**

**ĐẶC TẢ CRUD**

*Đồ án SWP391 – Chia 5 phần cho 5 thành viên*

*Nguồn: ChildrenCare\_Requirements.pdf và ChildrenCare\_Functions.xlsx (35 màn hình). Các mục ghi "giả định" cần được xác nhận trước khi lập trình (xem mục 6).*

# **1\. Giới thiệu và phạm vi**

Tài liệu mô tả các thao tác Create, Read, Update, Delete (CRUD) của hệ thống quản lý trung tâm chăm sóc trẻ em: trường dữ liệu, quy tắc validate và ai được thực hiện thao tác nào. Tài liệu chưa bao gồm thiết kế giao diện, API và sơ đồ CSDL chi tiết.

* **Công nghệ:** C\#, ASP.NET Core MVC, Entity Framework Core, SQL Server (giả định; code bằng Antigravity).

* **5 nhóm người dùng:** Public (Guest), Customer, Staff (Doctor, Nurse), Manager, Admin.

* **Lưu ý:** Mọi ràng buộc về độ dài, định dạng trong tài liệu là đề xuất của nhóm; file Requirements yêu cầu giảng viên duyệt trước khi cài đặt.

# **2\. Quy ước chung**

## **2.1. Vai trò**

| Vai trò | Quyền chính |
| :---- | :---- |
| Guest | Chưa đăng nhập: xem trang public, tạo đặt lịch, gửi feedback, đăng ký, đăng nhập, quên mật khẩu. |
| Customer | Như Guest, thêm My Reservations (xem, sửa, hủy khi còn Submitted), Profile, đổi mật khẩu. |
| Doctor | Xem Reservation được giao, Services, Customers, Feedbacks; xem lịch sử khám; thêm đơn thuốc. |
| Nurse | Như Doctor nhưng không được thêm đơn thuốc. |
| Manager | Quản lý Reservation, Post, Slider, Service, Customer, Feedback; xem Reservation Dashboard. |
| Admin | Admin Dashboard, quản lý Users và Settings. |

## **2.2. Quy ước dữ liệu**

* **Khóa chính:** Mọi bảng có Id kiểu int tự tăng.

* **Xóa mềm:** Không xóa cứng dữ liệu nghiệp vụ. "Delete" nghĩa là ẩn hoặc vô hiệu hóa bằng trường Status, đúng với các nút hide/show trong file Functions.

* **Mốc thời gian:** Mọi bảng chính có CreatedDate và UpdatedDate do hệ thống gán.

* **Phân trang:** Danh sách phân trang 10 dòng/trang (giả định).

* **Sắp xếp mặc định:** Danh sách công khai sắp theo UpdatedDate giảm dần.

* **Phân quyền:** Mỗi thao tác kiểm tra role ở phía server, không chỉ ẩn menu ở giao diện.

## **2.3. Validate chung**

| Loại dữ liệu | Quy tắc |
| :---- | :---- |
| Họ tên | 2–100 ký tự, chỉ chữ cái (có dấu) và khoảng trắng; cắt khoảng trắng đầu/cuối. |
| Email | Đúng định dạng, tối đa 100 ký tự; duy nhất khi dùng làm tài khoản (không phân biệt hoa thường). |
| Số điện thoại | Đúng 10 chữ số, bắt đầu bằng 0\. |
| Mật khẩu | 8–50 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường, 1 chữ số; lưu dạng băm. |
| Ảnh tải lên | jpg, png hoặc webp; tối đa 2 MB mỗi ảnh. |
| Giá tiền | Số nguyên (VND), lớn hơn 0; giá sale không lớn hơn giá gốc. |
| URL (backlink) | Bắt đầu bằng http\:// hoặc https\://, tối đa 500 ký tự. |
| Nội dung HTML | Làm sạch (sanitize) trước khi lưu để chống XSS. |
| Khoảng ngày | "Từ ngày" không lớn hơn "Đến ngày". |

# **3\. Phân công 5 phần**

| Phần | Nội dung | Thực thể | Màn hình (\#) | Phụ thuộc |
| :---- | :---- | :---- | :---- | :---- |
| 1 | Nền tảng và quản trị: đăng nhập, đăng ký, mật khẩu, profile, phân quyền, Users, Settings | User, Setting | 10–15, 32–35 | Không (làm trước) |
| 2 | Nội dung: Home, Blogs, Posts, Sliders | Post, Slider | 1, 2, 3, 18–21 | Phần 1 |
| 3 | Dịch vụ: danh sách và chi tiết public, quản lý Service | Service, ServiceImage | 4, 5, 22, 23 | Phần 1 |
| 4 | Đặt lịch: giỏ đặt lịch, thông tin người nhận, hoàn tất, My Reservations, quản lý Reservation | Reservation, ReservationItem | 6, 7, 8, 16, 17, 28, 29 | Phần 1, 3 |
| 5 | Khách hàng, phản hồi, khám bệnh, dashboard | Contact, ContactHistory, Feedback, FeedbackImage, MedicalExamination, Prescription, PrescriptionItem | 9, 24–27, 30, 31 | Phần 1, 3, 4 |

Thứ tự gợi ý: Phần 1 làm trước vì cung cấp DbContext, đăng nhập và phân quyền. Phần 2 và 3 làm song song sau đó. Phần 4 cần Service từ phần 3\. Phần 5 làm cuối vì cần dữ liệu Reservation.

Người phụ trách: Phần 1 \_\_\_\_\_\_\_\_\_\_\_\_   Phần 2 \_\_\_\_\_\_\_\_\_\_\_\_   Phần 3 \_\_\_\_\_\_\_\_\_\_\_\_   Phần 4 \_\_\_\_\_\_\_\_\_\_\_\_   Phần 5 \_\_\_\_\_\_\_\_\_\_\_\_

# **Phần 1\. Nền tảng và quản trị (User, Setting)**

*Màn hình: 10 User Login, 11 User Register, 12 Reset Password, 13 Change Password, 14 User Profile, 15 User Authorization, 32 Users List, 33 User Details, 34 Settings List, 35 Setting Details.*

## **1.1. Setting**

Mọi dữ liệu cấu hình do người dùng định nghĩa (danh mục bài viết, danh mục dịch vụ, role, menu admin) đều lưu ở bảng Setting. Các phần khác đọc dữ liệu này để đổ vào dropdown.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| Type | nvarchar(50) | Có | Chọn từ danh sách: PostCategory, ServiceCategory, UserRole, AdminMenu. |
| Name | nvarchar(100) | Có | 2–100 ký tự; duy nhất trong cùng Type. |
| Value | nvarchar(255) | Có | Tối đa 255 ký tự (ví dụ đường dẫn của menu, mã role). |
| Description | nvarchar(500) | Không | Tối đa 500 ký tự. |
| Status | enum | Có | Active hoặc Inactive; mặc định Active. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Admin | Nhập Type, Name, Value, Description, Status. Báo lỗi nếu trùng cặp Type và Name. |
| Read (danh sách) | Admin | Phân trang, hiển thị Id, Type, Name, Value, Status. |
| Read (chi tiết) | Admin | Xem đầy đủ một setting. |
| Update | Admin | Sửa mọi trường trừ Id. Role hệ thống (Customer, Doctor, Nurse, Manager, Admin) không được đổi Value. |
| Delete | Admin | Không xóa cứng. Đặt Status \= Inactive để ẩn; setting Inactive không hiện ở dropdown nhưng dữ liệu cũ vẫn giữ. |

**Quy tắc danh sách và ghi chú**

* **Lọc:** Type, Status.

* **Tìm kiếm:** Name, Value.

* **Sắp xếp:** Id, Type, Name, Value, Status.

* **Dữ liệu khởi tạo:** Cần seed sẵn 5 role và vài danh mục mẫu để các phần khác dùng được ngay.

## **1.2. User**

Dùng cho cả đăng ký của khách và tài khoản do Admin tạo. Email là tên đăng nhập.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| FullName | nvarchar(100) | Có | Theo validate Họ tên. |
| Gender | enum | Có | Male, Female hoặc Other. |
| Email | nvarchar(100) | Có | Duy nhất; không được sửa sau khi tạo. |
| Mobile | varchar(10) | Có | Theo validate Số điện thoại. |
| Address | nvarchar(255) | Không | Tối đa 255 ký tự. |
| AvatarUrl | nvarchar(255) | Không | Theo validate Ảnh tải lên. |
| PasswordHash | nvarchar(255) | Có | Chỉ lưu bản băm. |
| RoleId | int, FK Setting (UserRole) | Có | Tự đăng ký thì mặc định Customer. |
| Status | enum | Có | Unverified, Active, Inactive. Tự đăng ký bắt đầu ở Unverified, chuyển Active khi bấm link xác thực. |
| VerifyToken, VerifyTokenExpiry | nvarchar(100), datetime | Không | Token xác thực email. |
| ResetToken, ResetTokenExpiry | nvarchar(100), datetime | Không | Hạn của link reset lấy từ file cấu hình, dùng một lần. |
| CreatedDate, UpdatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create – Đăng ký | Guest | Nhập FullName, Gender, Email, Mobile, Address, mật khẩu (2 lần). Tạo user role Customer, Status Unverified, gửi email có link xác thực. Chưa xác thực thì không đăng nhập được. |
| Create – Admin tạo | Admin | Nhập thông tin và chọn Role. Hệ thống sinh mật khẩu ngẫu nhiên, gửi qua email cho user; Status \= Active. |
| Login | Mọi người | Nhập Email và mật khẩu. Sai thì báo thông báo chung, không tiết lộ email hay mật khẩu sai. Tài khoản Unverified hoặc Inactive bị từ chối. Đăng nhập xong chuyển trang theo role. |
| Read (danh sách) | Admin | Hiển thị Id, FullName, Gender, Email, Mobile, Role, Status, phân trang. |
| Read (chi tiết) | Admin | Xem đầy đủ avatar, thông tin và role. |
| Update – Profile | Chính chủ | Sửa FullName, Gender, Mobile, Address, Avatar. Không được sửa Email. |
| Update – Đổi mật khẩu | Chính chủ | Nhập mật khẩu hiện tại, mật khẩu mới 2 lần. Mật khẩu hiện tại phải đúng; mật khẩu mới khác mật khẩu cũ và khớp lần nhập lại. |
| Update – Quên mật khẩu | Guest | Nhập Email để nhận link reset. Mở link, nhập mật khẩu mới 2 lần. Link hết hạn hoặc đã dùng thì báo lỗi. |
| Update – Admin | Admin | Chỉ được sửa Role và Status của user. |
| Delete | Admin | Không xóa. Đặt Status \= Inactive để khóa tài khoản. |

**Quy tắc danh sách và ghi chú**

* **Lọc:** Gender, Role, Status.

* **Tìm kiếm:** FullName, Email, Mobile.

* **Sắp xếp:** Id, FullName, Gender, Email, Mobile, Role, Status.

* **Phân quyền (màn 15):** Sau đăng nhập, xây menu theo role (đọc Setting loại AdminMenu). Truy cập trực tiếp URL không đúng quyền phải bị chặn: chưa đăng nhập thì chuyển về trang đăng nhập, sai quyền thì báo 403\.

# **Phần 2\. Nội dung (Post, Slider)**

*Màn hình: 1 Home Page, 2 Blogs List, 3 Blog Details, 18 Posts List, 19 Post Details, 20 Sliders List, 21 Slider Details.*

## **2.1. Post**

Bài viết hiển thị ở Home và Blogs. Danh mục lấy từ Setting loại PostCategory.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| Title | nvarchar(200) | Có | 5–200 ký tự. |
| Thumbnail | nvarchar(255) | Có | Theo validate Ảnh tải lên. |
| CategoryId | int, FK Setting | Có | Phải thuộc PostCategory đang Active. |
| AuthorId | int, FK User | Có | Tự gán là người đang đăng nhập khi tạo; không sửa. |
| BriefInfo | nvarchar(500) | Có | 10–500 ký tự. |
| Description | ntext | Có | Nội dung HTML, đã sanitize. |
| IsFeatured | bit | Có | Bật/tắt bài nổi bật (hot post); mặc định tắt. |
| Status | enum | Có | Published hoặc Hidden; mặc định Hidden. |
| CreatedDate, UpdatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Manager | Nhập Title, Thumbnail, Category, BriefInfo, Description, Featured, Status. |
| Read – quản lý | Manager | Danh sách phân trang gồm Id, Thumbnail, Title, Category, Author, Featured, Status; có trang chi tiết. |
| Read – công khai | Guest, mọi người | Blogs List chỉ hiện bài Published, sắp theo UpdatedDate giảm dần, phân trang, kèm ô tìm kiếm và lọc danh mục. Blog Details hiện Title, Author, UpdatedDate, Category, Description. Home hiện các bài IsFeatured. |
| Update | Manager | Sửa mọi trường trừ Id và Author; UpdatedDate tự cập nhật. |
| Delete | Manager | Không xóa cứng. Nút hide đặt Hidden, nút show đặt Published. |

**Quy tắc danh sách và ghi chú**

* **Lọc (quản lý):** Category, Author, Status.

* **Tìm kiếm:** Title.

* **Sắp xếp:** Title, Category, Author, Featured, Status.

## **2.2. Slider**

Ảnh trượt ở trang chủ; bấm vào chuyển đến backlink.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| Title | nvarchar(200) | Có | 2–200 ký tự. |
| ImageUrl | nvarchar(255) | Có | Theo validate Ảnh tải lên. |
| BackLink | nvarchar(500) | Có | Theo validate URL. |
| Status | enum | Có | Active hoặc Inactive; mặc định Active. |
| Notes | nvarchar(500) | Không | Tối đa 500 ký tự. |
| CreatedDate, UpdatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Manager | Nhập Title, Image, BackLink, Status, Notes. |
| Read – quản lý | Manager | Danh sách phân trang gồm Id, Title, Image, BackLink, Status; có trang chi tiết. |
| Read – công khai | Guest, mọi người | Home chỉ hiện slider Active, hiển thị ảnh và tiêu đề, bấm chuyển tới BackLink. |
| Update | Manager | Sửa mọi trường trừ Id. |
| Delete | Manager | Không xóa cứng. Nút hide đặt Inactive, nút show đặt Active. |

**Quy tắc danh sách và ghi chú**

* **Lọc:** Status.

* **Tìm kiếm:** Title, BackLink.

# **Phần 3\. Dịch vụ (Service)**

*Màn hình: 4 Services List, 5 Service Details (public), 22 Services List, 23 Service Details (Manager). Staff chỉ được xem, lọc, tìm kiếm.*

## **3.1. Service**

Dịch vụ khám và chăm sóc mà khách đặt lịch. Danh mục lấy từ Setting loại ServiceCategory.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| Title | nvarchar(200) | Có | 5–200 ký tự. |
| Thumbnail | nvarchar(255) | Có | Theo validate Ảnh tải lên. |
| CategoryId | int, FK Setting | Có | Phải thuộc ServiceCategory đang Active. |
| BriefInfo | nvarchar(500) | Có | 10–500 ký tự. |
| Description | ntext | Có | Nội dung HTML, đã sanitize. |
| NumberOfPerson | int | Có | Số người mặc định của dịch vụ, từ 1 trở lên. |
| ListPrice | decimal(18,0) | Có | Lớn hơn 0\. |
| SalePrice | decimal(18,0) | Có | Lớn hơn 0 và không lớn hơn ListPrice. |
| AvailableQuantity | int | Có | Từ 0 trở lên; giảm khi đặt lịch, hoàn lại khi hủy (xem Phần 4). |
| IsFeatured | bit | Có | Bật/tắt dịch vụ nổi bật ở Home; mặc định tắt. |
| Status | enum | Có | Active hoặc Inactive; mặc định Inactive. |
| CreatedDate, UpdatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Manager | Nhập đầy đủ thông tin, đính kèm nhiều ảnh (ServiceImage), chọn Featured và Status. |
| Read – quản lý | Manager, Doctor, Nurse | Danh sách phân trang gồm Id, Thumbnail, Title, Category, ListPrice, SalePrice, Featured, Status. Staff chỉ xem. |
| Read – công khai | Guest, mọi người | Services List chỉ hiện dịch vụ Active, sắp theo UpdatedDate giảm dần, phân trang, kèm ô tìm kiếm và lọc danh mục; hiện Thumbnail, Title, BriefInfo, ListPrice, SalePrice. Service Details hiện thêm ảnh và Description. Có nút thêm vào giỏ và nút feedback. |
| Update | Manager | Sửa mọi trường trừ Id. Đổi giá không làm đổi giá của đặt lịch đã Submitted. |
| Delete | Manager | Không xóa cứng. Nút hide đặt Inactive, nút show đặt Active. |

**Quy tắc danh sách và ghi chú**

* **Lọc (quản lý):** Status.

* **Tìm kiếm:** Title, BriefInfo.

* **Sắp xếp:** Title, Category, ListPrice, SalePrice, Featured, Status.

## **3.2. ServiceImage**

Các ảnh đính kèm của một dịch vụ.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| ServiceId | int, FK Service | Có | Phải tồn tại. |
| ImageUrl | nvarchar(255) | Có | Theo validate Ảnh tải lên. |
| SortOrder | int | Không | Thứ tự hiển thị, mặc định theo thứ tự tải lên. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Manager | Thêm ảnh khi tạo hoặc sửa Service (giả định tối đa 10 ảnh/dịch vụ). |
| Read | Mọi người | Hiển thị trong Service Details. |
| Update | Manager | Đổi thứ tự ảnh. |
| Delete | Manager | Xóa cứng được vì chỉ là tài nguyên đính kèm. |

# **Phần 4\. Đặt lịch (Reservation)**

*Màn hình: 6 Reservation Details (giỏ), 7 Reservation Contact, 8 Reservation Completion, 16 My Reservations, 17 Reservation Information, 28 Reservations List, 29 Reservation Details (Staff/Manager).*

Giỏ đặt lịch chính là Reservation có Status \= Cart. Giỏ được giữ lại giữa các phiên (người đã đăng nhập lưu theo UserId; khách vãng lai lưu theo cookie/session). Giá dịch vụ trong giỏ luôn lấy giá mới nhất của hệ thống.

## **4.1. Reservation**

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| UserId | int, FK User | Không | Có khi khách đã đăng nhập; trống với khách vãng lai. |
| ReservedDate | datetime | Có | Gán lúc Submit. |
| CheckupTime | datetime | Có | Thời gian khám. Phải sau thời điểm hiện tại và nằm trong khung giờ làm việc (giả định, xem mục 6). |
| ReceiverFullName | nvarchar(100) | Có | Theo validate Họ tên. |
| ReceiverGender | enum | Có | Male, Female hoặc Other. |
| ReceiverEmail | nvarchar(100) | Có | Theo validate Email (không cần duy nhất). |
| ReceiverMobile | varchar(10) | Có | Theo validate Số điện thoại. |
| ReceiverAddress | nvarchar(255) | Không | Tối đa 255 ký tự. |
| Notes | nvarchar(500) | Không | Tối đa 500 ký tự. |
| TotalCost | decimal(18,0) | Có | Tổng TotalCost của các ReservationItem; hệ thống tự tính. |
| Status | enum | Có | Cart, Submitted, Success, Cancelled (giả định). |
| AssignedStaffId | int, FK User | Không | Doctor hoặc Nurse phụ trách; gán lúc Submit. |
| CreatedDate, UpdatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create – Submit | Guest, Customer | Từ Reservation Contact: kiểm tra giỏ không rỗng, nhập thông tin người nhận (nếu đã đăng nhập thì điền sẵn từ profile), bấm Submit. Hệ thống đổi Status sang Submitted, trừ AvailableQuantity của từng dịch vụ, tự gán nhân viên theo vòng xoay (hoặc khách chọn), lưu hoặc cập nhật Contact (Phần 5\) và gửi email xác nhận kèm hướng dẫn thanh toán (thông tin ngân hàng lấy từ file cấu hình). Lỗi kỹ thuật hoặc hết slot thì chuyển sang trang lỗi. |
| Read – của tôi | Customer | My Reservations: danh sách phân trang gồm Id, ReservedDate, dịch vụ đầu tiên và số người, CheckupTime, TotalCost, Status. Bấm Id để xem Reservation Information. |
| Read – quản lý | Doctor, Nurse, Manager | Reservations List và Reservation Details. Staff chỉ thấy đặt lịch được giao cho mình; Manager thấy tất cả. |
| Update – Customer | Customer | Chỉ khi Status \= Submitted: sửa các dịch vụ (chuyển về trang giỏ) hoặc hủy. Hủy: Status \= Cancelled và hoàn lại AvailableQuantity. |
| Update – Manager | Manager | Đổi Status; gán lại cho nhân viên khác. |
| Delete | Hệ thống | Không xóa đặt lịch đã Submitted. Giỏ Cart bị bỏ quên quá lâu có thể dọn tự động (giả định). |

**Quy tắc danh sách và ghi chú**

* **Lọc (Staff, Manager):** Khoảng ngày đặt (từ, đến), Status, nhân viên được giao.

* **Tìm kiếm:** Mã đặt lịch, tên khách.

* **Sắp xếp:** Ngày đặt, tên khách, TotalCost, Status.

## **4.2. ReservationItem**

Từng dịch vụ trong giỏ hoặc đặt lịch.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| ReservationId | int, FK Reservation | Có | Phải tồn tại. |
| ServiceId | int, FK Service | Có | Dịch vụ phải Active; không thêm trùng trong cùng một giỏ (cộng thêm số lượng). |
| UnitPrice | decimal(18,0) | Có | Giỏ: lấy SalePrice mới nhất. Sau Submit: giá được chốt, không đổi nữa. |
| Quantity | int | Có | Từ 1 đến AvailableQuantity của dịch vụ. |
| NumberOfPerson | int | Có | Từ 1 trở lên (giả định tối đa 10). |
| TotalCost | decimal(18,0) | Có | UnitPrice × Quantity × NumberOfPerson (giả định, xem mục 6). |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Guest, Customer | Bấm Buy ở Services List hoặc Service Details để thêm vào giỏ (tạo giỏ nếu chưa có). |
| Read | Guest, Customer, Staff | Giỏ hiển thị Id, Title, UnitPrice, Quantity, NumberOfPerson, TotalCost và tổng tiền. |
| Update | Guest, Customer | Đổi Quantity hoặc NumberOfPerson, TotalCost và tổng tiền tự cập nhật. Sau Submit chỉ sửa được khi Customer sửa đặt lịch Submitted. |
| Delete | Guest, Customer | Bấm biểu tượng xóa để bỏ dịch vụ khỏi giỏ. Giỏ trống thì không được Submit. |

# **Phần 5\. Khách hàng, phản hồi, khám bệnh, dashboard**

*Màn hình: 9 Feedback, 24 Customers List, 25 Customer Details, 26 Feedbacks List, 27 Feedback Details, 30 Medical examination, 31 Admin Dashboard (cộng Reservation Dashboard của Manager trong file Requirements).*

## **5.1. Contact (Customer)**

Thông tin liên hệ mới nhất của khách, dùng cho marketing. Khác với User: Contact có thể chưa có tài khoản.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| FullName | nvarchar(100) | Có | Theo validate Họ tên. |
| Gender | enum | Có | Male, Female hoặc Other. |
| Email | nvarchar(100) | Có | Duy nhất trong bảng Contact; dùng để nhận diện khách. |
| Mobile | varchar(10) | Có | Theo validate Số điện thoại. |
| Address | nvarchar(255) | Không | Tối đa 255 ký tự. |
| Status | enum | Có | Contact, Potential hoặc Customer. Hệ thống tự sinh, không cho sửa tay. |
| CreatedDate, UpdatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Manager; hệ thống | Manager nhập tay. Hệ thống cũng tự tạo khi Submit đặt lịch hoặc gửi Feedback với email chưa có. |
| Read (danh sách) | Manager, Doctor, Nurse | Hiển thị Id, FullName, Gender, Email, Mobile, Status, phân trang. Staff chỉ xem. |
| Read (chi tiết) | Manager, Doctor, Nurse | Xem thông tin và bảng lịch sử thay đổi (ContactHistory). |
| Update | Manager; hệ thống | Manager sửa mọi trường trừ Status. Khi Submit đặt lịch có thông tin mới (so theo email) thì cập nhật Contact. |
| Delete | — | Không xóa. Status do hệ thống quản lý. |

**Quy tắc danh sách và ghi chú**

* **Lọc:** Status.

* **Tìm kiếm:** FullName, Email, Mobile.

* **Sắp xếp:** FullName, Email, Mobile, Status.

## **5.2. ContactHistory**

Mỗi lần thông tin Contact thay đổi, lưu một bản ghi lịch sử.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| ContactId | int, FK Contact | Có | Phải tồn tại. |
| Email, FullName, Gender, Mobile, Address | như Contact | Có | Giá trị tại thời điểm đó. |
| UpdatedBy | int, FK User | Không | Trống nếu hệ thống tự cập nhật. |
| UpdatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Hệ thống | Tự tạo khi Contact được tạo hoặc thay đổi. |
| Read | Manager, Doctor, Nurse | Hiển thị dạng bảng trong Customer Details: email, họ tên, giới tính, mobile, địa chỉ, người sửa, ngày sửa. |
| Update, Delete | — | Không cho phép (lịch sử chỉ thêm, không sửa). |

## **5.3. Feedback và FeedbackImage**

Phản hồi chung hoặc cho một dịch vụ cụ thể.

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| Id | int, PK | Có | Hệ thống tự sinh. |
| FullName, Gender, Email, Mobile | như Contact | Có | Theo validate chung; nếu đã đăng nhập thì điền sẵn. |
| ServiceId | int, FK Service | Không | Trống nghĩa là feedback chung. |
| RatedStar | int | Có | Từ 1 đến 5\. |
| Content | nvarchar(1000) | Có | 10–1000 ký tự. |
| Status | enum | Có | Published hoặc Hidden; mặc định Published (giả định). |
| Images (FeedbackImage: Id, FeedbackId, ImageUrl) | bảng con | Không | Tối đa 5 ảnh, theo validate Ảnh tải lên. |
| CreatedDate | datetime | Có | Hệ thống tự gán. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Guest, Customer | Gửi từ menu, từ nút Feedback ở dịch vụ hoặc từ link trong email sau buổi khám. Tự tạo hoặc cập nhật Contact theo email. |
| Read (danh sách) | Manager, Doctor, Nurse | Hiển thị FullName, tên dịch vụ, RatedStar, Status, phân trang. |
| Read (chi tiết) | Manager, Doctor, Nurse | Xem họ tên, email, mobile, dịch vụ, số sao, nội dung, ảnh, status. |
| Update | Manager | Chỉ được đổi Status; không sửa nội dung phản hồi. |
| Delete | Manager | Không xóa cứng; ẩn bằng Status \= Hidden. |

**Quy tắc danh sách và ghi chú**

* **Lọc:** Status, Service, RatedStar.

* **Tìm kiếm:** FullName, Content.

* **Sắp xếp:** FullName, tên dịch vụ, RatedStar, Status.

## **5.4. MedicalExamination, Prescription, PrescriptionItem**

Lịch sử khám của khách thuộc đặt lịch được giao cho nhân viên. Một đặt lịch có thể có một lần khám; một lần khám có thể có nhiều đơn thuốc; một đơn thuốc có nhiều dòng thuốc (giả định).

**Trường dữ liệu**

| Trường | Kiểu dữ liệu | Bắt buộc | Quy tắc validate / ghi chú |
| :---- | :---- | :---- | :---- |
| MedicalExamination.Id, ReservationId | int, PK, FK Reservation | Có | Đặt lịch phải được giao cho Doctor đang đăng nhập. |
| MedicalExamination.ExaminationDate | datetime | Có | Không sau thời điểm hiện tại. |
| MedicalExamination.DoctorId | int, FK User | Có | Role Doctor. |
| Prescription.Id, ExaminationId | int, PK, FK | Có | Hệ thống tự sinh. |
| Prescription.Diagnosis | nvarchar(500) | Có | 5–500 ký tự. |
| Prescription.Note | nvarchar(500) | Không | Tối đa 500 ký tự. |
| PrescriptionItem.MedicineName | nvarchar(150) | Có | 2–150 ký tự. |
| PrescriptionItem.Dosage | nvarchar(100) | Có | Liều dùng, tối đa 100 ký tự. |
| PrescriptionItem.Quantity | int | Có | Từ 1 trở lên. |
| PrescriptionItem.Usage | nvarchar(255) | Không | Hướng dẫn sử dụng. |

**Thao tác CRUD**

| Thao tác | Người thực hiện | Mô tả và quy tắc |
| :---- | :---- | :---- |
| Create | Doctor | Từ đặt lịch được giao: tạo lần khám và thêm đơn thuốc với ít nhất 1 dòng thuốc. |
| Read | Doctor, Nurse | Medical examination: lịch sử khám gồm ngày, dịch vụ đã dùng, đơn thuốc; chỉ của khách thuộc đặt lịch được giao cho mình. Lọc theo dịch vụ, ngày, tên thuốc. |
| Update, Delete | — | Không cho phép (hồ sơ y tế chỉ thêm, không sửa hay xóa). Cần xác nhận ở mục 6\. |

**Quy tắc danh sách và ghi chú**

* **Phân quyền:** Nurse chỉ xem, không được thêm đơn thuốc.

## **5.5. Dashboard (chỉ đọc)**

| Màn hình | Người xem | Nội dung |
| :---- | :---- | :---- |
| Admin Dashboard | Admin | Đặt lịch mới theo trạng thái (Success, Cancelled, Submitted); doanh thu (tổng và theo ServiceCategory); khách (đăng ký mới, đặt lịch mới); feedback (số sao trung bình tổng và theo dịch vụ); biểu đồ số đặt lịch (Success và tất cả) theo ngày, mặc định 7 ngày gần nhất, cho chọn ngày bắt đầu và kết thúc. |
| Reservation Dashboard | Manager | Thống kê và xu hướng dữ liệu đặt lịch (file Requirements không nêu chi tiết, giả định dùng lại các số liệu đặt lịch của Admin Dashboard). |

# **6\. Điểm cần xác nhận**

Các điểm file nguồn chưa nói rõ hoặc mâu thuẫn. Tài liệu hiện đang dùng phần "Giả định" để làm tiếp.

| \# | Vấn đề | Giả định hiện tại |
| :---- | :---- | :---- |
| 1 | Kiểu ứng dụng cụ thể: ASP.NET Core MVC, Razor Pages hay Blazor? Dùng SQL Server? | ASP.NET Core MVC, EF Core, SQL Server. |
| 2 | Requirements ghi 37 màn hình nhưng Excel chỉ có 35\. Các màn Staff (Services, Customers, Feedbacks) và Reservation Dashboard của Manager không có trong Excel. | Staff dùng lại màn của Manager ở chế độ chỉ xem; Reservation Dashboard dùng số liệu đặt lịch. |
| 3 | Đăng ký (màn 11\) liệt kê họ tên, giới tính, email, mobile, địa chỉ nhưng không nói mật khẩu lấy ở đâu. | Người dùng tự nhập mật khẩu 2 lần khi đăng ký. |
| 4 | Công thức tổng tiền mỗi dịch vụ: giá × số lượng × số người, hay chỉ giá × số lượng? | Giá × Quantity × NumberOfPerson. |
| 5 | Ai chọn CheckupTime? Màn Reservation Contact không có ô này nhưng My Reservations hiển thị. "Slot" lấy từ đâu? | Khách chọn ngày giờ khi Submit, trong khung giờ làm việc cấu hình. |
| 6 | Các trạng thái của Reservation và ai chuyển sang Success. | Cart, Submitted, Success, Cancelled; Manager hoặc Doctor chuyển Success sau khi khám. |
| 7 | Quy tắc tự sinh trạng thái Contact (Contact, Potential, Customer). | Contact: mới có thông tin; Potential: có đặt lịch Submitted; Customer: có đặt lịch Success. |
| 8 | Cách chọn nhân viên: tự gán xoay vòng hay khách chọn? Doctor và Nurse là hai role hay một role Staff. | Hai role riêng; mặc định gán xoay vòng. |
| 9 | "Sale name" ở Reservation Details của Staff nghĩa là gì? | Hiểu là nhân viên được giao (AssignedStaff). |
| 10 | Có bảng thuốc (Medicine) riêng không? Có cho sửa hoặc xóa đơn thuốc không? | Nhập tên thuốc tự do; đơn thuốc không sửa, không xóa. |
| 11 | Feedback có hiển thị công khai trên web không? Khách vãng lai có được gửi không? | Có thể gửi mà không cần đăng nhập; mặc định Published, Manager có thể ẩn. |
| 12 | Các giới hạn độ dài và định dạng trong tài liệu (mục 2.3) cần giảng viên duyệt. | Dùng giá trị đề xuất trong tài liệu. |

