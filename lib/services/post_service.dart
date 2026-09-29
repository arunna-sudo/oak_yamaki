import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

/// PostService จัดการ Firestore collection "community_posts" และ sub-collection "comments"
/// ทุกคนในหอพักอ่านและโพสต์/คอมเมนต์ได้ การลบควรจำกัดให้เจ้าของหรือแอดมินผ่าน Security Rules
class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _posts => _db.collection('community_posts');

  CollectionReference<Map<String, dynamic>> _comments(String postId) =>
      _posts.doc(postId).collection('comments');

  Stream<List<PostModel>> watchPosts({int limit = 100}) {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PostModel.fromJson(d.data(), d.id)).toList());
  }

  Future<void> createPost(PostModel post) async {
    await _posts.add(post.toJson());
  }

  /// ลบโพสต์พร้อมคอมเมนต์ทั้งหมดของโพสต์นั้น
  Future<void> deletePost(String postId) async {
    final comments = await _comments(postId).get();
    final batch = _db.batch();
    for (final doc in comments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_posts.doc(postId));
    await batch.commit();
  }

  Stream<List<CommentModel>> watchComments(String postId) {
    return _comments(postId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => CommentModel.fromJson(d.data(), d.id)).toList());
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    final batch = _db.batch();
    batch.set(_comments(postId).doc(), comment.toJson());
    batch.update(_posts.doc(postId), {'commentCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final batch = _db.batch();
    batch.delete(_comments(postId).doc(commentId));
    batch.update(_posts.doc(postId), {'commentCount': FieldValue.increment(-1)});
    await batch.commit();
  }
}
