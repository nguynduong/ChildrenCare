-- ===============================================================
-- CHILDREN CARE SYSTEM (CCS) DATABASE SCHEMA (SQL SERVER)
-- ===============================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ChildrenCareDB')
BEGIN
    CREATE DATABASE ChildrenCareDB;
END
GO

USE ChildrenCareDB;
GO

-- 1. BẢNG SETTINGS (Cấu hình hệ thống, Roles, Danh mục bài viết/dịch vụ)
IF OBJECT_ID('Settings', 'U') IS NULL
CREATE TABLE Settings (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(50) NOT NULL,              -- UserRole, PostCategory, ServiceCategory, AdminMenu
    Name NVARCHAR(100) NOT NULL,             -- Tên hiển thị
    Value NVARCHAR(255) NOT NULL,            -- Giá trị mã hóa hoặc URL menu
    Description NVARCHAR(500) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Inactive
    CONSTRAINT UQ_Settings_Type_Name UNIQUE (Type, Name)
);
GO

-- 2. BẢNG USERS (Tài khoản người dùng, nhân viên, quản trị)
IF OBJECT_ID('Users', 'U') IS NULL
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL DEFAULT 'Other', -- Male, Female, Other
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Mobile VARCHAR(10) NOT NULL,
    Address NVARCHAR(255) NULL,
    AvatarUrl NVARCHAR(255) NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    RoleId INT NOT NULL,                     -- FK Settings (Type = UserRole)
    Status NVARCHAR(20) NOT NULL DEFAULT 'Unverified', -- Unverified, Active, Inactive
    VerifyToken NVARCHAR(100) NULL,
    VerifyTokenExpiry DATETIME NULL,
    ResetToken NVARCHAR(100) NULL,
    ResetTokenExpiry DATETIME NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Role FOREIGN KEY (RoleId) REFERENCES Settings(Id)
);
GO

-- 3. BẢNG SLIDERS (Ảnh trượt trang chủ)
IF OBJECT_ID('Sliders', 'U') IS NULL
CREATE TABLE Sliders (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ImageUrl NVARCHAR(255) NOT NULL,
    BackLink NVARCHAR(500) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Inactive
    Notes NVARCHAR(500) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 4. BẢNG POSTS (Bài viết / Tin tức)
IF OBJECT_ID('Posts', 'U') IS NULL
CREATE TABLE Posts (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Thumbnail NVARCHAR(255) NOT NULL,
    CategoryId INT NOT NULL,                 -- FK Settings (PostCategory)
    AuthorId INT NOT NULL,                   -- FK Users
    BriefInfo NVARCHAR(500) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    IsFeatured BIT NOT NULL DEFAULT 0,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Hidden', -- Published, Hidden
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Posts_Category FOREIGN KEY (CategoryId) REFERENCES Settings(Id),
    CONSTRAINT FK_Posts_Author FOREIGN KEY (AuthorId) REFERENCES Users(Id)
);
GO

-- 5. BẢNG SERVICES (Gói dịch vụ khám & chăm sóc)
IF OBJECT_ID('Services', 'U') IS NULL
CREATE TABLE Services (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Thumbnail NVARCHAR(255) NOT NULL,
    CategoryId INT NOT NULL,                 -- FK Settings (ServiceCategory)
    BriefInfo NVARCHAR(500) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    NumberOfPerson INT NOT NULL DEFAULT 1,
    ListPrice DECIMAL(18,0) NOT NULL,
    SalePrice DECIMAL(18,0) NOT NULL,
    AvailableQuantity INT NOT NULL DEFAULT 0,
    IsFeatured BIT NOT NULL DEFAULT 0,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Inactive', -- Active, Inactive
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Services_Category FOREIGN KEY (CategoryId) REFERENCES Settings(Id),
    CONSTRAINT CK_Services_Price CHECK (SalePrice <= ListPrice AND SalePrice >= 0)
);
GO

-- 6. BẢNG SERVICE_IMAGES (Ảnh đính kèm dịch vụ)
IF OBJECT_ID('ServiceImages', 'U') IS NULL
CREATE TABLE ServiceImages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ServiceId INT NOT NULL,
    ImageUrl NVARCHAR(255) NOT NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_ServiceImages_Service FOREIGN KEY (ServiceId) REFERENCES Services(Id) ON DELETE CASCADE
);
GO

-- 7. BẢNG RESERVATIONS (Lịch hẹn / Đơn đặt lịch)
IF OBJECT_ID('Reservations', 'U') IS NULL
CREATE TABLE Reservations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NULL,                         -- Khách đăng nhập (hoặc NULL nếu khách vãng lai)
    ReservedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CheckupTime DATETIME NOT NULL,
    ReceiverFullName NVARCHAR(100) NOT NULL,
    ReceiverGender NVARCHAR(10) NOT NULL,
    ReceiverEmail NVARCHAR(100) NOT NULL,
    ReceiverMobile VARCHAR(10) NOT NULL,
    ReceiverAddress NVARCHAR(255) NULL,
    Notes NVARCHAR(500) NULL,
    TotalCost DECIMAL(18,0) NOT NULL DEFAULT 0,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Cart', -- Cart, Submitted, Success, Cancelled
    AssignedStaffId INT NULL,                -- FK Users (Doctor hoặc Nurse)
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Reservations_User FOREIGN KEY (UserId) REFERENCES Users(Id),
    CONSTRAINT FK_Reservations_Staff FOREIGN KEY (AssignedStaffId) REFERENCES Users(Id)
);
GO

-- 8. BẢNG RESERVATION_ITEMS (Chi tiết dịch vụ trong lịch hẹn)
IF OBJECT_ID('ReservationItems', 'U') IS NULL
CREATE TABLE ReservationItems (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL,
    ServiceId INT NOT NULL,
    UnitPrice DECIMAL(18,0) NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    NumberOfPerson INT NOT NULL DEFAULT 1,
    TotalCost DECIMAL(18,0) NOT NULL,
    CONSTRAINT FK_ReservationItems_Reservation FOREIGN KEY (ReservationId) REFERENCES Reservations(Id) ON DELETE CASCADE,
    CONSTRAINT FK_ReservationItems_Service FOREIGN KEY (ServiceId) REFERENCES Services(Id)
);
GO

-- 9. BẢNG CONTACTS (Khách hàng phục vụ tiếp thị)
IF OBJECT_ID('Contacts', 'U') IS NULL
CREATE TABLE Contacts (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Mobile VARCHAR(10) NOT NULL,
    Address NVARCHAR(255) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Contact', -- Contact, Potential, Customer
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 10. BẢNG CONTACT_HISTORIES (Lịch sử cập nhật thông tin khách hàng)
IF OBJECT_ID('ContactHistories', 'U') IS NULL
CREATE TABLE ContactHistories (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ContactId INT NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Mobile VARCHAR(10) NOT NULL,
    Address NVARCHAR(255) NULL,
    UpdatedBy INT NULL,                      -- FK Users
    UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_ContactHistories_Contact FOREIGN KEY (ContactId) REFERENCES Contacts(Id) ON DELETE CASCADE,
    CONSTRAINT FK_ContactHistories_User FOREIGN KEY (UpdatedBy) REFERENCES Users(Id)
);
GO

-- 11. BẢNG FEEDBACKS (Phản hồi / Đánh giá)
IF OBJECT_ID('Feedbacks', 'U') IS NULL
CREATE TABLE Feedbacks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Mobile VARCHAR(10) NOT NULL,
    ServiceId INT NULL,                      -- FK Services (NULL = phản hồi chung)
    RatedStar INT NOT NULL CHECK (RatedStar BETWEEN 1 AND 5),
    Content NVARCHAR(1000) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Published', -- Published, Hidden
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Feedbacks_Service FOREIGN KEY (ServiceId) REFERENCES Services(Id)
);
GO

-- 12. BẢNG FEEDBACK_IMAGES (Ảnh đính kèm phản hồi)
IF OBJECT_ID('FeedbackImages', 'U') IS NULL
CREATE TABLE FeedbackImages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FeedbackId INT NOT NULL,
    ImageUrl NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_FeedbackImages_Feedback FOREIGN KEY (FeedbackId) REFERENCES Feedbacks(Id) ON DELETE CASCADE
);
GO

-- 13. BẢNG MEDICAL_EXAMINATIONS (Hồ sơ khám bệnh)
IF OBJECT_ID('MedicalExaminations', 'U') IS NULL
CREATE TABLE MedicalExaminations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ReservationId INT NOT NULL UNIQUE,
    ExaminationDate DATETIME NOT NULL DEFAULT GETDATE(),
    DoctorId INT NOT NULL,
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT FK_MedicalExaminations_Reservation FOREIGN KEY (ReservationId) REFERENCES Reservations(Id),
    CONSTRAINT FK_MedicalExaminations_Doctor FOREIGN KEY (DoctorId) REFERENCES Users(Id)
);
GO

-- 14. BẢNG PRESCRIPTIONS (Đơn thuốc)
IF OBJECT_ID('Prescriptions', 'U') IS NULL
CREATE TABLE Prescriptions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    MedicalExaminationId INT NOT NULL,
    DoctorId INT NOT NULL,
    Diagnosis NVARCHAR(500) NOT NULL,
    Note NVARCHAR(500) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Prescriptions_Exam FOREIGN KEY (MedicalExaminationId) REFERENCES MedicalExaminations(Id) ON DELETE CASCADE,
    CONSTRAINT FK_Prescriptions_Doctor FOREIGN KEY (DoctorId) REFERENCES Users(Id)
);
GO

-- 15. BẢNG PRESCRIPTION_ITEMS (Chi tiết các loại thuốc trong đơn)
IF OBJECT_ID('PrescriptionItems', 'U') IS NULL
CREATE TABLE PrescriptionItems (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PrescriptionId INT NOT NULL,
    MedicineName NVARCHAR(150) NOT NULL,
    Dosage NVARCHAR(100) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Usage NVARCHAR(255) NULL,
    CONSTRAINT FK_PrescriptionItems_Prescription FOREIGN KEY (PrescriptionId) REFERENCES Prescriptions(Id) ON DELETE CASCADE
);
GO

-- ===============================================================
-- SEED DATA MẪU
-- ===============================================================

-- 5 Roles mặc định trong hệ thống
SET IDENTITY_INSERT Settings ON;
INSERT INTO Settings (Id, Type, Name, Value, Description, Status) VALUES
(1, 'UserRole', 'Customer', '1', N'Khách hàng đã đăng ký', 'Active'),
(2, 'UserRole', 'Doctor', '2', N'Bác sĩ nhi khoa', 'Active'),
(3, 'UserRole', 'Nurse', '3', N'Điều dưỡng / Y tá', 'Active'),
(4, 'UserRole', 'Manager', '4', N'Quản lý trung tâm', 'Active'),
(5, 'UserRole', 'Admin', '5', N'Quản trị viên hệ thống', 'Active'),
(6, 'PostCategory', N'Chăm sóc trẻ sơ sinh', '1', N'Các kiến thức về trẻ sơ sinh', 'Active'),
(7, 'PostCategory', N'Dinh dưỡng cho bé', '2', N'Thực đơn và chế độ ăn dặm', 'Active'),
(8, 'ServiceCategory', N'Khám tổng quát', '1', N'Gói khám sức khỏe định kỳ', 'Active'),
(9, 'ServiceCategory', N'Tiêm chủng vắc-xin', '2', N'Các mũi tiêm phòng theo độ tuổi', 'Active');
SET IDENTITY_INSERT Settings OFF;
GO

-- Tài khoản Admin & Manager mặc định (Mật khẩu: Admin@123 -> BCrypt hash)
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (Id, FullName, Gender, Email, Mobile, Address, PasswordHash, RoleId, Status) VALUES
(1, N'Quản Trị Viên', 'Male', 'admin@childrencare.com', '0912345678', N'Hà Nội', '$2a$10$wO0I7JqX6R4E17qA1F.2w.b3tG4V2.dF7F5bA3P6C9qP5F0a1K2eG', 5, 'Active'),
(2, N'Quản Lý Trung Tâm', 'Female', 'manager@childrencare.com', '0987654321', N'Hà Nội', '$2a$10$wO0I7JqX6R4E17qA1F.2w.b3tG4V2.dF7F5bA3P6C9qP5F0a1K2eG', 4, 'Active'),
(3, N'Bác Sĩ Nguyễn Văn A', 'Male', 'doctor@childrencare.com', '0901234567', N'Hà Nội', '$2a$10$wO0I7JqX6R4E17qA1F.2w.b3tG4V2.dF7F5bA3P6C9qP5F0a1K2eG', 2, 'Active'),
(4, N'Y Tá Trần Thị B', 'Female', 'nurse@childrencare.com', '0902345678', N'Hà Nội', '$2a$10$wO0I7JqX6R4E17qA1F.2w.b3tG4V2.dF7F5bA3P6C9qP5F0a1K2eG', 3, 'Active');
SET IDENTITY_INSERT Users OFF;
GO

