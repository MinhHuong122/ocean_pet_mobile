-- =============================================
-- OCEAN PET - Database Schema
-- MySQL/MariaDB
-- =============================================

-- Tạo database
CREATE DATABASE IF NOT EXISTS ocean_pet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ocean_pet;

-- =============================================
-- BẢNG USERS - Quản lý người dùng
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255),  -- NULL nếu đăng nhập qua OAuth
    avatar_url TEXT,
    provider ENUM('email', 'google', 'facebook') DEFAULT 'email',
    provider_id VARCHAR(255),  -- ID từ Google/Facebook
    is_verified BOOLEAN DEFAULT FALSE,
    otp_code VARCHAR(6),
    otp_expires_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_provider (provider, provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG PETS - Thông tin thú cưng
-- =============================================
CREATE TABLE IF NOT EXISTS pets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,  -- Mèo, Chó, Cá, Rắn, Rùa, Heo, Thỏ, Vẹt, Hamster
    breed VARCHAR(255),  -- Giống
    age INT,  -- Tuổi (tháng)
    weight DECIMAL(5,2),  -- Cân nặng (kg)
    gender ENUM('male', 'female', 'unknown') DEFAULT 'unknown',
    avatar_url TEXT,
    notes TEXT,  -- Ghi chú
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG FOLDERS - Thư mục nhật ký (từ pets đã chọn)
-- =============================================
CREATE TABLE IF NOT EXISTS folders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,  -- Tên thư mục (tên thú cưng)
    icon VARCHAR(50),  -- Icon đại diện
    color VARCHAR(20),  -- Màu sắc
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    UNIQUE KEY unique_user_folder (user_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG DIARY_ENTRIES - Nhật ký chăm sóc
-- =============================================
CREATE TABLE IF NOT EXISTS diary_entries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    folder_id INT,  -- Thư mục (thú cưng)
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category ENUM('Ăn uống', 'Sức khỏe', 'Vui chơi', 'Tắm rửa') NOT NULL,
    entry_date DATE NOT NULL,
    entry_time TIME NOT NULL,
    bg_color VARCHAR(20),  -- Màu nền
    has_password BOOLEAN DEFAULT FALSE,
    password VARCHAR(255),  -- Mật khẩu bảo vệ (đã hash)
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP NULL,  -- Thời gian xóa (vào thùng rác)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_folder_id (folder_id),
    INDEX idx_category (category),
    INDEX idx_is_deleted (is_deleted),
    INDEX idx_entry_date (entry_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG DIARY_IMAGES - Hình ảnh trong nhật ký
-- =============================================
CREATE TABLE IF NOT EXISTS diary_images (
    id INT PRIMARY KEY AUTO_INCREMENT,
    diary_entry_id INT NOT NULL,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (diary_entry_id) REFERENCES diary_entries(id) ON DELETE CASCADE,
    INDEX idx_diary_entry_id (diary_entry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG APPOINTMENTS - Lịch hẹn chăm sóc
-- =============================================
CREATE TABLE IF NOT EXISTS appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    pet_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    location VARCHAR(255),
    service_type ENUM('Khám sức khỏe', 'Tiêm phòng', 'Grooming', 'Huấn luyện', 'Khác') NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
    reminder_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_pet_id (pet_id),
    INDEX idx_appointment_date (appointment_date),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG HEALTH_RECORDS - Hồ sơ sức khỏe
-- =============================================
CREATE TABLE IF NOT EXISTS health_records (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pet_id INT NOT NULL,
    record_type ENUM('vaccination', 'checkup', 'medication', 'surgery', 'other') NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    veterinarian VARCHAR(255),
    clinic VARCHAR(255),
    record_date DATE NOT NULL,
    next_appointment_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
    INDEX idx_pet_id (pet_id),
    INDEX idx_record_type (record_type),
    INDEX idx_record_date (record_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG FEEDING_SCHEDULE - Lịch cho ăn
-- =============================================
CREATE TABLE IF NOT EXISTS feeding_schedule (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pet_id INT NOT NULL,
    meal_time TIME NOT NULL,
    food_type VARCHAR(255),
    quantity VARCHAR(100),  -- Số lượng (gram, ml...)
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
    INDEX idx_pet_id (pet_id),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- BẢNG NOTIFICATIONS - Thông báo
-- =============================================
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('appointment', 'feeding', 'health', 'general') NOT NULL,
    related_id INT,  -- ID của appointment, feeding, etc.
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- DỮ LIỆU MẪU (Sample Data)
-- =============================================

-- Thêm user mẫu
INSERT INTO users (name, email, password, provider, is_verified) VALUES
('Admin User', 'admin@oceanpet.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', 'email', TRUE),
('Nguyễn Văn A', 'nguyenvana@gmail.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', 'email', TRUE),
('Test User', 'test@oceanpet.com', '$2b$10$abcdefghijklmnopqrstuvwxyz123456', 'email', TRUE);

-- Thêm thú cưng mẫu
INSERT INTO pets (user_id, name, type, breed, age, weight, gender) VALUES
(2, 'Mochi', 'Chó', 'Poodle', 24, 5.5, 'female'),
(2, 'Miu Miu', 'Mèo', 'British Shorthair', 18, 4.2, 'female'),
(2, 'Nemo', 'Cá', 'Cá vàng', 6, 0.1, 'unknown');

-- Thêm thư mục mẫu (từ pets đã chọn)
INSERT INTO folders (user_id, name, icon, color) VALUES
(2, 'Chó', '🐕', '#8B5CF6'),
(2, 'Mèo', '🐱', '#EC4899'),
(2, 'Cá', '🐠', '#60A5FA');

-- Thêm nhật ký mẫu
INSERT INTO diary_entries (user_id, folder_id, title, description, category, entry_date, entry_time) VALUES
(2, 1, 'Mochi ăn sáng', 'Mochi đã ăn 100g thức ăn khô và uống nước', 'Ăn uống', '2025-09-17', '08:00:00'),
(2, 1, 'Tắm cho Mochi', 'Tắm và chải lông cho Mochi', 'Tắm rửa', '2025-09-17', '14:00:00'),
(2, 1, 'Khám sức khỏe định kỳ', 'Kiểm tra sức khỏe tổng quát tại phòng khám', 'Sức khỏe', '2025-09-15', '10:00:00'),
(2, 1, 'Chơi đùa ngoài trời', 'Mochi chơi với bóng và chạy nhảy 30 phút', 'Vui chơi', '2025-09-14', '17:00:00');

-- Thêm lịch hẹn mẫu
INSERT INTO appointments (user_id, pet_id, title, description, appointment_date, appointment_time, location, service_type, status) VALUES
(2, 1, 'Khám sức khỏe định kỳ', 'Kiểm tra tổng quát cho Mochi', '2025-09-20', '10:00:00', 'Phòng khám Pet Care', 'Khám sức khỏe', 'confirmed'),
(2, 1, 'Tiêm phòng dại ứng', 'Tiêm phòng bệnh dại cho Mochi', '2025-09-25', '14:00:00', 'Phòng khám Pet Care', 'Tiêm phòng', 'pending');

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- Procedure: Tự động xóa các entries trong thùng rác sau 30 ngày
DELIMITER //
CREATE PROCEDURE CleanupTrashedEntries()
BEGIN
    DELETE FROM diary_entries 
    WHERE is_deleted = TRUE 
    AND deleted_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
END //
DELIMITER ;

-- Procedure: Lấy tất cả nhật ký của user (không bao gồm đã xóa)
DELIMITER //
CREATE PROCEDURE GetUserDiaryEntries(IN p_user_id INT)
BEGIN
    SELECT 
        de.*,
        f.name as folder_name,
        GROUP_CONCAT(di.image_url) as images
    FROM diary_entries de
    LEFT JOIN folders f ON de.folder_id = f.id
    LEFT JOIN diary_images di ON de.id = di.diary_entry_id
    WHERE de.user_id = p_user_id 
    AND de.is_deleted = FALSE
    GROUP BY de.id
    ORDER BY de.entry_date DESC, de.entry_time DESC;
END //
DELIMITER ;

-- Procedure: Lấy entries trong thùng rác
DELIMITER //
CREATE PROCEDURE GetTrashedEntries(IN p_user_id INT)
BEGIN
    SELECT 
        de.*,
        DATEDIFF(DATE_ADD(de.deleted_at, INTERVAL 30 DAY), NOW()) as days_left
    FROM diary_entries de
    WHERE de.user_id = p_user_id 
    AND de.is_deleted = TRUE
    AND de.deleted_at > DATE_SUB(NOW(), INTERVAL 30 DAY)
    ORDER BY de.deleted_at DESC;
END //
DELIMITER ;

-- =============================================
-- EVENTS (Tự động chạy)
-- =============================================

-- Event: Tự động dọn dẹp thùng rác mỗi ngày
SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS daily_cleanup_trash
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 2 HOUR
DO
    CALL CleanupTrashedEntries();

-- =============================================
-- VIEWS
-- =============================================

-- View: Thống kê tổng quan của user
CREATE OR REPLACE VIEW user_statistics AS
SELECT 
    u.id as user_id,
    u.name,
    COUNT(DISTINCT p.id) as total_pets,
    COUNT(DISTINCT de.id) as total_diary_entries,
    COUNT(DISTINCT a.id) as total_appointments,
    COUNT(DISTINCT CASE WHEN de.entry_date = CURDATE() THEN de.id END) as today_entries
FROM users u
LEFT JOIN pets p ON u.id = p.user_id
LEFT JOIN diary_entries de ON u.id = de.user_id AND de.is_deleted = FALSE
LEFT JOIN appointments a ON u.id = a.user_id
GROUP BY u.id;

-- =============================================
-- INDEXES OPTIMIZATION
-- =============================================

-- Thêm indexes cho performance
CREATE INDEX idx_diary_user_date ON diary_entries(user_id, entry_date, is_deleted);
CREATE INDEX idx_appointments_user_date ON appointments(user_id, appointment_date, status);

-- =============================================
-- PERMISSIONS
-- =============================================

-- Tạo user cho backend application
-- CREATE USER 'ocean_pet_app'@'localhost' IDENTIFIED BY 'your_secure_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ocean_pet.* TO 'ocean_pet_app'@'localhost';
-- FLUSH PRIVILEGES;

-- =============================================
-- BACKUP REMINDER
-- =============================================
-- Nhớ backup database định kỳ:
-- mysqldump -u root -p ocean_pet > backup_ocean_pet_$(date +%Y%m%d).sql
