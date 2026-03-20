# 🚀 TaskMaster — Flutter App

A beautiful, fully-featured productivity app built with Flutter + Firebase + Claude AI.

## ✅ Features
- 🔐 Login (Email + Google Sign-In)
- 🔥 Firebase (Auth + Firestore cloud sync)
- 📋 Task Manager (priorities, categories, swipe-to-delete)
- 📅 Calendar View (tasks by date)
- 🤖 AI Assistant (Claude API chat)
- 🍅 Pomodoro Timer (work/break cycles)
- 📊 Analytics (charts, completion rate, productivity score)
- ⏰ Reminders (local notifications)
- 🌙 Dark Mode (beautiful dark UI)
- 💾 Offline-first (SQLite local + Firestore sync)

---

## 📁 Project Structure

```
lib/
├── main.dart                    ← Entry point
├── firebase_options.dart        ← ⚠️ Replace with your Firebase config
├── models/
│   └── task.dart                ← Task model + enums
├── providers/
│   ├── auth_provider.dart       ← Firebase Auth state
│   ├── task_provider.dart       ← Task CRUD + filtering
│   ├── pomodoro_provider.dart   ← Timer logic
│   └── theme_provider.dart      ← Dark/light toggle
├── services/
│   ├── claude_service.dart      ← Claude AI API calls
│   ├── firestore_service.dart   ← Firestore operations
│   ├── local_db.dart            ← SQLite database
│   └── notification_service.dart← Local notifications
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── main_screen.dart         ← Bottom navigation shell
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── add_task_screen.dart
│   ├── task_detail_screen.dart
│   ├── calendar_screen.dart
│   ├── ai_screen.dart
│   ├── pomodoro_screen.dart
│   └── analytics_screen.dart
├── widgets/
│   ├── task_tile.dart
│   └── stat_card.dart
└── utils/
    └── app_theme.dart           ← Colors + theme config

android/
├── app/
│   ├── google-services.json     ← ⚠️ Replace with your Firebase file
│   ├── build.gradle
│   └── src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/com/taskmaster/app/MainActivity.kt
└── build.gradle
```

---

## ⚙️ STEP-BY-STEP SETUP

### STEP 1 — Install Flutter
If you don't have Flutter:
1. Download from https://flutter.dev/docs/get-started/install
2. Run: `flutter doctor` — fix any issues shown
3. Minimum Flutter version: **3.0.0**

---

### STEP 2 — Set Up Firebase

1. Go to https://console.firebase.google.com
2. Click **"Add project"** → Name it `TaskMaster`
3. Enable **Google Analytics** → Continue

**Add Android app:**
- Package name: `com.taskmaster.app`
- Download `google-services.json`
- Replace `android/app/google-services.json` with your downloaded file

**Enable Firebase services:**
- **Authentication** → Sign-in methods → Enable **Email/Password** AND **Google**
- **Firestore Database** → Create database → **Start in test mode** → choose region

**Get Web Client ID for Google Sign-In:**
1. Firebase Console → Project Settings → General → scroll down to "Your apps"
2. Copy the **Web Client ID** (ends in `.apps.googleusercontent.com`)
3. Open `android/app/src/main/res/values/strings.xml` and add:
```xml
<string name="default_web_client_id">YOUR_WEB_CLIENT_ID</string>
```
OR use the FlutterFire CLI (recommended, see Step 3).

---

### STEP 3 — Configure Flutter Firebase (FlutterFire CLI)

This is the EASIEST way to set up `firebase_options.dart` correctly:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In your project root:
flutterfire configure
```

Select your Firebase project → it auto-generates `lib/firebase_options.dart` with real values.

---

### STEP 4 — Add Claude API Key

1. Get your API key from https://console.anthropic.com
2. Open `lib/services/claude_service.dart`
3. Replace:
```dart
static const _apiKey = 'YOUR_CLAUDE_API_KEY_HERE';
```
with your real key.

---

### STEP 5 — Install Dependencies

```bash
cd TaskMaster_Flutter
flutter pub get
```

---

### STEP 6 — Run the App

```bash
# Check connected devices
flutter devices

# Run on Android
flutter run

# Run on iOS (Mac only)
flutter run -d ios

# Run in debug mode
flutter run --debug
```

---

## 🛠️ Common Issues & Fixes

| Error | Fix |
|-------|-----|
| `firebase_options.dart` has placeholder values | Run `flutterfire configure` |
| Google Sign-In fails | Add Web Client ID (Step 2) or run flutterfire configure |
| `MissingPluginException` | Run `flutter clean && flutter pub get`, restart app |
| Notification not working on Android 13+ | Grant notification permission in device settings |
| `PigeonUserDetails` error | Run `flutter clean && flutter pub get` |
| Build fails on Android | Ensure `minSdkVersion 23` in `android/app/build.gradle` |
| `Outfit font not found` | App uses Google Fonts package — no manual font files needed! |

---

## 🎨 Key Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_auth` | Authentication |
| `cloud_firestore` | Cloud database |
| `google_sign_in` | Google OAuth |
| `provider` | State management |
| `sqflite` | Local SQLite database |
| `google_fonts` | Outfit font (no files needed!) |
| `fl_chart` | Bar + pie charts |
| `table_calendar` | Calendar view |
| `flutter_local_notifications` | Reminders |
| `http` | Claude AI API calls |

---

## 📱 Minimum Requirements
- Android 6.0+ (API 23+)
- iOS 12.0+
- Flutter 3.0+
- Internet for Firebase + AI features

---

## 🔑 Things to Replace Before Running

| File | What to Replace |
|------|----------------|
| `android/app/google-services.json` | Your real Firebase file |
| `lib/firebase_options.dart` | Run `flutterfire configure` |
| `lib/services/claude_service.dart` | Your Claude API key |

---

*Built with Flutter 💙, Firebase 🔥, and Claude AI 🤖*
