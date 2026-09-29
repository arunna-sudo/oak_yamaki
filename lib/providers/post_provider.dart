import 'dart:async';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/post_service.dart';
import 'loading_state_mixin.dart';

/// PostProvider: ฟังฟีดโพสต์แบบเรียลไทม์ และรวมคำสั่งโพสต์/คอมเมนต์/ลบ
class PostProvider extends ChangeNotifier with LoadingStateMixin {
  final PostService _service = PostService();
  StreamSubscription<List<PostModel>>? _subscription;

  List<PostModel> _posts = [];
  List<PostModel> get posts => _posts;

  bool _started = false;

  /// เรียกซ้ำได้อย่างปลอดภัย (ไม่ subscribe ซ้ำ)
  void start() {
    if (_started) return;
    _started = true;
    setLoading(true);
    _subscription?.cancel();
    _subscription = _service.watchPosts().listen((data) {
      _posts = data;
      setLoading(false);
    }, onError: (e) {
      setError(e.toString());
      setLoading(false);
    });
  }

  Stream<List<CommentModel>> watchComments(String postId) => _service.watchComments(postId);

  Future<bool> createPost({
    required String text,
    required List<String> imagesBase64,
    required UserModel author,
  }) async {
    try {
      await _service.createPost(PostModel(
        id: '',
        text: text.trim(),
        imagesBase64: imagesBase64,
        authorUid: author.uid,
        authorName: author.name,
        authorRoom: author.isAdmin ? '' : author.room,
        authorRole: author.role,
        createdAt: DateTime.now(),
      ));
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _service.deletePost(postId);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> addComment({
    required String postId,
    required String text,
    required UserModel author,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    try {
      await _service.addComment(
        postId,
        CommentModel(
          id: '',
          text: trimmed,
          authorUid: author.uid,
          authorName: author.name,
          authorRoom: author.isAdmin ? '' : author.room,
          authorRole: author.role,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await _service.deleteComment(postId, commentId);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
