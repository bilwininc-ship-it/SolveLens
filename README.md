# 🎓 SolveLens - AI-Powered Homework Helper

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

**Premium AI Tutor Application with Gemini 2.5 Flash Integration**

</div>

---

## ✨ Features

### 🔐 Authentication
- ✅ **Google Sign-In** - One-tap authentication
- ✅ **Email/Password** - Traditional authentication
- ✅ **User Management** - Profile and preferences
- ✅ **Auto Login** - Persistent authentication state

### 🎨 Design
- ✅ **Premium Dark Theme** - Material Design 3
- ✅ **Deep Black (#000000)** - OLED-optimized
- ✅ **Gold Accents (#D4AF37)** - Luxury feel
- ✅ **Smooth Animations** - Polished user experience

### 📸 Core Features
- 📷 **Camera Integration** - Scan homework questions
- 🤖 **AI Solutions** - Powered by Gemini 2.5 Flash
- 📚 **Question History** - Track solved problems
- ⭐ **Premium Subscription** - Unlimited access
- 🎯 **Smart Recognition** - Advanced OCR

### 🏗️ Architecture
- ✅ **Clean Architecture** - Scalable and maintainable
- ✅ **Provider Pattern** - Efficient state management
- ✅ **Dependency Injection** - GetIt service locator
- ✅ **Repository Pattern** - Clean data layer

---

## 📱 Screenshots

<div align="center">

| Login Screen | Home Screen | Camera Screen | Subscription |
|:---:|:---:|:---:|:---:|
| 🔐 | 🏠 | 📸 | ⭐ |

</div>

---

## 🚀 Quick Start

### Prerequisites

```bash
# Flutter SDK
Flutter 3.0.0 or higher

# Development Environment
Android Studio / VS Code
Xcode (for iOS)

# Firebase Account
Google Account for Firebase Console
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/solvelens.git
cd solvelens
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```
See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.

4. **Run the app**
```bash
flutter run
```

---

## 📂 Project Structure

```
lib/
├── 🎯 core/                    # Core functionality
│   ├── constants/              # App-wide constants
│   ├── errors/                 # Error handling
│   ├── utils/                  # Utility functions
│   └── di/                     # Dependency injection
│
├── 💾 data/                    # Data layer
│   ├── models/                 # Data models
│   ├── repositories/           # Repository implementations
│   └── datasources/            # Remote & local data sources
│
├── 🎯 domain/                  # Domain layer (Business Logic)
│   ├── entities/               # Business entities
│   ├── repositories/           # Repository interfaces
│   └── usecases/               # Business use cases
│
├── 🎨 presentation/            # Presentation layer (UI)
│   ├── screens/                # App screens
│   │   ├── auth/               # Authentication screens
│   │   ├── home/               # Home screen
│   │   ├── camera/             # Camera screen
│   │   └── subscription/       # Subscription screen
│   ├── widgets/                # Reusable widgets
│   ├── providers/              # State management
│   └── theme/                  # App theme & styling
│
└── 🔧 services/                # Services
    ├── auth/                   # Authentication service
    ├── ai/                     # AI/Gemini service
    ├── payment/                # Payment service
    ├── user/                   # User service
    └── config/                 # Remote config service
```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** - UI framework
- **Material 3** - Design system
- **Provider** - State management

### Backend & Services
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Firebase Remote Config** - Feature flags
- **Google Generative AI** - Gemini 2.5 Flash
- **RevenueCat** - Subscription management

### Tools & Libraries
- **GetIt** - Dependency injection
- **Dartz** - Functional programming
- **Camera** - Image capture
- **Image Picker** - Gallery access
- **Flutter TeX** - LaTeX rendering
- **Google Mobile Ads** - Monetization

---

## 🔧 Configuration

### Android Configuration

**Minimum SDK:** 21 (Android 5.0 Lollipop)  
**Target SDK:** 34 (Android 14)  
**Compile SDK:** 34

Location: `android/app/build.gradle.kts`

### Firebase Setup

1. Create Firebase project
2. Add Android/iOS apps
3. Download config files
4. Enable Authentication methods
5. Create Firestore database

See detailed guide: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

### Environment Variables

Create `.env` file in project root:

```env
# Gemini AI
GEMINI_API_KEY=your_gemini_api_key

# RevenueCat
REVENUECAT_API_KEY=your_revenuecat_key

# Google Ads
ADMOB_APP_ID=your_admob_app_id
```

---

## 🎨 Theme Customization

### Color Palette

```dart
// Premium Dark Theme
Deep Black:     #000000
Slate Grey:     #121212
Dark Grey:      #1E1E1E
Accent Gold:    #D4AF37
Light Gold:     #E5C158
Pale Gold:      #F5E6C8

// Status Colors
Success Green:  #4CAF50
Error Red:      #E53935
Warning Orange: #FF9800
```

### Customize Theme

Edit `lib/presentation/theme/app_theme.dart`

---

## 📝 Development Guide

### Running Setup Script

**Windows (PowerShell):**
```powershell
.\setup_solvelens.ps1
```

This script creates:
- Clean Architecture folder structure
- Firebase configuration placeholders
- Documentation files
- Asset folders

### Adding New Features

1. **Create Use Case** in `domain/usecases/`
2. **Implement Repository** in `data/repositories/`
3. **Create Screen** in `presentation/screens/`
4. **Register Dependencies** in `core/di/service_locator.dart`

### State Management

```dart
// 1. Create Provider
class MyProvider extends ChangeNotifier {
  // State and methods
}

// 2. Register in main.dart
ChangeNotifierProvider(create: (_) => MyProvider())

// 3. Use in widgets
Consumer<MyProvider>(
  builder: (context, provider, child) {
    // Build UI
  }
)
```

---

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget

# Integration tests
flutter test test/integration
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🚀 Deployment

### Android (Google Play Store)

1. **Build Release APK**
```bash
flutter build apk --release
```

2. **Build App Bundle**
```bash
flutter build appbundle --release
```

3. **Upload to Play Console**
- Create app in Google Play Console
- Upload signed app bundle
- Complete store listing
- Submit for review

### iOS (App Store)

1. **Build iOS Archive**
```bash
flutter build ios --release
```

2. **Open Xcode**
```bash
open ios/Runner.xcworkspace
```

3. **Archive & Upload**
- Product → Archive
- Distribute App
- Upload to App Store

---

## 📊 Performance Optimization

### Build Optimizations

```gradle
// android/app/build.gradle.kts
buildTypes {
    release {
        minifyEnabled = true
        shrinkResources = true
        proguardFiles(...)
    }
}
```

### Image Optimization

- Use `.webp` format for images
- Optimize with `flutter_image_compress`
- Use `CachedNetworkImage` for remote images

---

## 🔐 Security

### API Keys

- Store in Remote Config (production)
- Use `.env` files (development)
- Never commit API keys to repository

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

- **Your Name** - Initial work - [YourGitHub](https://github.com/yourusername)

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Firebase for backend services
- Google Gemini for AI capabilities
- Material Design for design guidelines
- Open source community

---

## 📞 Support

For support and questions:

- 📧 Email: support@solvelens.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/solvelens/issues)
- 💬 Discord: [Join Community](https://discord.gg/solvelens)

---

## 🗺️ Roadmap

- [ ] Multi-language support
- [ ] Offline mode
- [ ] Social sharing
- [ ] Study groups
- [ ] Gamification
- [ ] Teacher dashboard
- [ ] Parent monitoring
- [ ] Video solutions

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repo if you find it helpful!

</div>
