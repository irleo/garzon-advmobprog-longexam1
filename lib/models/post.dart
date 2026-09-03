class Post {
  const Post({
    required this.id,
    required this.postId,
    required this.userId,
    required this.title,
    required this.body,
    required this.likes,
    required this.dislikes,
    required this.views,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int postId;
  final int userId;
  final String title;
  final String body;
  final int likes;
  final int dislikes;
  final int views;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  factory Post.fromJson(Map<String, dynamic> json) {
    final reactionsJson = json['reactions'];
    final reactions = reactionsJson is Map<String, dynamic>
        ? reactionsJson
        : <String, dynamic>{};
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final tagsJson = json['tags'];

    return Post(
      id: id,
      postId: (json['postId'] as num?)?.toInt() ?? id,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      likes: (reactions['likes'] as num?)?.toInt() ??
          (json['likes'] as num?)?.toInt() ??
          0,
      dislikes: (reactions['dislikes'] as num?)?.toInt() ??
          (json['dislikes'] as num?)?.toInt() ??
          0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      tags: tagsJson is List
          ? tagsJson.map((tag) => tag.toString()).toList(growable: false)
          : const <String>[],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'postId': postId,
        'userId': userId,
        'title': title,
        'body': body,
        'reactions': <String, int>{'likes': likes, 'dislikes': dislikes},
        'views': views,
        'tags': tags,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
