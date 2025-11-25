using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using ClosedXML.Excel;

var builder = WebApplication.CreateBuilder(args);

// ===== DATABASE CONNECTION =====
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=localhost;Database=AssetDB;Trusted_Connection=True;TrustServerCertificate=True;";

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

// ===== CORS =====
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowLocal", policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

var app = builder.Build();
app.UseCors("AllowLocal");

// ========== AUTH LOGIN (HARDCODED) ==========
app.MapPost("/api/login", (LoginDto login) =>
{
    if (login.Username == "admin" && login.Password == "admin123")
    {
        return Results.Ok(new { username = "admin", role = "Admin" });
    }
    if (login.Username == "user" && login.Password == "user123")
    {
        return Results.Ok(new { username = "user", role = "Normal" });
    }

    return Results.Unauthorized();
});

// ========== ASSETS CRUD ==========

// GET all assets
app.MapGet("/api/assets", async (AppDbContext db) =>
{
    return await db.Assets.ToListAsync();
});

// GET asset by ID
app.MapGet("/api/assets/{id}", async (int id, AppDbContext db) =>
{
    var asset = await db.Assets.FindAsync(id);
    return asset is null ? Results.NotFound() : Results.Ok(asset);
});

// CREATE asset
app.MapPost("/api/assets", async (Asset asset, AppDbContext db) =>
{
    db.Assets.Add(asset);
    await db.SaveChangesAsync();
    return Results.Created($"/api/assets/{asset.Id}", asset);
});

// UPDATE asset
app.MapPut("/api/assets/{id}", async (int id, Asset updated, AppDbContext db) =>
{
    var asset = await db.Assets.FindAsync(id);
    if (asset is null) return Results.NotFound();

    // update fields
    asset.Name = updated.Name;
    asset.Category = updated.Category;
    asset.AssignedTo = updated.AssignedTo;
    asset.Status = updated.Status;
    asset.PurchaseDate = updated.PurchaseDate;

    await db.SaveChangesAsync();
    return Results.NoContent();
});

// DELETE asset
app.MapDelete("/api/assets/{id}", async (int id, AppDbContext db) =>
{
    var asset = await db.Assets.FindAsync(id);
    if (asset is null) return Results.NotFound();

    db.Assets.Remove(asset);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

// ========== EXPORT EXCEL FILE ==========
app.MapGet("/api/assets/export", async (AppDbContext db) =>
{
    var assets = await db.Assets.ToListAsync();

    using var workbook = new XLWorkbook();
    var sheet = workbook.Worksheets.Add("Assets");

    // header row
    sheet.Cell(1, 1).Value = "Id";
    sheet.Cell(1, 2).Value = "Name";
    sheet.Cell(1, 3).Value = "Category";
    sheet.Cell(1, 4).Value = "AssignedTo";
    sheet.Cell(1, 5).Value = "Status";
    sheet.Cell(1, 6).Value = "PurchaseDate";

    // data rows
    for (int i = 0; i < assets.Count; i++)
    {
        var row = i + 2;
        var a = assets[i];
        sheet.Cell(row, 1).Value = a.Id;
        sheet.Cell(row, 2).Value = a.Name;
        sheet.Cell(row, 3).Value = a.Category;
        sheet.Cell(row, 4).Value = a.AssignedTo;
        sheet.Cell(row, 5).Value = a.Status;
        sheet.Cell(row, 6).Value = a.PurchaseDate?.ToString("yyyy-MM-dd");
    }

    using var stream = new MemoryStream();
    workbook.SaveAs(stream);
    stream.Position = 0;

    return Results.File(stream.ToArray(),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "assets.xlsx");
});

// ========== DASHBOARD ==========
app.MapGet("/api/dashboard", async (AppDbContext db) =>
{
    var total = await db.Assets.CountAsync();
    var assigned = await db.Assets.CountAsync(a => a.AssignedTo != null && a.AssignedTo != "");
    var unassigned = total - assigned;
    var needingRepair = await db.Assets.CountAsync(a => a.Status == "Repair" || a.Status == "Maintenance");

    return Results.Ok(new
    {
        total,
        assigned,
        unassigned,
        needingRepair
    });
});

app.Run();


// ==================== MODELS + DB CONTEXT ====================

public class Asset
{
    public int Id { get; set; }

    [Required]
    public string Name { get; set; } = "";

    public string? Category { get; set; }
    public string? AssignedTo { get; set; }
    public string? Status { get; set; }
    public DateTime? PurchaseDate { get; set; }
}

public class LoginDto
{
    public string Username { get; set; } = "";
    public string Password { get; set; } = "";
}

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    { }

    public DbSet<Asset> Assets => Set<Asset>();
}
