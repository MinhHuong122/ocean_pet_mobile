-- =============================================
-- OCEAN PET - Firebase Firestore Schema Reference
-- =============================================
-- Lưu ý: Firebase Firestore là NoSQL database, không dùng SQL.
-- File này chỉ để tham khảo cấu trúc dữ liệu sẽ được lưu trong Firestore.
-- Mỗi bảng dưới đây sẽ tương ứng với một Collection trong Firestore.
-- =============================================

-- =============================================
-- COLLECTION: users
-- Document ID: user.uid từ Firebase Auth
-- =============================================
/*
users/{userId} = {
    uid: string,                    // Firebase Auth UID
    name: string,
    email: string,
    avatar_url: string?,
    provider: 'email' | 'google' | 'facebook',
    provider_id: string?,
    is_verified: boolean,
    created_at: timestamp,
    updated_at: timestamp
}
*/

-- SQL tương đương (chỉ để tham khảo)
CREATE TABLE users_reference (
    uid VARCHAR(128) PRIMARY KEY,          -- Firebase Auth UID
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    avatar_url TEXT,
    provider ENUM('email', 'google', 'facebook') DEFAULT 'email',
    provider_id VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- COLLECTION: pets
-- Document ID: auto-generated
-- =============================================
/*
pets/{petId} = {
    id: string,                     // Auto-generated
    user_id: string,                // Reference to users/{userId}
    name: string,
    type: string,                   // 'Mèo', 'Chó', 'Cá', 'Rắn', 'Rùa', 'Heo', 'Thỏ', 'Vẹt', 'Hamster'
    breed: string?,
    age: number?,                   // Tuổi (tháng)
    weight: number?,                // Cân nặng (kg)
    gender: 'male' | 'female' | 'unknown',
    avatar_url: string?,
    notes: string?,
    created_at: timestamp,
    updated_at: timestamp
}

Indexes:
- user_id (ascending)
- type (ascending)
*/

-- SQL tương đương
CREATE TABLE pets_reference (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    breed VARCHAR(255),
    age INT,
    weight DECIMAL(5,2),
    gender ENUM('male', 'female', 'unknown') DEFAULT 'unknown',
    avatar_url TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- COLLECTION: folders
-- Document ID: auto-generated
-- =============================================
/*
folders/{folderId} = {
    id: string,
    user_id: string,                // Reference to users/{userId}
    name: string,
    icon: string,
    color: string,
    created_at: timestamp,
    updated_at: timestamp
}

Indexes:
- user_id (ascending)
*/

-- SQL tương đương
CREATE TABLE folders_reference (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- COLLECTION: diary_entries
-- Document ID: auto-generated
-- =============================================
/*
diary_entries/{entryId} = {
    id: string,
    user_id: string,                // Reference to users/{userId}
    folder_id: string?,             // Reference to folders/{folderId}
    title: string,
    description: string?,
    category: 'Ăn uống' | 'Sức khỏe' | 'Vui chơi' | 'Tắm rửa',
    entry_date: string,             // Format: 'YYYY-MM-DD'
    entry_time: string,             // Format: 'HH:mm:ss'
    bg_color: string?,
    has_password: boolean,
    password: string?,              // Hashed password
    images: string[],               // Array of image URLs
    is_deleted: boolean,
    deleted_at: timestamp?,
    created_at: timestamp,
    updated_at: timestamp
}

Indexes:
- user_id (ascending)
- folder_id (ascending)
- category (ascending)
- is_deleted (ascending)
- entry_date (descending)
*/

-- SQL tương đương
CREATE TABLE diary_entries_reference (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    folder_id VARCHAR(128),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category ENUM('Ăn uống', 'Sức khỏe', 'Vui chơi', 'Tắm rửa') NOT NULL,
    entry_date DATE NOT NULL,
    entry_time TIME NOT NULL,
    bg_color VARCHAR(20),
    has_password BOOLEAN DEFAULT FALSE,
    password VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- COLLECTION: appointments
-- Document ID: auto-generated
-- =============================================
/*
appointments/{appointmentId} = {
    id: string,
    user_id: string,                // Reference to users/{userId}
    pet_id: string?,                // Reference to pets/{petId}
    title: string,
    description: string?,
    appointment_date: string,       // Format: 'YYYY-MM-DD'
    appointment_time: string,       // Format: 'HH:mm:ss'
    location: string?,
    service_type: 'Khám sức khỏe' | 'Tiêm phòng' | 'Grooming' | 'Huấn luyện' | 'Khác',
    status: 'pending' | 'confirmed' | 'completed' | 'cancelled',
    reminder_sent: boolean,
    created_at: timestamp,
    updated_at: timestamp
}

Indexes:
- user_id (ascending)
- pet_id (ascending)
- appointment_date (ascending)
- status (ascending)
*/

-- SQL tương đương
CREATE TABLE appointments_reference (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    pet_id VARCHAR(128),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    location VARCHAR(255),
    service_type ENUM('Khám sức khỏe', 'Tiêm phòng', 'Grooming', 'Huấn luyện', 'Khác') NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
    reminder_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- COLLECTION: health_records
-- Document ID: auto-generated
-- =============================================
/*
health_records/{recordId} = {
    id: string,
    pet_id: string,                 // Reference to pets/{petId}
    record_type: 'vaccination' | 'checkup' | 'medication' | 'surgery' | 'other',
    title: string,
    description: string?,
    veterinarian: string?,
    clinic: string?,
    record_date: string,            // Format: 'YYYY-MM-DD'
    next_appointment_date: string?, // Format: 'YYYY-MM-DD'
    notes: string?,
    created_at: timestamp,
    updated_at: timestamp
}

Indexes:
- pet_id (ascending)
- record_type (ascending)
- record_date (descending)
*/

-- SQL tương đương
CREATE TABLE health_records_reference (
    id VARCHAR(128) PRIMARY KEY,
    pet_id VARCHAR(128) NOT NULL,
    record_type ENUM('vaccination', 'checkup', 'medication', 'surgery', 'other') NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    veterinarian VARCHAR(255),
    clinic VARCHAR(255),
    record_date DATE NOT NULL,
    next_appointment_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- COLLECTION: feeding_schedule
-- Document ID: auto-generated
-- =============================================
/*
feeding_schedule/{scheduleId} = {
    id: string,
    pet_id: string,                 // Reference to pets/{petId}
    meal_time: string,              // Format: 'HH:mm:ss'
    food_type: string?,
    quantity: string?,
    notes: string?,
    is_active: boolean,
    created_at: timestamp,
    updated_at: timestamp
}

Indexes:
- pet_id (ascending)
- is_active (ascending)
*/

-- SQL tương đương
CREATE TABLE feeding_schedule_reference (
    id VARCHAR(128) PRIMARY KEY,
    pet_id VARCHAR(128) NOT NULL,
    meal_time TIME NOT NULL,
    food_type VARCHAR(255),
    quantity VARCHAR(100),
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================
-- COLLECTION: notifications
-- Document ID: auto-generated
-- =============================================
/*
notifications/{notificationId} = {
    id: string,
    user_id: string,                // Reference to users/{userId}
    title: string,
    message: string,
    type: 'appointment' | 'feeding' | 'health' | 'general',
    related_id: string?,
    is_read: boolean,
    created_at: timestamp
}

Indexes:
- user_id (ascending)
- is_read (ascending)
- type (ascending)
- created_at (descending)
*/

-- SQL tương đương
CREATE TABLE notifications_reference (
    id VARCHAR(128) PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('appointment', 'feeding', 'health', 'general') NOT NULL,
    related_id VARCHAR(128),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- FIRESTORE SECURITY RULES
-- =============================================
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update, delete: if isOwner(userId);
    }
    
    // Pets collection
    match /pets/{petId} {
      allow read, write: if isAuthenticated() && 
                            resource.data.user_id == request.auth.uid;
      allow create: if isAuthenticated() && 
                       request.resource.data.user_id == request.auth.uid;
    }
    
    // Folders collection
    match /folders/{folderId} {
      allow read, write: if isAuthenticated() && 
                            resource.data.user_id == request.auth.uid;
      allow create: if isAuthenticated() && 
                       request.resource.data.user_id == request.auth.uid;
    }
    
    // Diary entries collection
    match /diary_entries/{entryId} {
      allow read, write: if isAuthenticated() && 
                            resource.data.user_id == request.auth.uid;
      allow create: if isAuthenticated() && 
                       request.resource.data.user_id == request.auth.uid;
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      allow read, write: if isAuthenticated() && 
                            resource.data.user_id == request.auth.uid;
      allow create: if isAuthenticated() && 
                       request.resource.data.user_id == request.auth.uid;
    }
    
    // Health records collection
    match /health_records/{recordId} {
      allow read, write: if isAuthenticated();
    }
    
    // Feeding schedule collection
    match /feeding_schedule/{scheduleId} {
      allow read, write: if isAuthenticated();
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read, write: if isAuthenticated() && 
                            resource.data.user_id == request.auth.uid;
      allow create: if isAuthenticated() && 
                       request.resource.data.user_id == request.auth.uid;
    }
  }
}
*/

-- =============================================
-- DỮ LIỆU MẪU (Sample Data for Testing)
-- =============================================
-- Trong Firebase, bạn có thể thêm dữ liệu mẫu qua Firebase Console
-- hoặc sử dụng code để seed data.

-- =============================================
-- MIGRATION NOTES
-- =============================================
/*
CHUYỂN ĐỔI TỪ MYSQL SANG FIREBASE:

1. Authentication:
   - MySQL: Lưu password đã hash trong bảng users
   - Firebase: Sử dụng Firebase Authentication (tự động quản lý)

2. Relationships:
   - MySQL: Foreign keys
   - Firebase: Lưu reference IDs (không có foreign key constraints)

3. Queries:
   - MySQL: JOIN queries
   - Firebase: Denormalization hoặc multiple queries

4. Transactions:
   - MySQL: ACID transactions
   - Firebase: Batch writes và transactions hỗ trợ

5. Images:
   - MySQL: Lưu URLs
   - Firebase: Sử dụng Firebase Storage, lưu download URLs trong Firestore

6. Real-time:
   - MySQL: Polling
   - Firebase: Real-time listeners (onSnapshot)

7. Offline Support:
   - MySQL: Không có
   - Firebase: Tự động cache offline

LỢI ÍCH KHI CHUYỂN SANG FIREBASE:
- Không cần backend server (Node.js/Express)
- Authentication tích hợp sẵn (Google, Facebook, Email)
- Real-time synchronization
- Offline support tự động
- Scalable infrastructure
- Security rules thay vì API authorization
- Firebase Storage cho images
- Free tier rộng rãi

CÁC BƯỚC THỰC HIỆN:
1. Tạo Firebase project
2. Enable Authentication (Email/Password, Google, Facebook)
3. Tạo Firestore database
4. Setup Security Rules
5. Enable Firebase Storage
6. Cập nhật Flutter code để sử dụng Firebase SDK
*/
