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

-- Insert sample data into Assets
INSERT INTO Assets (Id, Name, Category, AssignedTo, Status, PurchaseDate)
VALUES
(1, 'Mandy', 'Laptop', 'John', 'Active', '2024-01-01 00:00:00.000'),
(5, 'David', 'Chair', 'Mary', 'Repair', '2025-11-14 00:00:00.000');
GO


-- Insert all tickets
INSERT INTO Tickets (Id, Title, Category, Priority, Description, Status, SubmittedBy, AdminNotes, CreatedAt)
VALUES
(1, 'Laptop not turning on', 'Hardware', 'Urgent', 'My work laptop won''t start. The power button does not respond at all. Need urgent help as I have a presentation today.', 'In Progress', 'user', NULL, '2025-11-24 20:33:18.650'),
(2, 'Need Microsoft Office installation', 'Software', 'Medium', 'I need Microsoft Office installed on my new computer. Specifically need Word, Excel, and PowerPoint for my department work.', 'In Progress', 'user', 'License key requested from IT admin', '2025-11-23 20:33:18.650'),
(3, 'Internet connection issues', 'Network', 'High', 'My computer keeps disconnecting from the office WiFi. Connection drops every 10-15 minutes. This is affecting my productivity.', 'Open', 'admin', NULL, '2025-11-24 17:33:18.650'),
(4, 'Cannot access shared drive', 'Access', 'Medium', 'I am unable to access the Finance shared drive. Getting "Access Denied" error. I need access to complete monthly reports.', 'Resolved', 'user', 'Access permissions granted by IT team', '2025-11-22 20:33:18.650'),
(5, 'Request for new keyboard', 'Request', 'Low', 'My current keyboard has several non-functioning keys. Would like to request a replacement wireless keyboard if possible.', 'Open', 'user', NULL, '2025-11-24 15:33:18.650'),
(6, 'Printer not working', 'Hardware', 'High', 'The office printer on 3rd floor is showing "Paper Jam" error but there is no paper stuck. Multiple employees are affected.', 'In Progress', 'admin', 'Technician dispatched to check printer', '2025-11-24 18:33:18.650'),
(7, 'Slow computer performance', 'Hardware', 'Medium', 'My computer has become very slow recently. It takes 5+ minutes to boot up and applications freeze frequently.', 'Open', 'user', NULL, '2025-11-23 20:33:18.650'),
(8, 'Email not syncing', 'Software', 'High', 'My Outlook email is not syncing properly. Not receiving new emails for the past 2 hours. Need urgent fix.', 'Resolved', 'user', 'Email server settings reconfigured. Issue resolved.', '2025-11-24 12:33:18.650'),
(9, 'VPN connection failed', 'Network', 'Urgent', 'Cannot connect to company VPN from home. Getting "Authentication failed" error. Need to access work files urgently.', 'In Progress', 'user', 'Checking VPN credentials and firewall settings', '2025-11-24 19:33:18.650'),
(10, 'Request for dual monitor setup', 'Request', 'Low', 'Would like to request an additional monitor for my workstation to improve productivity. Current single monitor setup is limiting.', 'Open', 'admin', NULL, '2025-11-21 20:33:18.650'),
(11, 'Software license expired', 'Software', 'Medium', 'Adobe Photoshop license has expired. Need renewal for design work. Department budget has been approved.', 'Closed', 'user', 'New license purchased and activated', '2025-11-19 20:33:18.650'),
(12, 'Mouse not working', 'Hardware', 'Low', 'Wireless mouse stopped working suddenly. Changed batteries but still not responding. Need replacement.', 'Resolved', 'user', 'Provided new wireless mouse', '2025-11-23 20:33:18.650');
GO

PRINT 'Tickets table populated successfully!';

PRINT 'Database setup complete!';