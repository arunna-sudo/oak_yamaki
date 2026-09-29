/// โพสต์ในคอมมูนิตี้หอพัก เก็บใน Firestore collection "community_posts"
/// รูปภาพเก็บเป็น base64 ใน field "images" (สูงสุด 3 รูป)
class PostModel {
  final String id;
  final String text;
  final List<String> imagesBase64;
  final String authorUid;
  final String authorName;
  final String authorRoom;
  final String authorRole; // 'admin' หรือ 'resident'
  final int commentCount;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.text,
    this.imagesBase64 = const [],
    required this.authorUid,
    required this.authorName,
    required this.authorRoom,
    required this.authorRole,
    this.commentCount = 0,
    required this.createdAt,
  });

  bool get isFromAdmin => authorRole == 'admin';

  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
    return PostModel(
      id: id,
      text: json['text'] ?? '',
      imagesBase64: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      authorUid: json['authorUid'] ?? '',
      authorName: json['authorName'] ?? 'ผู้ใช้',
      authorRoom: json['authorRoom'] ?? '',
      authorRole: json['authorRole'] ?? 'resident',
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'images': imagesBase64,
      'authorUid': authorUid,
      'authorName': authorName,
      'authorRoom': authorRoom,
      'authorRole': authorRole,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// คอมเมนต์ในโพสต์ เก็บใน sub-collection "community_posts/{postId}/comments"
class CommentModel {
  final String id;
  final String text;
  final String authorUid;
  final String authorName;
  final String authorRoom;
  final String authorRole;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorUid,
    required this.authorName,
    required this.authorRoom,
    required this.authorRole,
    required this.createdAt,
  });

  bool get isFromAdmin => authorRole == 'admin';

  factory CommentModel.fromJson(Map<String, dynamic> json, String id) {
    return CommentModel(
      id: id,
      text: json['text'] ?? '',
      authorUid: json['authorUid'] ?? '',
      authorName: json['authorName'] ?? 'ผู้ใช้',
      authorRoom: json['authorRoom'] ?? '',
      authorRole: json['authorRole'] ?? 'resident',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'authorUid': authorUid,
      'authorName': authorName,
      'authorRoom': authorRoom,
      'authorRole': authorRole,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
