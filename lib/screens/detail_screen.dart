import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/comment_service.dart';
import '../widgets/like_widget.dart';
import '../widgets/user_avatar.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.post,
    required this.author,
    required this.currentUser,
    required this.initialLikes,
    required this.initiallyLiked,
  });

  final Post post;
  final User author;
  final User currentUser;
  final int initialLikes;
  final bool initiallyLiked;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Comment>> _commentsFuture;
  late int _likes;
  late bool _isLiked;
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes;
    _isLiked = widget.initiallyLiked;
    _commentsFuture = _commentService.getCommentsForPost(widget.post.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentService.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
  }

  Future<void> _addComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _isAddingComment) return;
    setState(() => _isAddingComment = true);
    try {
      final comment = await _commentService.addComment(
        postId: widget.post.id,
        user: widget.currentUser,
        body: body,
      );
      final currentComments = await _commentsFuture;
      if (!mounted) return;
      _commentController.clear();
      setState(() {
        _commentsFuture = Future<List<Comment>>.value(
          <Comment>[...currentComments, comment],
        );
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to add comment: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingComment = false);
    }
  }

  void _retryComments() {
    setState(() {
      _commentsFuture = _commentService.getCommentsForPost(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                final comments = snapshot.data ?? const <Comment>[];
                return ListView(
                  padding: const EdgeInsets.only(bottom: 12),
                  children: <Widget>[
                    _PostDetails(
                      post: widget.post,
                      author: widget.author,
                      likes: _likes,
                      isLiked: _isLiked,
                      onLike: _toggleLike,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Text(
                        'Comments${comments.isEmpty ? '' : ' (${comments.length})'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (snapshot.hasError)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                            TextButton.icon(
                              onPressed: _retryComments,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry comments'),
                            ),
                          ],
                        ),
                      )
                    else if (comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Be the first to comment.')),
                      )
                    else
                      ...comments.map(
                        (comment) => ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                            comment.user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(comment.body),
                          trailing: comment.likes > 0
                              ? Text('👍 ${comment.likes}')
                              : null,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: <Widget>[
                  UserAvatar(imageUrl: widget.currentUser.image, radius: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(),
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isAddingComment ? null : _addComment,
                    icon: _isAddingComment
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostDetails extends StatelessWidget {
  const _PostDetails({
    required this.post,
    required this.author,
    required this.likes,
    required this.isLiked,
    required this.onLike,
  });

  final Post post;
  final User author;
  final int likes;
  final bool isLiked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                UserAvatar(imageUrl: author.image, radius: 25),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      author.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text('@${author.username} · Public'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(post.body),
            const Divider(height: 28),
            LikeWidget(
              numOfLikes: likes,
              isLiked: isLiked,
              onPressed: onLike,
            ),
          ],
        ),
      ),
    );
  }
}
