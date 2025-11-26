-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AssetDB')
BEGIN
    CREATE DATABASE AssetDB;
END
GO

USE AssetDB;
GO

-- Create Assets Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Assets')
BEGIN
    CREATE TABLE Assets (
        Id INT PRIMARY KEY IDENTITY(1,1),
        Name NVARCHAR(255) NOT NULL,
        Category NVARCHAR(100),
        AssignedTo NVARCHAR(100),
        Status NVARCHAR(50),
        PurchaseDate DATETIME2
    );
END
GO

-- Create Tickets Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tickets')
BEGIN
    CREATE TABLE Tickets (
        Id INT PRIMARY KEY IDENTITY(1,1),
        Title NVARCHAR(255) NOT NULL,
        Category NVARCHAR(100),
        Priority NVARCHAR(50),
        Description NVARCHAR(MAX) NOT NULL,
        Status NVARCHAR(50) DEFAULT 'Open',
        SubmittedBy NVARCHAR(100),
        AdminNotes NVARCHAR(MAX),
        CreatedAt DATETIME2 DEFAULT GETDATE()
    );
END
GO

PRINT 'Database setup complete!';