# Kiến trúc Firebase Authentication - Ocean Pet

## 📊 Sơ đồ tổng quan

```
┌─────────────────────────────────────────────────────────────┐
│                         USER                                 │
│                    (Người dùng)                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Nhấn "TIẾP TỤC VỚI GOOGLE"
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   LOGIN SCREEN                               │
│                 (login_screen.dart)                          │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  _loginWithGoogle()                                 │    │
│  │  - Gọi AuthService.loginWithGoogle()              │    │
│  │  - Hiển thị loading                                │    │
│  │  - Xử lý kết quả                                   │    │
│  └────────────┬───────────────────────────────────────┘    │
└───────────────┼──────────────────────────────────────────────┘
                │
                │ AuthService.loginWithGoogle()
                ▼
┌─────────────────────────────────────────────────────────────┐
│                    AUTH SERVICE                              │
│                  (AuthService.dart)                          │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  loginWithGoogle()                                  │    │
│  │  1. GoogleSignIn.signIn()          ─────┐          │    │
│  │  2. Lấy authentication tokens            │          │    │
│  │  3. Tạo Firebase credential              │          │    │
│  │  4. Firebase.signInWithCredential()      │          │    │
│  │  5. Lấy Firebase token                   │          │    │
│  │  6. Lưu vào SharedPreferences            │          │    │
│  └──────────────┬───────────────────────────┼─────────┘    │
└─────────────────┼───────────────────────────┼──────────────┘
                  │                           │
                  │                           │
        ┌─────────┴─────────┐    ┌───────────┴──────────┐
        ▼                   ▼    ▼                      ▼
┌───────────────┐   ┌──────────────────┐   ┌────────────────┐
│  Google       │   │  Firebase Auth   │   │ SharedPrefs    │
│  Sign-In      │   │  (Cloud)         │   │ (Local)        │
│               │   │                  │   │                │
│  - OAuth      │   │  - Xác thực      │   │  - auth_token  │
│  - Tokens     │   │  - Tạo user      │   │  - user_id     │
│  - User info  │   │  - Quản lý       │   │  - is_logged   │
└───────────────┘   └──────────────────┘   └────────────────┘
```

## 🔄 Luồng dữ liệu chi tiết

### 1. User Interaction Layer
```
LoginScreen (UI)
│
├── Nhấn nút Google → _loginWithGoogle()
├── Hiển thị loading (CircularProgressIndicator)
├── Nhận kết quả từ AuthService
│   ├── Success → Navigate to WelcomeScreen
│   └── Failure → Show SnackBar error
```

### 2. Service Layer
```
AuthService
│
├── loginWithGoogle()
│   ├── GoogleSignIn().signIn()
│   │   └── Returns: GoogleSignInAccount
│   │
│   ├── googleUser.authentication
│   │   └── Returns: accessToken, idToken
│   │
│   ├── GoogleAuthProvider.credential()
│   │   └── Creates: Firebase AuthCredential
│   │
│   ├── FirebaseAuth.signInWithCredential()
│   │   └── Returns: UserCredential
│   │
│   ├── user.getIdToken()
│   │   └── Returns: Firebase JWT token
│   │
│   └── saveLoginState()
│       └── Saves: token, userId to SharedPreferences
│
├── logout()
│   ├── Clear SharedPreferences
│   ├── FirebaseAuth.signOut()
│   └── GoogleSignIn().signOut()
```

### 3. Data Storage
```
SharedPreferences (Local)
├── auth_token: String (Firebase JWT)
├── user_id: String (Firebase UID)
└── is_logged_in: bool

Firebase Auth (Cloud)
├── Users collection
├── Token management
└── Session handling
```

## 🏗️ Kiến trúc Files

```
ocean_pet/
│
├── lib/
│   ├── main.dart
│   │   ├── Firebase.initializeApp() ← Khởi tạo Firebase
│   │   └── runApp(MyApp)
│   │
│   ├── services/
│   │   └── AuthService.dart
│   │       ├── loginWithGoogle()      ← Firebase Auth
│   │       ├── registerWithGoogle()   ← Firebase Auth
│   │       ├── loginWithFacebook()    ← Backend API
│   │       ├── login()                ← Backend API
│   │       ├── register()             ← Backend API
│   │       └── logout()               ← Firebase + Google
│   │
│   └── screens/
│       ├── login_screen.dart
│       │   └── _loginWithGoogle() → AuthService
│       │
│       └── register_screen.dart
│           └── _registerWithGoogle() → AuthService
│
├── android/
│   ├── app/
│   │   ├── google-services.json      ← Firebase config
│   │   └── build.gradle              ← Google services plugin
│   └── build.gradle                  ← Google services classpath
│
└── pubspec.yaml
    ├── firebase_core
    ├── firebase_auth
    └── google_sign_in
```

## 🔐 Security Flow

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │ Email/Password
       ▼
┌─────────────────────┐
│  Google OAuth      │
│  - Xác thực user   │ ← Secure (Google handles)
│  - Cấp tokens      │
└──────┬──────────────┘
       │ accessToken + idToken
       ▼
┌─────────────────────┐
│  Firebase Auth     │
│  - Verify tokens   │ ← Secure (Firebase handles)
│  - Create/login    │
│  - Issue JWT       │
└──────┬──────────────┘
       │ Firebase JWT token
       ▼
┌─────────────────────┐
│  Local Storage     │
│  - SharedPrefs     │ ← Secure on device
│  - Encrypted       │
└─────────────────────┘
```

## 📦 Data Models

### Google Sign-In Response
```dart
GoogleSignInAccount {
  email: "user@gmail.com",
  displayName: "John Doe",
  photoUrl: "https://...",
  id: "google_user_id"
}

GoogleSignInAuthentication {
  accessToken: "ya29.a0...",
  idToken: "eyJhbGc..."
}
```

### Firebase UserCredential
```dart
UserCredential {
  user: {
    uid: "firebase_uid_123",
    email: "user@gmail.com",
    displayName: "John Doe",
    photoURL: "https://...",
    emailVerified: true,
    isAnonymous: false
  },
  additionalUserInfo: {...},
  credential: {...}
}
```

### AuthService Response
```dart
{
  'success': true/false,
  'message': 'Đăng nhập thành công',
  'user': {
    'id': 'firebase_uid_123',
    'email': 'user@gmail.com',
    'name': 'John Doe',
    'photoUrl': 'https://...'
  }
}
```

## 🔄 State Management

```
App Launch
│
├── Check SharedPreferences
│   ├── is_logged_in = true
│   │   └── Navigate to WelcomeScreen
│   └── is_logged_in = false
│       └── Show OnboardingScreen → LoginScreen
│
Login Flow
│
├── User clicks Google Sign-In
├── setState: _isLoading = true
├── AuthService.loginWithGoogle()
├── Save to SharedPreferences
├── setState: _isLoading = false
└── Navigate to WelcomeScreen
```

## 🎯 Key Components Integration

```
┌─────────────────────────────────────────────────┐
│           Application Layer                      │
│                                                  │
│  ┌──────────────┐         ┌──────────────┐     │
│  │  UI Screens  │ ◄────── │  Navigation  │     │
│  │  - Login     │         │  - Routes    │     │
│  │  - Register  │         │  - Guards    │     │
│  │  - Welcome   │         └──────────────┘     │
│  └──────┬───────┘                               │
│         │                                        │
└─────────┼────────────────────────────────────────┘
          │
┌─────────┼────────────────────────────────────────┐
│         ▼       Service Layer                    │
│  ┌──────────────┐                                │
│  │ AuthService  │                                │
│  │ - Google     │                                │
│  │ - Facebook   │                                │
│  │ - Email      │                                │
│  └──────┬───────┘                                │
│         │                                        │
└─────────┼────────────────────────────────────────┘
          │
┌─────────┼────────────────────────────────────────┐
│         ▼       External Services                │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Firebase │  │  Google  │  │  Local   │      │
│  │   Auth   │  │ Sign-In  │  │ Storage  │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└──────────────────────────────────────────────────┘
```

## ⚙️ Configuration Dependencies

```
Firebase Project (Cloud)
│
├── Authentication
│   ├── Google Sign-In Provider ✓ Enabled
│   ├── Authorized domains
│   └── OAuth consent screen
│
├── Android App
│   ├── Package name: com.example.ocean_pet
│   ├── SHA-1 certificate
│   └── google-services.json
│
└── iOS App (optional)
    ├── Bundle ID: com.example.oceanPet
    └── GoogleService-Info.plist
```

## 🚀 Deployment Checklist

```
Development Environment
├── ✅ Firebase project created
├── ✅ Google Sign-In enabled
├── ✅ SHA-1 debug certificate added
├── ✅ google-services.json in place
├── ✅ Dependencies installed
└── ✅ Code updated

Production Environment
├── ⚠️ SHA-1 release certificate needed
├── ⚠️ Update google-services.json
├── ⚠️ Configure OAuth consent screen
├── ⚠️ Add production domains
└── ⚠️ Build release APK/Bundle
```

---

**Lưu ý:** Sơ đồ này mô tả kiến trúc hiện tại của Ocean Pet sau khi tích hợp Firebase Authentication cho Google Sign-In.
