import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/comment.dart';
import '../models/user.dart';
import '../services/comment_service.dart';
import '../widgets/comment_widget.dart';
import '../widgets/custom_font.dart';
import '../widgets/like_widget.dart';
import '../widgets/share_widget.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.userName,
    required this.postContent,
    required this.numOfLikes,
    required this.isLiked,
    required this.onLikePressed,
    required this.date,
    required this.currentUser,
    this.apiPostId,
    this.postImage,
    this.userAvatar,
  });

  final String userName;
  final String postContent;
  final String date;
  final int numOfLikes;
  final bool isLiked;
  final VoidCallback onLikePressed;
  final String? postImage;
  final String? userAvatar;
  final int? apiPostId;
  final User currentUser;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Comment>> _comments;
  late int likes;
  late bool isLiked;
  bool _isAddingComment = false;

  @override
  void initState() {
    super.initState();
    likes = widget.numOfLikes;
    isLiked = widget.isLiked;
    _comments = widget.apiPostId == null
        ? Future<List<Comment>>.value(const <Comment>[])
        : _commentService.getCommentsForPost(widget.apiPostId!);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentService.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      likes += isLiked ? -1 : 1;
      isLiked = !isLiked;
    });
    widget.onLikePressed();
  }

  ImageProvider<Object>? _imageProvider(String? source) {
    if (source == null || source.isEmpty) return null;
    return source.startsWith('http')
        ? NetworkImage(source)
        : AssetImage(source);
  }

  Widget _postImage(String source) {
    if (source.startsWith('http')) {
      return Image.network(
        source,
        width: double.infinity,
        height: ScreenUtil().setHeight(300),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }
    return Image.asset(
      source,
      width: double.infinity,
      height: ScreenUtil().setHeight(300),
      fit: BoxFit.cover,
    );
  }

  Future<void> _addComment() async {
    final postId = widget.apiPostId;
    final body = _commentController.text.trim();
    if (postId == null || body.isEmpty || _isAddingComment) return;
    setState(() => _isAddingComment = true);
    try {
      final addedComment = await _commentService.addComment(
        postId: postId,
        user: widget.currentUser,
        body: body,
      );
      final currentComments = await _comments;
      if (!mounted) return;
      _commentController.clear();
      setState(() {
        _comments = Future<List<Comment>>.value(<Comment>[
          ...currentComments,
          addedComment,
        ]);
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
    final postId = widget.apiPostId;
    if (postId == null) return;
    setState(() => _comments = _commentService.getCommentsForPost(postId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomFont(
          text: widget.userName,
          fontSize: ScreenUtil().setSp(20),
          color: Colors.black,
        ),
      ),
      body: Container(
        color: Colors.white,
        height: ScreenUtil().screenHeight,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (widget.postImage != null && widget.postImage!.isNotEmpty)
                _postImage(widget.postImage!),
              SizedBox(height: ScreenUtil().setHeight(20)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: ScreenUtil().setSp(25),
                      backgroundImage: _imageProvider(widget.userAvatar),
                      child: _imageProvider(widget.userAvatar) == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    SizedBox(width: ScreenUtil().setWidth(10)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CustomFont(
                          text: widget.userName,
                          fontSize: ScreenUtil().setSp(20),
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        Row(
                          children: <Widget>[
                            CustomFont(
                              text: '${widget.date} ·',
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.grey,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(3)),
                            Icon(
                              Icons.public,
                              color: Colors.grey,
                              size: ScreenUtil().setSp(15),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                ),
                alignment: Alignment.centerLeft,
                child: CustomFont(
                  text: widget.postContent,
                  fontSize: ScreenUtil().setSp(18),
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(30)),
              const Divider(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    LikeWidget(
                      numOfLikes: likes,
                      onPressed: _toggleLike,
                      isLiked: isLiked,
                    ),
                    CommentWidget(
                      onPressed: () => FocusScope.of(context).nextFocus(),
                    ),
                    const ShareWidget(),
                  ],
                ),
              ),
              if (widget.apiPostId != null) ...<Widget>[
                const Divider(),
                _commentsSection(),
                _commentComposer(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _commentsSection() {
    return FutureBuilder<List<Comment>>(
      future: _comments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text(snapshot.error.toString()),
                TextButton(
                  onPressed: _retryComments,
                  child: const Text('Retry comments'),
                ),
              ],
            ),
          );
        }
        final comments = snapshot.data ?? const <Comment>[];
        if (comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Be the first to comment.'),
          );
        }
        return Column(
          children: comments
              .map(
                (comment) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    comment.user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(comment.body),
                  trailing: comment.likes > 0
                      ? Text('👍 ${comment.likes}')
                      : null,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _commentComposer() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenUtil().setWidth(16),
        8,
        ScreenUtil().setWidth(8),
        ScreenUtil().setHeight(20),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: ScreenUtil().setSp(16),
            backgroundImage: _imageProvider(widget.currentUser.image),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _addComment(),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _isAddingComment ? null : _addComment,
            icon: _isAddingComment
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
