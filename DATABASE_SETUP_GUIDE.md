# 🗄️ Hướng dẫn Setup Database MySQL cho Ocean Pet

## 📋 Mục lục
1. [Cài đặt MySQL](#cài-đặt-mysql)
2. [Tạo Database](#tạo-database)
3. [Chạy Schema](#chạy-schema)
4. [Kiểm tra](#kiểm-tra)
5. [Troubleshooting](#troubleshooting)

---

## 1. Cài đặt MySQL

### Windows

#### Option 1: MySQL Installer (Khuyến nghị)
1. Download từ: https://dev.mysql.com/downloads/installer/
2. Chọn "MySQL Installer for Windows"
3. Chạy file installer và chọn "Full" installation
4. Thiết lập root password (nhớ password này!)
5. Hoàn tất cài đặt

#### Option 2: XAMPP
1. Download từ: https://www.apachefriends.org/
2. Cài đặt XAMPP
3. Khởi động MySQL từ XAMPP Control Panel

---

## 2. Tạo Database

### Cách 1: Sử dụng MySQL Workbench

1. Mở MySQL Workbench
2. Connect tới MySQL Server (localhost:3306)
3. Nhập root password
4. Chạy lệnh sau:

```sql
CREATE DATABASE ocean_pet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Cách 2: Sử dụng Terminal/Command Line

```bash
# Mở MySQL CLI
mysql -u root -p

# Nhập password

# Tạo database
CREATE DATABASE ocean_pet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Chọn database
USE ocean_pet;

# Exit
exit;
```

### Cách 3: Sử dụng phpMyAdmin (nếu dùng XAMPP)

1. Mở browser: http://localhost/phpmyadmin
2. Click "New" ở sidebar
3. Nhập tên database: `ocean_pet`
4. Chọn Collation: `utf8mb4_unicode_ci`
5. Click "Create"

---

## 3. Chạy Schema

### Option 1: MySQL Workbench

1. Mở file `database/schema.sql` trong MySQL Workbench
2. Click vào icon "Execute" (⚡) hoặc nhấn `Ctrl + Shift + Enter`
3. Chờ script chạy xong (khoảng 10-30 giây)

### Option 2: Command Line

```bash
# Di chuyển đến thư mục project
cd d:\dhv_assignments\DoAnChuyenNganh\ocean_pet

# Chạy schema.sql
mysql -u root -p ocean_pet < database\schema.sql

# Nhập password khi được yêu cầu
```

### Option 3: phpMyAdmin

1. Vào phpMyAdmin: http://localhost/phpmyadmin
2. Chọn database `ocean_pet`
3. Click tab "SQL"
4. Copy toàn bộ nội dung file `database/schema.sql`
5. Paste vào ô SQL và click "Go"

---

## 4. Kiểm tra

### Kiểm tra tables đã tạo

```sql
USE ocean_pet;
SHOW TABLES;
```

**Kết quả mong đợi:** (10 tables)
```
+----------------------+
| Tables_in_ocean_pet  |
+----------------------+
| appointments         |
| diary_entries        |
| diary_images         |
| feeding_schedule     |
| folders              |
| health_records       |
| notifications        |
| pet_folders          |
| pets                 |
| users                |
+----------------------+
```

### Kiểm tra sample data

```sql
-- Kiểm tra users
SELECT * FROM users;

-- Kiểm tra pets
SELECT * FROM pets;

-- Kiểm tra folders
SELECT * FROM folders;

-- Kiểm tra diary entries
SELECT * FROM diary_entries;
```

### Kiểm tra Events (Auto-cleanup)

```sql
-- Kiểm tra event scheduler có bật không
SHOW VARIABLES LIKE 'event_scheduler';

-- Nếu OFF, bật event scheduler
SET GLOBAL event_scheduler = ON;

-- Kiểm tra events đã tạo
SHOW EVENTS;
```

**Kết quả mong đợi:**
```
+------------+---------------------+----------+---------+
| Db         | Name                | Type     | Status  |
+------------+---------------------+----------+---------+
| ocean_pet  | daily_cleanup_trash | RECURRING| ENABLED |
+------------+---------------------+----------+---------+
```

---

## 5. Troubleshooting

### Lỗi: Access denied for user 'root'@'localhost'

**Nguyên nhân:** Password sai hoặc user không có quyền

**Giải pháp:**
```bash
# Reset root password
mysqladmin -u root password "new_password"

# Hoặc cấp quyền
GRANT ALL PRIVILEGES ON ocean_pet.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

---

### Lỗi: Unknown database 'ocean_pet'

**Nguyên nhân:** Database chưa được tạo

**Giải pháp:**
```sql
CREATE DATABASE ocean_pet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

### Lỗi: Table already exists

**Nguyên nhân:** Schema đã chạy trước đó

**Giải pháp:** Xóa database và tạo lại
```sql
DROP DATABASE ocean_pet;
CREATE DATABASE ocean_pet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ocean_pet;
SOURCE database/schema.sql;
```

---

### Lỗi: Event scheduler is OFF

**Nguyên nhân:** MySQL Event Scheduler chưa được bật

**Giải pháp:**
```sql
-- Bật tạm thời
SET GLOBAL event_scheduler = ON;

-- Bật vĩnh viễn: Thêm vào my.ini (Windows) hoặc my.cnf (Linux)
[mysqld]
event_scheduler=ON
```

---

### Lỗi: Cannot connect to MySQL

**Nguyên nhân:** MySQL service chưa chạy

**Giải pháp:**

**Windows:**
```bash
# Mở Services (Win + R → services.msc)
# Tìm "MySQL" → Right-click → Start

# Hoặc dùng command line
net start MySQL80
```

**XAMPP:**
- Mở XAMPP Control Panel
- Click "Start" bên cạnh MySQL

---

## 6. Kết nối từ Backend

Sau khi setup database xong, cấu hình file `.env` trong thư mục `backend`:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=ocean_pet
```

**Test connection:**

```bash
cd backend
npm install
npm run dev
```

Nếu thấy: `✅ Ocean Pet Server running on port 3000` → Kết nối thành công!

---

## 7. Database Tools Khuyến nghị

| Tool | Platform | Link | Ghi chú |
|------|----------|------|---------|
| **MySQL Workbench** | Windows/Mac/Linux | https://www.mysql.com/products/workbench/ | Official, full-featured |
| **phpMyAdmin** | Web-based | Included with XAMPP | Easy to use, web UI |
| **DBeaver** | Windows/Mac/Linux | https://dbeaver.io/ | Free, supports multiple DBs |
| **HeidiSQL** | Windows | https://www.heidisql.com/ | Lightweight, fast |

---

## 8. Maintenance Commands

```sql
-- Backup database
mysqldump -u root -p ocean_pet > backup.sql

-- Restore database
mysql -u root -p ocean_pet < backup.sql

-- Xem kích thước database
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'ocean_pet'
GROUP BY table_schema;

-- Optimize tables
OPTIMIZE TABLE users, pets, folders, diary_entries;
```

---

**✅ Setup hoàn tất! Giờ bạn đã sẵn sàng chạy backend server.**

**Bước tiếp theo:** Xem file `backend/README.md` để chạy server.
