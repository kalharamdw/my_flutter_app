# 🚀 TaskMaster — Flutter App

A beautiful, fully-featured productivity app built with Flutter + Firebase + Claude AI.

## ✅ Features
-  Login (Email + Google Sign-In)
-  Firebase (Auth + Firestore cloud sync)
-  Task Manager (priorities, categories, swipe-to-delete)
-  Calendar View (tasks by date)
-  AI Assistant (Claude API chat)
-  Pomodoro Timer (work/break cycles)
-  Analytics (charts, completion rate, productivity score)
-  Reminders (local notifications)
-  Dark Mode (beautiful dark UI)
-  Offline-first (SQLite local + Firestore sync)

---

## 📁 Project Structure

```
lib/
├── main.dart                    
├── firebase_options.dart        
├── models/
│   └── task.dart                
├── providers/
│   ├── auth_provider.dart      
│   ├── task_provider.dart       
│   ├── pomodoro_provider.dart   
│   └── theme_provider.dart      
├── services/
│   ├── claude_service.dart      
│   ├── firestore_service.dart   
│   ├── local_db.dart            
│   └── notification_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── main_screen.dart         
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
    └── app_theme.dart           

android/
├── app/
│   ├── google-services.json     
│   ├── build.gradle
│   └── src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/com/taskmaster/app/MainActivity.kt
└── build.gradle
```


