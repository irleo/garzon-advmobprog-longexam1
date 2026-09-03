class CommentAuthor {
  const CommentAuthor({
    required this.id,
    required this.username,
    required this.fullName,
  });

  final int id;
  final String username;
  final String fullName;

  factory CommentAuthor.fromJson(Map<String, dynamic> json) => CommentAuthor(
        id: (json['id'] as num?)?.toInt() ?? 0,
        username: json['username']?.toString() ?? 'user',
        fullName: json['fullName']?.toString() ??
            json['username']?.toString() ??
            'User',
      );
}

class Comment {
  const Comment({
    required this.id,
    required this.body,
    required this.postId,
    required this.likes,
    required this.user,
  });

  final int id;
  final String body;
  final int postId;
  final int likes;
  final CommentAuthor user;

  factory Comment.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return Comment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      body: json['body']?.toString() ?? '',
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      user: CommentAuthor.fromJson(
        userJson is Map<String, dynamic> ? userJson : <String, dynamic>{},
      ),
    );
  }
}
