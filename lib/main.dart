import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';
import 'providers/auth_provider.dart' as my_auth;
import 'providers/task_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';   // ✅ IMPORTANT
import 'screens/main_screen.dart';   // ✅ IMPORTANT
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase init ONLY
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Timezone
  tz.initializeTimeZones();

  // ✅ Notifications
  const androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  await notificationsPlugin.initialize(
    const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ),
  );

  // ✅ Status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const TaskMasterApp());
}

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
      ],
      child: Consumer2<ThemeProvider, my_auth.AuthProvider>(
        builder: (context, themeProvider, auth, _) {
          return MaterialApp(
            title: 'TaskMaster',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
            themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

            // ✅ FIXED NAVIGATION LOGIC
            home: auth.isLoggedIn
                ? const MainScreen()   // if logged in → go to home
                : const LoginScreen(), // if not → show login
          );
        },
      ),
    );
  }
}