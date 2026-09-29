import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/pending_approval_page.dart';
import 'pages/home/main_shell.dart';
import 'pages/splash_page.dart';
import 'providers/announcement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/maintenance_provider.dart';
import 'providers/parcel_provider.dart';
import 'providers/post_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เตรียมข้อมูล locale ภาษาไทยสำหรับการจัดรูปแบบวันที่ (package intl)
  await initializeDateFormatting('th');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DormEaseApp());
}

class DormEaseApp extends StatelessWidget {
  const DormEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ใช้ Provider package เพื่อทำ State Management ตามที่สอนใน Lecture 7
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadSavedTheme()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
        ChangeNotifierProvider(create: (_) => ParcelProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DormEase - Hugo condo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// AuthGate คือ StatelessWidget ที่คอยฟังสถานะการล็อกอินจาก AuthProvider
/// แล้วสลับไปแสดงหน้าจอที่เหมาะสม: Splash -> Login -> MainShell (หลังล็อกอินสำเร็จ)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const SplashPage();
        }
        if (!auth.isLoggedIn) {
          return const LoginPage();
        }
        final profile = auth.userProfile;
        if (profile == null) {
          return const SplashPage();
        }
        // ผู้พักที่สมัครใหม่ต้องรอแอดมินยืนยันก่อนถึงจะเข้าแอปได้ (ยกเว้นแอดมิน)
        if (!profile.isApproved && !profile.isAdmin) {
          return const PendingApprovalPage();
        }
        return const MainShell();
      },
    );
  }
}
