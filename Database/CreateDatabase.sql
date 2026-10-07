-- =============================================
-- ERP System Database Script
-- SQL Server
-- =============================================

-- إنشاء قاعدة البيانات
CREATE DATABASE ERP_DB;
GO

USE ERP_DB;
GO

-- =============================================
-- جدول المستخدمين (Users)
-- =============================================
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Department NVARCHAR(50),
    Position NVARCHAR(50),
    Status NVARCHAR(20) DEFAULT 'Active', -- Active, Inactive
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME,
    LastPasswordChange DATETIME,
    IsAdmin BIT DEFAULT 0
);
GO

-- =============================================
-- جدول الأدوار والصلاحيات (Roles)
-- =============================================
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- =============================================
-- جدول ربط المستخدمين بالأدوار (UserRoles)
-- =============================================
CREATE TABLE UserRoles (
    UserRoleID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    RoleID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID) ON DELETE CASCADE,
    UNIQUE(UserID, RoleID)
);
GO

-- =============================================
-- جدول الفئات (Categories)
-- =============================================
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME
);
GO

-- =============================================
-- جدول المنتجات (Products)
-- =============================================
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductCode NVARCHAR(50) UNIQUE NOT NULL,
    ProductName NVARCHAR(150) NOT NULL,
    CategoryID INT,
    Description NVARCHAR(255),
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INT DEFAULT 0,
    MinimumStock INT DEFAULT 10,
    SupplierID INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME,
    CreatedBy INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

-- =============================================
-- جدول الموردين (Suppliers)
-- =============================================
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName NVARCHAR(100) NOT NULL,
    ContactPerson NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Address NVARCHAR(255),
    City NVARCHAR(50),
    Country NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME
);
GO

-- تحديث جدول المنتجات بالمورد
ALTER TABLE Products
ADD FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID);
GO

-- =============================================
-- جدول المبيعات (Sales)
-- =============================================
CREATE TABLE Sales (
    SalesID INT PRIMARY KEY IDENTITY(1,1),
    SalesCode NVARCHAR(50) UNIQUE NOT NULL,
    UserID INT NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL,
    CustomerPhone NVARCHAR(20),
    TotalAmount DECIMAL(12, 2) NOT NULL,
    Discount DECIMAL(10, 2) DEFAULT 0,
    TaxAmount DECIMAL(10, 2) DEFAULT 0,
    FinalAmount DECIMAL(12, 2) NOT NULL,
    SalesDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50), -- Cash, Card, Check
    Notes NVARCHAR(255),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- =============================================
-- جدول تفاصيل المبيعات (SalesDetails)
-- =============================================
CREATE TABLE SalesDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    SalesID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    SubTotal DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (SalesID) REFERENCES Sales(SalesID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =============================================
-- جدول المشتريات (Purchases)
-- =============================================
CREATE TABLE Purchases (
    PurchaseID INT PRIMARY KEY IDENTITY(1,1),
    PurchaseCode NVARCHAR(50) UNIQUE NOT NULL,
    SupplierID INT NOT NULL,
    UserID INT NOT NULL,
    TotalAmount DECIMAL(12, 2) NOT NULL,
    Discount DECIMAL(10, 2) DEFAULT 0,
    TaxAmount DECIMAL(10, 2) DEFAULT 0,
    FinalAmount DECIMAL(12, 2) NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(),
    PaymentStatus NVARCHAR(50) DEFAULT 'Pending', -- Pending, Paid, Partial
    Notes NVARCHAR(255),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- =============================================
-- جدول تفاصيل المشتريات (PurchaseDetails)
-- =============================================
CREATE TABLE PurchaseDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    PurchaseID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    SubTotal DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (PurchaseID) REFERENCES Purchases(PurchaseID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =============================================
-- جدول سجل العمليات (AuditLog)
-- =============================================
CREATE TABLE AuditLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    Action NVARCHAR(100),
    TableName NVARCHAR(100),
    RecordID INT,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    LogDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- =============================================
-- إدراج بيانات أولية
-- =============================================

-- إدراج أدوار افتراضية
INSERT INTO Roles (RoleName, Description) VALUES 
('Admin', 'مسؤول النظام'),
('Manager', 'مدير'),
('Accountant', 'محاسب'),
('Salesman', 'موظف مبيعات'),
('Inventory', 'مسؤول المخزون');
GO

-- إدراج مستخدم Admin (كلمة المرور: Admin123)
INSERT INTO Users (Username, Password, FullName, Email, Department, Position, IsAdmin, Status)
VALUES ('admin', '3D3EFC9F0D1F0D0C3F0D9F0D1F0D3F0D', 'Administrator', 'admin@erp.com', 'IT', 'System Administrator', 1, 'Active');
GO

-- إدراج المستخدم Admin في دور Admin
INSERT INTO UserRoles (UserID, RoleID) 
SELECT u.UserID, r.RoleID FROM Users u, Roles r 
WHERE u.Username = 'admin' AND r.RoleName = 'Admin';
GO

-- إدراج فئات افتراضية
INSERT INTO Categories (CategoryName, Description) VALUES 
('Electronics', 'المنتجات الإلكترونية'),
('Clothing', 'الملابس والأزياء'),
('Food', 'المواد الغذائية'),
('Furniture', 'الأثاث'),
('Office Supplies', 'أدوات المكتب');
GO

-- إدراج موردين افتراضيين
INSERT INTO Suppliers (SupplierName, ContactPerson, Email, Phone, City, Country) VALUES 
('Supplier A', 'Ahmed Hassan', 'supplier.a@email.com', '01012345678', 'Cairo', 'Egypt'),
('Supplier B', 'Fatima Mohamed', 'supplier.b@email.com', '01112345678', 'Alexandria', 'Egypt');
GO

-- =============================================
-- Indexes لتحسين الأداء
-- =============================================
CREATE INDEX IX_Users_Username ON Users(Username);
CREATE INDEX IX_Products_ProductCode ON Products(ProductCode);
CREATE INDEX IX_Sales_SalesDate ON Sales(SalesDate);
CREATE INDEX IX_Purchases_PurchaseDate ON Purchases(PurchaseDate);
CREATE INDEX IX_AuditLog_UserID ON AuditLog(UserID);
GO

PRINT 'تم إنشاء قاعدة البيانات بنجاح!';
