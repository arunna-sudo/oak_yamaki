import 'dart:async';
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import 'loading_state_mixin.dart';

class AnnouncementProvider extends ChangeNotifier with LoadingStateMixin {
  final AnnouncementService _service = AnnouncementService();
  StreamSubscription<List<AnnouncementModel>>? _subscription;

  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> get announcements => _announcements;

  void start() {
    setLoading(true);
    _subscription?.cancel();
    _subscription = _service.watchAnnouncements().listen((data) {
      _announcements = data;
      setLoading(false);
    }, onError: (e) {
      setError(e.toString());
      setLoading(false);
    });
  }

  Future<bool> createAnnouncement({
    required String title,
    required String body,
    required String createdByName,
    required String createdByUid,
    bool pinned = false,
    String? imageBase64,
  }) async {
    final result = await runWithLoading(() async {
      await _service.createAnnouncement(AnnouncementModel(
        id: '',
        title: title,
        body: body,
        createdByName: createdByName,
        createdByUid: createdByUid,
        pinned: pinned,
        imageBase64: imageBase64,
        createdAt: DateTime.now(),
      ));
      return true;
    });
    return result ?? false;
  }

  Future<void> deleteAnnouncement(String id) async {
    await _service.deleteAnnouncement(id);
  }

  Future<void> togglePinned(String id, bool pinned) async {
    await _service.togglePinned(id, pinned);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
