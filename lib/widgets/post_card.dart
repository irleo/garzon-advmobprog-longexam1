import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../screens/detail_screen.dart';
import 'comment_widget.dart';
import 'like_widget.dart';
import 'share_widget.dart';
import 'user_avatar.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.author,
    required this.currentUser,
  });

  final Post post;
  final User author;
  final User currentUser;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _likes = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
  }

  Future<void> _openDetails() async {
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DetailScreen(
            post: widget.post,
            author: widget.author,
            currentUser: widget.currentUser,
            initialLikes: _likes,
            initiallyLiked: _isLiked,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open the post: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openDetails,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  UserAvatar(imageUrl: widget.author.image, radius: 23),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.author.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '@${widget.author.username} · Public',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.post.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(widget.post.body),
              if (widget.post.tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: widget.post.tags
                      .map(
                        (tag) => Text(
                          '#$tag',
                          style: const TextStyle(color: FB_DARK_PRIMARY),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LikeWidget(
                    numOfLikes: _likes,
                    isLiked: _isLiked,
                    onPressed: _toggleLike,
                  ),
                  CommentWidget(onPressed: _openDetails),
                  ShareWidget(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post link copied (demo).')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
