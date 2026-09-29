import 'dart:async';
import 'package:flutter/material.dart';
import '../models/parcel_model.dart';
import '../services/parcel_service.dart';
import 'loading_state_mixin.dart';

class ParcelProvider extends ChangeNotifier with LoadingStateMixin {
  final ParcelService _service = ParcelService();
  StreamSubscription<List<ParcelModel>>? _subscription;

  List<ParcelModel> _parcels = [];
  List<ParcelModel> get parcels => _parcels;

  List<ParcelModel> get pending =>
      _parcels.where((p) => p.status == ParcelStatus.pending).toList();
  List<ParcelModel> get received =>
      _parcels.where((p) => p.status == ParcelStatus.received).toList();

  void startForRoom(String room) {
    _parcels = [];
    if (room.trim().isEmpty) {
      _subscription?.cancel();
      setLoading(false);
      return;
    }
    _listen(_service.watchForRoom(room));
  }

  void startForAdmin() {
    _parcels = [];
    _listen(_service.watchAll());
  }

  void _listen(Stream<List<ParcelModel>> stream) {
    setLoading(true);
    _subscription?.cancel();
    _subscription = stream.listen((data) {
      _parcels = data;
      setLoading(false);
    }, onError: (e) {
      setError(e.toString());
      setLoading(false);
    });
  }

  Future<bool> addParcel({
    required String room,
    required String note,
    String? imageBase64,
  }) async {
    final result = await runWithLoading(() async {
      await _service.addParcel(ParcelModel(
        id: '',
        room: room,
        note: note,
        imageBase64: imageBase64,
        createdAt: DateTime.now(),
      ));
      return true;
    });
    return result ?? false;
  }

  Future<void> markReceived(String id) => _service.markReceived(id);

  Future<void> deleteParcel(String id) => _service.deleteParcel(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
