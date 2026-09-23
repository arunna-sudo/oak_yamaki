import 'dart:async';
import 'package:flutter/material.dart';
import '../models/maintenance_model.dart';
import '../services/maintenance_service.dart';
import 'loading_state_mixin.dart';

class MaintenanceProvider extends ChangeNotifier with LoadingStateMixin {
  final MaintenanceService _service = MaintenanceService();
  StreamSubscription<List<MaintenanceModel>>? _subscription;

  List<MaintenanceModel> _requests = [];
  List<MaintenanceModel> get requests => _requests;

  void startForUser(String uid) {
    setLoading(true);
    _subscription?.cancel();
    _subscription = _service.watchMyRequests(uid).listen((data) {
      _requests = data;
      setLoading(false);
    }, onError: (e) {
      setError(e.toString());
      setLoading(false);
    });
  }

  void startForAdmin() {
    setLoading(true);
    _subscription?.cancel();
    _subscription = _service.watchAllRequests().listen((data) {
      _requests = data;
      setLoading(false);
    }, onError: (e) {
      setError(e.toString());
      setLoading(false);
    });
  }

  Future<bool> createRequest(MaintenanceModel request) async {
    final result = await runWithLoading(() async {
      await _service.createRequest(request);
      return true;
    });
    return result ?? false;
  }

  Future<void> updateStatus(String id, MaintenanceStatus status) async {
    await _service.updateStatus(id, status);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
