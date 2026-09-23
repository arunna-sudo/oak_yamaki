import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/user_service.dart';
import 'loading_state_mixin.dart';

/// AuthProvider ทำหน้าที่เป็น "Controller" ตามแนวคิดใน Lecture 7:
/// - รับคำสั่งจากผู้ใช้ (login/register/logout)
/// - เรียกใช้ Service (AuthService, UserService) เพื่อทำงานจริง
/// - เก็บ State ของแอป (currentUser, userProfile, isLoading)
/// - แจ้งเตือน UI ให้ build ใหม่ผ่าน notifyListeners()
class AuthProvider extends ChangeNotifier with LoadingStateMixin {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final SecureStorageService _secureStorage = SecureStorageService();

  fb_auth.User? _firebaseUser;
  UserModel? _userProfile;
  bool _initialized = false;

  fb_auth.User? get firebaseUser => _firebaseUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isAdmin => _userProfile?.isAdmin ?? false;

  /// true เมื่อ Firebase ตรวจสอบสถานะ session เดิม (ถ้ามี) เสร็จเรียบร้อยแล้ว
  /// ใช้กำหนดว่าจะแสดงหน้า Splash รอ หรือแสดงหน้า Login/Home ได้แล้ว
  bool get initialized => _initialized;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(fb_auth.User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _userProfile = await _userService.getUserProfile(user.uid);
    } else {
      _userProfile = null;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String room,
  }) async {
    final result = await runWithLoading(() async {
      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final newUser = UserModel(
        uid: uid,
        email: email,
        name: name,
        phone: phone,
        room: room,
        role: 'resident',
        createdAt: DateTime.now(),
      );
      await _userService.createUserProfile(newUser);
      await _secureStorage.saveLoginSession(uid: uid, email: email);
      _userProfile = newUser;
      _firebaseUser = credential.user;
      return true;
    });
    return result ?? false;
  }

  Future<bool> login({required String email, required String password}) async {
    final result = await runWithLoading(() async {
      final credential = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      _userProfile = await _userService.getUserProfile(uid);
      _firebaseUser = credential.user;
      await _secureStorage.saveLoginSession(uid: uid, email: email);
      return true;
    });
    return result ?? false;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _secureStorage.clearLoginSession();
    _firebaseUser = null;
    _userProfile = null;
    notifyListeners();
  }

  String describeError(Object error) => _authService.describeError(error);
}
