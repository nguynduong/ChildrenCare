-- ==========================================================================
-- CHILDREN CARE SYSTEM (CCS) - DỮ LIỆU MẪU ĐỂ TEST & DEMO HỆ THỐNG
-- Chuẩn SWP391 - Chạy SAU schema.sql
--
-- TẤT CẢ TÀI KHOẢN MẪU DÙNG CHUNG MẬT KHẨU: 123456
-- Mật khẩu đã được mã hóa bằng BCrypt: $2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm
-- ==========================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE ChildrenCareDB;
GO

-- 1. BỔ SUNG SETTINGS (DANH MỤC DỊCH VỤ, BÀI VIẾT, ROLE)
SET IDENTITY_INSERT Settings ON;

-- Đảm bảo có đủ 5 Roles (Id 1..5)
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 1)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (1, 'UserRole', 'Customer', '1', N'Khách hàng đã đăng ký', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 2)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (2, 'UserRole', 'Doctor', '2', N'Bác sĩ nhi khoa', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 3)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (3, 'UserRole', 'Nurse', '3', N'Điều dưỡng / Y tá', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 4)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (4, 'UserRole', 'Manager', '4', N'Quản lý trung tâm', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 5)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (5, 'UserRole', 'Admin', '5', N'Quản trị viên hệ thống', 'Active');

-- Danh mục bài viết
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 6)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (6, 'PostCategory', N'Chăm sóc trẻ sơ sinh', '1', N'Kiến thức chăm sóc bé dưới 1 tuổi', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 7)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (7, 'PostCategory', N'Dinh dưỡng & Ăn dặm', '2', N'Thực đơn và cẩm nang dinh dưỡng', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 8)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (8, 'PostCategory', N'Bệnh lý thường gặp', '3', N'Nhận biết triệu chứng sốt, ho, dị ứng', 'Active');

-- Danh mục dịch vụ
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 9)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (9, 'ServiceCategory', N'Khám sức khỏe tổng quát', '1', N'Gói khám tổng thể định kỳ theo mốc tuổi', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 10)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (10, 'ServiceCategory', N'Tiêm chủng vắc-xin', '2', N'Các gói tiêm phòng đạt chuẩn quốc tế', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 11)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (11, 'ServiceCategory', N'Tư vấn dinh dưỡng chuyên sâu', '3', N'Phác đồ dinh dưỡng cho trẻ biếng ăn, còi cọc', 'Active');
IF NOT EXISTS (SELECT 1 FROM Settings WHERE Id = 12)
    INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES (12, 'ServiceCategory', N'Khám Tai - Mũi - Họng', '4', N'Nội soi và điều trị hô hấp nhi khoa', 'Active');

SET IDENTITY_INSERT Settings OFF;
GO

-- 2. TÀI KHOẢN ĐĂNG NHẬP THEO TỪNG VAI TRÒ (MẬT KHẨU TẤT CẢ: 123456)
-- Hash BCrypt: $2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm
SET IDENTITY_INSERT Users ON;

-- Xóa dữ liệu cũ nếu có để nạp bộ test sạch sẽ
DELETE FROM Users WHERE Id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

INSERT INTO Users (Id, FullName, Gender, Email, Mobile, Address, AvatarUrl, PasswordHash, RoleId, Status) VALUES
-- Admin (Quản trị hệ thống)
(1, N'Trần Đại Nghĩa (Admin)', 'Male', 'admin@childrencare.com', '0912345678', N'Số 1 Đại Cồ Việt, Hai Bà Trưng, Hà Nội', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 5, 'Active'),

-- Manager (Quản lý dịch vụ, bài viết, khách hàng)
(2, N'Nguyễn Thu Trang (Manager)', 'Female', 'manager@childrencare.com', '0987654321', N'Số 18 Tam Trinh, Hoàng Mai, Hà Nội', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 4, 'Active'),

-- Doctor (Bác sĩ chuyên khoa Nhi)
(3, N'BS.CKII Trịnh Văn Minh', 'Male', 'doctor@childrencare.com', '0901234567', N'BV Nhi Trung Ương, Đống Đa, Hà Nội', 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 2, 'Active'),
(4, N'ThS.BS Lê Thị Mai', 'Female', 'doctor2@childrencare.com', '0901234568', N'BV Bạch Mai, Thanh Xuân, Hà Nội', 'https://images.unsplash.com/photo-1594824813589-1d48c8b67104?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 2, 'Active'),

-- Nurse (Điều dưỡng / Y tá)
(5, N'ĐD. Trần Thảo Vy', 'Female', 'nurse@childrencare.com', '0902345678', N'Số 26 Liễu Giai, Ba Đình, Hà Nội', 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 3, 'Active'),
(6, N'ĐD. Nguyễn Hải Yến', 'Female', 'nurse2@childrencare.com', '0902345679', N'Số 89 Nguyễn Trãi, Thanh Xuân, Hà Nội', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 3, 'Active'),

-- Customer (Khách hàng đã xác thực, có lịch hẹn)
(7, N'Phạm Hoàng Nam (Phụ huynh)', 'Male', 'customer@childrencare.com', '0934567890', N'Căn 1205 Chung cư Royal City, Thanh Xuân, Hà Nội', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 1, 'Active'),
(8, N'Đặng Thu Thảo (Phụ huynh)', 'Female', 'khachhang2@gmail.com', '0934567891', N'Căn 802 Chung cư Times City, Hai Bà Trưng, Hà Nội', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 1, 'Active'),

-- Test Case đặc biệt: Tài khoản chưa kích hoạt (Unverified)
(9, N'Người Dùng Chưa Kích Hoạt', 'Male', 'unverified@childrencare.com', '0934567892', N'Cầu Giấy, Hà Nội', NULL, '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 1, 'Unverified'),

-- Test Case đặc biệt: Tài khoản bị khóa (Inactive)
(10, N'Tài Khoản Bị Khóa', 'Male', 'inactive@childrencare.com', '0934567893', N'Đống Đa, Hà Nội', NULL, '$2a$10$zT84pKtOEfx1vO6h97AqFOHNBfoNNwgMDQAm5018jtLCVHsZU5HPm', 1, 'Inactive');

SET IDENTITY_INSERT Users OFF;
GO

-- 3. BANNER SLIDERS TRANG CHỦ
DELETE FROM Sliders;
INSERT INTO Sliders (Title, ImageUrl, BackLink, Status, Notes) VALUES
(N'Chăm sóc toàn diện sức khỏe cho bé yêu cùng chuyên gia Nhi khoa', 'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=1200', '/services', 'Active', N'Banner chính 1'),
(N'Gói tiêm chủng vắc-xin trọn gói chuẩn quốc tế - Không lo sốt', 'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=1200', '/services', 'Active', N'Banner chính 2'),
(N'Đội ngũ y bác sĩ tận tâm, trang thiết bị y tế hiện đại, thân thiện trẻ nhỏ', 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=1200', '/blogs', 'Active', N'Banner chính 3');
GO

-- 4. BÀI VIẾT / TIN TỨC (POSTS)
DELETE FROM Posts;
INSERT INTO Posts (Title, Thumbnail, CategoryId, AuthorId, BriefInfo, Description, IsFeatured, Status) VALUES
(N'Cẩm nang chăm sóc rốn trẻ sơ sinh an toàn tại nhà', 'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=600', 6, 3, 
 N'Hướng dẫn chi tiết các bước vệ sinh cuống rốn cho bé mới sinh đúng chuẩn y khoa tránh nhiễm trùng nguy hiểm.',
 N'<p>Cuống rốn của trẻ sơ sinh là vết thương hở rất nhạy cảm. Việc chăm sóc rốn đúng cách đóng vai trò sống còn trong việc ngăn chặn nhiễm trùng uốn ván và nhiễm khuẩn máu sơ sinh.</p><h4>1. Nguyên tắc chăm sóc rốn</h4><ul><li>Luôn rửa tay sát khuẩn trước khi chạm vào bé.</li><li>Để cuống rốn khô thoáng tự nhiên, không băng kín hoặc đắp bất kỳ loại lá thuốc nào.</li><li>Vệ sinh bằng nước muối sinh lý 0.9% từ chân rốn ra ngoài.</li></ul><h4>2. Khi nào cần gặp bác sĩ ngay?</h4><p>Nếu rốn bé có mùi hôi, rỉ dịch mủ vàng, da quanh chân rốn sưng đỏ hoặc bé bị sốt li bì, phụ huynh cần đưa bé đến trung tâm ChildrenCare ngay lập tức.</p>', 
 1, 'Published'),

(N'Thực đơn ăn dặm khoa học cho bé từ 6 đến 12 tháng tuổi', 'https://images.unsplash.com/photo-1584473457406-6240486418e9?w=600', 7, 4,
 N'Nguyên tắc vàng khi bắt đầu cho trẻ ăn dặm kết hợp 4 nhóm dưỡng chất thiết yếu giúp bé tăng cân chuẩn biểu đồ WHO.',
 N'<p>Giai đoạn 6 tháng tuổi là cột mốc vàng khi hệ tiêu hóa của bé đã sẵn sàng đón nhận thức ăn đặc ngoài sữa mẹ. Hãy cùng chuyên gia dinh dưỡng ChildrenCare xây dựng khẩu phần khoa học.</p><h4>Các nhóm chất không thể thiếu:</h4><ol><li><strong>Tinh bột:</strong> Gạo tẻ, yến mạch, khoai lang xay nhuyễn.</li><li><strong>Đạm:</strong> Lòng đỏ trứng gà, thịt ức gà, thịt nạc thăn heo.</li><li><strong>Chất béo:</strong> Dầu oliu ép lạnh hoặc dầu gấc.</li><li><strong>Vitamin & Khoáng chất:</strong> Rau ngót, bí đỏ, cà rốt.</li></ol>',
 1, 'Published'),

(N'Cách xử lý nhanh khi trẻ bị sốt cao co giật phụ huynh cần biết', 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=600', 8, 3,
 N'Những thao tác sơ cứu quan trọng tại nhà giúp bảo vệ tính mạng trẻ và tránh di chứng não khi cơn sốt vượt 39 độ C.',
 N'<p>Sốt cao co giật thường gặp ở trẻ từ 6 tháng đến 5 tuổi. Bình tĩnh xử lý theo các bước sau:</p><ul><li>Đặt trẻ nằm nghiêng một bên trên bề mặt phẳng, thông thoáng.</li><li>Nới lỏng quần áo, tuyệt đối KHÔNG nhét bất cứ thứ gì vào miệng trẻ.</li><li>Dùng khăn ấm lau các vùng nách, bẹn để hạ nhiệt.</li><li>Đưa trẻ đến cơ sở y tế gần nhất sau khi cơn co giật kết thúc.</li></ul>',
 0, 'Published'),

(N'Lịch tiêm phòng đầy đủ cho trẻ em từ sơ sinh đến 5 tuổi năm 2026', 'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=600', 6, 2,
 N'Tổng hợp các mũi vắc-xin 6 trong 1, phế cầu, rota virus, cúm mùa giúp tạo lá chắn miễn dịch hoàn hảo cho con.',
 N'<p>Tiêm phòng đầy đủ đúng lịch là món quà sức khỏe vô giá cha mẹ dành cho con. Danh mục vắc-xin cập nhật mới nhất tại ChildrenCare sẵn sàng phục vụ các bé.</p>',
 1, 'Published');
GO

-- 5. DỊCH VỤ KHÁM & CHĂM SÓC (SERVICES)
DELETE FROM Services;
INSERT INTO Services (Title, Thumbnail, CategoryId, BriefInfo, Description, NumberOfPerson, ListPrice, SalePrice, AvailableQuantity, IsFeatured, Status) VALUES
(N'Gói khám sức khỏe tổng quát định kỳ cho trẻ', 'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=600', 9,
 N'Đánh giá toàn diện thể lực, tim mạch, hô hấp, mắt, tai mũi họng và biểu đồ tăng trưởng chiều cao, cân nặng.',
 N'<p>Gói khám được thiết kế bởi các chuyên gia đầu ngành Nhi khoa, giúp phát hiện sớm các dị tật bẩm sinh, thiếu hụt vi chất hoặc bệnh lý tiềm ẩn.</p><h5>Chi tiết gói khám:</h5><ul><li>Đo chỉ số sinh tồn, chiều cao, cân nặng, vòng đầu.</li><li>Khám chuyên khoa: Tim mạch, Phổi, Tiêu hóa, Thần kinh.</li><li>Nội soi Tai - Mũi - Họng kỹ thuật số êm ái, không đau.</li><li>Xét nghiệm công thức máu và tư vấn chế độ sinh hoạt.</li></ul>',
 1, 800000, 650000, 50, 1, 'Active'),

(N'Gói tiêm chủng trọn gói cho bé từ 0 - 12 tháng tuổi', 'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=600', 10,
 N'Bao gồm đầy đủ các mũi vắc-xin quan trọng nhất trong năm đầu đời: 6in1, Phế cầu Synflorix/Prevenar 13, Rota vi-rút, Cúm, Sởi.',
 N'<p>Cam kết vắc-xin nhập khẩu chính hãng từ Bỉ, Pháp, Mỹ. Bảo quản hệ thống dây chuyền lạnh GSP đạt chuẩn quốc tế.</p><h5>Đặc quyền khi đặt gói:</h5><ul><li>Giữ nguyên liều vắc-xin suốt năm không lo khan hiếm hay tăng giá.</li><li>Bác sĩ khám sàng lọc miễn phí trước mỗi mũi tiêm.</li><li>Nhắc lịch tiêm tự động qua SMS và email.</li></ul>',
 1, 5500000, 4800000, 30, 1, 'Active'),

(N'Khám và tư vấn phác đồ dinh dưỡng cho trẻ biếng ăn, chậm lớn', 'https://images.unsplash.com/photo-1584473457406-6240486418e9?w=600', 11,
 N'Đo mật độ khoáng chất, phân tích khẩu phần ăn hàng ngày và lập thực đơn cá nhân hóa cho từng bé.',
 N'<p>Giải quyết tận gốc tình trạng biếng ăn sinh lý, táo bón kéo dài hoặc suy dinh dưỡng thấp còi bằng phương pháp khoa học không lạm dụng kháng sinh hay thuốc bổ vô tội vạ.</p>',
 1, 500000, 400000, 40, 1, 'Active'),

(N'Nội soi và điều trị bệnh lý Tai - Mũi - Họng Nhi khoa', 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=600', 12,
 N'Sử dụng ống nội soi mềm siêu nhỏ chuyên dụng cho trẻ em, không gây đau rát hay khó chịu.',
 N'<p>Chẩn đoán chính xác các bệnh lý: Viêm VA, viêm amidan, viêm tai giữa thanh dịch, dị vật mũi tai. Điều trị dứt điểm, hạn chế tối đa nguy cơ tái phát.</p>',
 1, 350000, 300000, 60, 0, 'Active');
GO

-- 6. DỮ LIỆU ĐẶT LỊCH HẸN KHÁM (RESERVATIONS)
DELETE FROM ReservationItems;
DELETE FROM Prescriptions;
DELETE FROM MedicalExaminations;
DELETE FROM Reservations;

SET IDENTITY_INSERT Reservations ON;

INSERT INTO Reservations (Id, CustomerId, StaffId, TotalCost, Status, ReceiverName, ReceiverGender, ReceiverEmail, ReceiverMobile, ReceiverAddress, CheckupTime, Notes, CreatedDate) VALUES
-- Lịch hẹn 1: Đã khám xong thành công (Success) -> Có hồ sơ khám bệnh & đơn thuốc
(1, 7, 3, 650000, 'Success', N'Bé Phạm Bảo An (Mẹ: Phạm Hoàng Nam)', 'Male', 'customer@childrencare.com', '0934567890', N'Căn 1205 Royal City, Thanh Xuân, Hà Nội', DATEADD(day, -2, GETDATE()), N'Bé 3 tuổi, khám sức khỏe tổng quát định kỳ', DATEADD(day, -3, GETDATE())),

-- Lịch hẹn 2: Đã được nhân viên duyệt (Approved) -> Đang chờ đến ngày khám
(2, 7, 3, 400000, 'Approved', N'Bé Phạm Gia Hưng', 'Male', 'customer@childrencare.com', '0934567890', N'Căn 1205 Royal City, Thanh Xuân, Hà Nội', DATEADD(day, 2, GETDATE()), N'Bé biếng ăn kéo dài, cần tư vấn thực đơn', DATEADD(hour, -5, GETDATE())),

-- Lịch hẹn 3: Vừa gửi yêu cầu (Submitted) -> Chờ Manager/Staff phân công bác sĩ
(3, 8, 4, 300000, 'Submitted', N'Bé Đặng Mai Chi', 'Female', 'khachhang2@gmail.com', '0934567891', N'Times City, Hai Bà Trưng, Hà Nội', DATEADD(day, 3, GETDATE()), N'Bé bị ho sổ mũi đêm, cần nội soi tai mũi họng', GETDATE()),

-- Lịch hẹn 4: Lịch bị hủy (Cancelled)
(4, 8, 4, 650000, 'Cancelled', N'Bé Đặng Mai Chi', 'Female', 'khachhang2@gmail.com', '0934567891', N'Times City, Hai Bà Trưng, Hà Nội', DATEADD(day, -10, GETDATE()), N'Bận việc gia đình nên xin phép hủy lịch', DATEADD(day, -12, GETDATE()));

SET IDENTITY_INSERT Reservations OFF;
GO

-- Chi tiết dịch vụ trong từng lịch hẹn (ReservationItems)
INSERT INTO ReservationItems (ReservationId, ServiceId, Quantity, UnitPrice) VALUES
(1, 1, 1, 650000), -- Lịch 1: Gói khám sức khỏe tổng quát
(2, 3, 1, 400000), -- Lịch 2: Tư vấn dinh dưỡng
(3, 4, 1, 300000), -- Lịch 3: Nội soi tai mũi họng
(4, 1, 1, 650000); -- Lịch 4: Khám tổng quát (hủy)
GO

-- 7. HỒ SƠ KHÁM BỆNH & ĐƠN THUỐC MẪU (Cho Lịch hẹn Id = 1)
SET IDENTITY_INSERT MedicalExaminations ON;
INSERT INTO MedicalExaminations (Id, ReservationId, ExaminationDate, DoctorId, Notes) VALUES
(1, 1, DATEADD(day, -2, GETDATE()), 3, N'Bé tỉnh táo, da niêm mạc hồng, thể trạng tốt. Họng hơi đỏ nhẹ do thời tiết chuyển mùa, tim phổi bình thường.');
SET IDENTITY_INSERT MedicalExaminations OFF;
GO

SET IDENTITY_INSERT Prescriptions ON;
INSERT INTO Prescriptions (Id, MedicalExaminationId, DoctorId, Diagnosis, Note) VALUES
(1, 1, 3, N'Viêm họng cấp thể nhẹ - Theo dõi tại nhà', N'Cho bé uống nhiều nước ấm, giữ ấm cổ họng ban đêm');
SET IDENTITY_INSERT Prescriptions OFF;
GO

INSERT INTO PrescriptionItems (PrescriptionId, MedicineName, Dosage, Quantity, Usage) VALUES
(1, N'Siro ho Astex (Chai 90ml)', N'5ml / lần', 2, N'Uống ngày 3 lần sau ăn sáng, trưa, tối'),
(1, N'Men vi sinh BioGaia Protectis', N'5 giọt / ngày', 1, N'Nhỏ trực tiếp vào miệng hoặc pha với sữa nguội'),
(1, N'Nước muối sinh lý kháng viêm Physiodose', N'1 ống / ngày', 10, N'Nhỏ mũi và vệ sinh họng ngày 2 lần');
GO

-- 8. GÓP Ý & ĐÁNH GIÁ (FEEDBACKS)
DELETE FROM Feedbacks;
INSERT INTO Feedbacks (CustomerId, ServiceId, RatedStar, Comment, Status) VALUES
(7, 1, 5, N'Bác sĩ Trịnh Văn Minh rất tận tâm và kiên nhẫn với các bé nhỏ. Phòng khám sạch sẽ, không có mùi cồn khó chịu. Bé nhà mình rất hợp tác.', 'Approved'),
(8, 3, 4, N'Tư vấn dinh dưỡng rất kỹ lưỡng, thực đơn dễ áp dụng với nguyên liệu quen thuộc. Sẽ tiếp tục đồng hành cùng trung tâm.', 'Approved'),
(7, 4, 5, N'Dụng cụ nội soi êm dịu, bé không hề giãy khóc như các bệnh viện khác. Rất hài lòng về chất lượng phục vụ.', 'Approved');
GO

-- 9. DANH SÁCH LIÊN HỆ & LỊCH SỬ TƯ VẤN (CONTACTS)
DELETE FROM ContactHistory;
DELETE FROM Contacts;

SET IDENTITY_INSERT Contacts ON;
INSERT INTO Contacts (Id, FullName, Email, Mobile, Address, Status, Notes) VALUES
(1, N'Hoàng Thị Ngọc', 'ngoc.hoang@gmail.com', '0978111222', N'Đống Đa, Hà Nội', 'New', N'Muốn tìm hiểu gói tiêm chủng vắc-xin cho bé 2 tháng tuổi'),
(2, N'Vũ Đình Khang', 'khang.vu@gmail.com', '0912999888', N'Thanh Xuân, Hà Nội', 'Contacted', N'Đã gọi điện tư vấn và hẹn lịch thứ 7 này qua khám dinh dưỡng');
SET IDENTITY_INSERT Contacts OFF;
GO

INSERT INTO ContactHistory (ContactId, StaffId, ActionType, Note) VALUES
(2, 2, 'Call', N'Nhân viên Manager gọi điện tư vấn gói khám dinh dưỡng trong 10 phút, khách hàng đồng ý');
GO

PRINT N'==================================================================';
PRINT N'  ĐÃ NẠP THÀNH CÔNG DỮ LIỆU TEST TOÀN DIỆN CHO CHILDREN CARE SYSTEM!';
PRINT N'  MẬT KHẨU TẤT CẢ TÀI KHOẢN: 123456';
PRINT N'==================================================================';

