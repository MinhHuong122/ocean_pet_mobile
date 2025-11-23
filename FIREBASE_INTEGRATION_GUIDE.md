## 🔥 Hướng Dẫn Tích Hợp Firebase Services

### Các Services Mới Được Tạo

#### 1. **AppointmentService** (`lib/services/AppointmentService.dart`)
Quản lý đặt lịch khám sức khỏe, tiêm phòng, tắm và spa

**Các hàm chính:**
```dart
// Tạo lịch hẹn
AppointmentService.createAppointment(
  petId: 'pet_id',
  type: 'health_checkup', // 'vaccination', 'bath_spa', 'grooming'
  appointmentDate: DateTime.now(),
  appointmentTime: TimeOfDay(hour: 10, minute: 0),
  vetName: 'Dr. Smith',
  vetClinic: 'Pet Care Clinic',
  location: 'Address',
  notes: 'Notes',
  reminderTime: '1day',
  isRecurring: true,
  recurringCycle: 'monthly',
);

// Lấy danh sách lịch hẹn
AppointmentService.getAppointments(
  petId: 'pet_id',
  type: 'health_checkup',
  isUpcoming: true,
);

// Cập nhật lịch hẹn
AppointmentService.updateAppointment(appointmentId, {
  'status': 'completed',
  'notes': 'Updated notes',
});

// Hoàn thành/hủy lịch hẹn
AppointmentService.completeAppointment(appointmentId);
AppointmentService.cancelAppointment(appointmentId);

// Stream theo dõi lịch hẹn sắp tới
AppointmentService.watchUpcomingAppointments(petId).listen((appointments) {
  // Xử lý danh sách lịch hẹn
});
```

**Firestore Collection:** `appointments`
**Fields:**
- `user_id` - ID của người dùng
- `pet_id` - ID của thú cưng
- `type` - Loại lịch hẹn
- `appointment_date` - Ngày giờ lịch hẹn
- `vet_name` - Tên bác sĩ
- `vet_clinic` - Tên phòng khám
- `location` - Địa điểm
- `notes` - Ghi chú
- `status` - Trạng thái (scheduled, completed, cancelled)
- `reminder_time` - Thời gian nhắc nhở
- `is_recurring` - Có lặp lại không
- `recurring_cycle` - Chu kỳ lặp

---

#### 2. **UserProfileService** (`lib/services/UserProfileService.dart`)
Quản lý thông tin cá nhân người dùng

**Các hàm chính:**
```dart
// Lấy thông tin cá nhân
UserProfileService.getUserProfile();

// Cập nhật thông tin cá nhân
UserProfileService.updateUserProfile(
  name: 'John Doe',
  phoneNumber: '0912345678',
  address: '123 Street',
  bio: 'Pet lover',
  avatarUrl: 'https://...',
  gender: 'Male',
  dateOfBirth: DateTime(1990, 5, 15),
  city: 'Ho Chi Minh',
  district: 'District 1',
  ward: 'Ward 1',
);

// Cập nhật email
UserProfileService.updateEmail('newemail@example.com');

// Cập nhật mật khẩu
UserProfileService.updatePassword('currentPassword', 'newPassword');

// Xóa tài khoản
UserProfileService.deleteAccount('password');

// Stream theo dõi thay đổi thông tin
UserProfileService.watchUserProfile().listen((profile) {
  // Cập nhật UI
});

// Lấy thông tin công khai của người khác
UserProfileService.getPublicProfile(userId);

// Tìm kiếm người dùng
UserProfileService.searchUsers('John');
```

**Firestore Collection:** `users`
**Fields:**
- `uid` - ID Firebase Auth
- `name` - Tên
- `email` - Email
- `phone_number` - Số điện thoại
- `address` - Địa chỉ
- `bio` - Tiểu sử
- `avatar_url` - URL avatar
- `gender` - Giới tính
- `date_of_birth` - Ngày sinh
- `city` - Thành phố
- `district` - Quận
- `ward` - Phường

---

#### 3. **LostPetService** (`lib/services/LostPetService.dart`)
Quản lý bài đăng thú cưng thất lạc và tìm thấy

**Các hàm chính:**
```dart
// Đăng bài thú cưng thất lạc
LostPetService.createLostPetPost(
  petName: 'Bella',
  petType: 'dog', // 'cat', 'bird', 'other'
  breed: 'Golden Retriever',
  color: 'Golden',
  distinguishingFeatures: 'White patch on chest',
  imageUrl: 'https://...',
  lostDate: DateTime.now().subtract(Duration(days: 1)),
  lostLocation: 'District 1, HCMC',
  latitude: 10.762622,
  longitude: 106.660172,
  additionalNotes: 'Very friendly',
  phoneNumber: '0912345678',
  rewardAmount: '500000',
);

// Lấy danh sách thú cưng thất lạc
LostPetService.getLostPets(
  status: 'active',
  petType: 'dog',
  sortBy: 'recent', // 'distance'
  userLatitude: 10.762622,
  userLongitude: 106.660172,
);

// Lấy bài đăng của tôi
LostPetService.getMyLostPets();

// Đánh dấu đã tìm thấy
LostPetService.markAsFound(postId);

// Đóng bài đăng
LostPetService.closeLostPetPost(postId);

// Stream theo dõi bài đăng gần đây
LostPetService.watchNearbyLostPets(
  latitude: 10.762622,
  longitude: 106.660172,
  radiusKm: 50,
).listen((nearbyPets) {
  // Hiển thị bài đăng gần đây
});

// Đăng bài thú cưng tìm thấy
LostPetService.createFoundPetPost(
  description: 'Found a Golden dog',
  imageUrl: 'https://...',
  foundDate: DateTime.now(),
  foundLocation: 'District 1, HCMC',
  latitude: 10.762622,
  longitude: 106.660172,
);

// Lấy danh sách thú cưng tìm thấy
LostPetService.getFoundPets(status: 'active');
```

**Firestore Collections:**
- `lost_pets` - Thú cưng thất lạc
- `found_pets` - Thú cưng tìm thấy

**Lost Pets Fields:**
- `user_id` - ID người đăng
- `pet_name` - Tên thú cưng
- `pet_type` - Loại thú cưng
- `breed` - Giống loại
- `color` - Màu
- `distinguishing_features` - Đặc điểm
- `image_url` - Ảnh
- `lost_date` - Ngày thất lạc
- `lost_location` - Địa điểm thất lạc
- `latitude`, `longitude` - Tọa độ
- `status` - Trạng thái (active, found, closed)
- `views` - Lượt xem

---

#### 4. **CommunityService** (Đã tồn tại)
Quản lý bài viết, bình luận, thích trong cộng đồng

**Các hàm chính:**
```dart
// Tạo bài viết
CommunityService.createPost(
  title: 'Mẹo chăm sóc chó',
  content: 'Nội dung bài viết...',
  imageUrl: 'https://...',
);

// Lấy bài viết
CommunityService.getCommunityPosts();

// Bình luận
CommunityService.addComment(postId, 'Bình luận...');

// Thích
CommunityService.likePost(postId);
```

---

#### 5. **DatingService** (Đã tồn tại)
Quản lý hẹn hò thú cưng

**Các hàm chính:**
```dart
// Tạo hồ sơ dating
DatingService.createPetProfile(
  petName: 'Bella',
  breed: 'Golden Retriever',
  age: '2',
  gender: 'Female',
  location: 'HCMC',
  imageUrl: 'https://...',
  description: 'Mô tả...',
  interests: ['playing', 'swimming'],
);

// Xem hồ sơ
DatingService.getDiscoverProfiles();

// Thích/Ghét
DatingService.likePetProfile(targetPetId);
DatingService.dislikePetProfile(targetPetId);

// Kiểm tra match
DatingService.getMatches();

// Gửi tin nhắn
DatingService.sendMessage(conversationId, 'Nội dung tin nhắn');
```

---

### Cách Sử Dụng Trong Screen

#### **Ví dụ: appointment_detail_screen.dart**

```dart
import '../services/AppointmentService.dart';

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  
  Future<void> _saveAppointment() async {
    try {
      if (_selectedPetId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn thú cưng')),
        );
        return;
      }

      final appointmentId = await AppointmentService.createAppointment(
        petId: _selectedPetId!,
        type: _appointmentType, // 'health_checkup', 'vaccination', etc.
        appointmentDate: _selectedDate,
        appointmentTime: _selectedTime,
        vetName: _vetNameController.text,
        vetClinic: _vetClinicController.text,
        location: _locationController.text,
        notes: _notesController.text,
        reminderTime: _reminderTime,
        isRecurring: _isRecurring,
        recurringCycle: _recurringCycle,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lịch hẹn đã được lưu')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _loadUpcomingAppointments() async {
    try {
      final appointments = await AppointmentService.getAppointments(
        petId: _selectedPetId,
        isUpcoming: true,
      );

      setState(() {
        _upcomingAppointments = appointments;
      });
    } catch (e) {
      print('Error loading appointments: $e');
    }
  }
}
```

#### **Ví dụ: profile_detail_screen.dart**

```dart
import '../services/UserProfileService.dart';

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  
  Future<void> _updateProfile() async {
    try {
      await UserProfileService.updateUserProfile(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
        city: _selectedCity,
        district: _selectedDistrict,
        ward: _selectedWard,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thông tin đã được cập nhật')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserProfileService.getUserProfile();
      if (profile != null) {
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _phoneController.text = profile['phone_number'] ?? '';
          _addressController.text = profile['address'] ?? '';
          _bioController.text = profile['bio'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
}
```

#### **Ví dụ: lost_pet_screen.dart**

```dart
import '../services/LostPetService.dart';

class _LostPetScreenState extends State<LostPetScreen> {
  
  Future<void> _createLostPetPost() async {
    try {
      final postId = await LostPetService.createLostPetPost(
        petName: _petNameController.text,
        petType: _selectedPetType,
        breed: _breedController.text,
        color: _colorController.text,
        distinguishingFeatures: _featuresController.text,
        imageUrl: _selectedImageUrl!,
        lostDate: _lostDate,
        lostLocation: _locationController.text,
        latitude: _latitude,
        longitude: _longitude,
        phoneNumber: _phoneController.text,
        rewardAmount: _rewardController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bài đăng đã được tạo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNearbyLostPets();
  }

  void _loadNearbyLostPets() {
    LostPetService.watchNearbyLostPets(
      latitude: _userLatitude,
      longitude: _userLongitude,
      radiusKm: 50,
    ).listen((nearbyPets) {
      setState(() {
        _lostPets = nearbyPets;
      });
    });
  }
}
```

---

### Firestore Security Rules (Đã cập nhật)

Tất cả các collection đã được thêm vào `firestore.rules` với các quy tắc bảo mật phù hợp:
- `appointments` - Người dùng chỉ có thể truy cập lịch hẹn của họ
- `users` - Mỗi người chỉ có thể cập nhật thông tin của chính họ
- `lost_pets` - Công khai để tìm kiếm, nhưng chỉ chủ sở hữu mới có thể sửa/xóa
- `found_pets` - Công khai, người tạo có thể quản lý

---

### Hướng Tích Hợp Tiếp Theo

1. **Cập nhật các Screen hiện tại** để sử dụng các service mới
2. **Thêm thông báo Firebase Cloud Messaging** cho:
   - Nhắc nhở lịch hẹn sắp tới
   - Bài đăng thú cưng mới gần đây
   - Tin nhắn từ người khác
3. **Thêm Storage** để lưu hình ảnh thay vì chỉ URL
4. **Thêm Pagination** cho danh sách bài đăng/lịch hẹn

---

### Kiểm Tra Firebase Console

Trong Firebase Console, kiểm tra:
1. **Firestore Database** → Collections:
   - `appointments`
   - `users`
   - `lost_pets`
   - `found_pets`
   - `pets` (đã tồn tại)
   - `communities` (đã tồn tại)

2. **Security Rules** → Kiểm tra quy tắc trong `firestore.rules`

3. **Indexes** → Firebase sẽ tạo tự động nếu cần
