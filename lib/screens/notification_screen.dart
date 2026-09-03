import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_info.dart' as notification;
import 'detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  late Future<_NotificationData> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _loadNotifications();
  }

  Future<_NotificationData> _loadNotifications() async {
    final posts = await _postService.getPosts(limit: 15);
    final userIds = posts.map((post) => post.userId).toSet();
    final authors = await Future.wait<User>(userIds.map(_loadAuthor));
    return _NotificationData(
      posts: posts,
      authors: <int, User>{for (final author in authors) author.id: author},
    );
  }

  Future<User> _loadAuthor(int userId) async {
    if (userId == widget.currentUser.id) return widget.currentUser;
    try {
      return await _userService.getUser(userId);
    } catch (error) {
      return User(
        id: userId,
        firstName: 'DummyJSON',
        lastName: 'User $userId',
        username: 'user$userId',
        email: '',
        gender: '',
        image: '',
        phone: '',
        birthDate: '',
        university: '',
        address: '',
      );
    }
  }

  Future<void> _openPost(Post post, User author) async {
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DetailScreen(
            userName: author.fullName,
            postContent: '${post.title}\n\n${post.body}',
            date: 'DummyJSON · Public',
            numOfLikes: post.likes,
            isLiked: false,
            onLikePressed: () {},
            userAvatar: author.image,
            apiPostId: post.id,
            currentUser: widget.currentUser,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open notification: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _postService.dispose();
    _userService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_NotificationData>(
      future: _notifications,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final data = snapshot.data;
        if (data == null || data.posts.isEmpty) {
          return const Center(child: Text('No notifications.'));
        }
        return Container(
          color: Colors.white,
          width: ScreenUtil().screenWidth,
          padding: EdgeInsets.only(top: ScreenUtil().setSp(8)),
          child: ListView.separated(
            itemCount: data.posts.length,
            separatorBuilder: (_, _) => const Divider(height: 10),
            itemBuilder: (context, index) {
              final post = data.posts[index];
              final author = data.authors[post.userId] ?? widget.currentUser;
              return notification.CustomInformation(
                name: author.fullName,
                post: 'shared a new post: “${post.title}”',
                description: 'From DummyJSON',
                notificationIcon: author.image,
                postId: post.id.toString(),
                onTap: () => _openPost(post, author),
              );
            },
          ),
        );
      },
    );
  }
}

class _NotificationData {
  const _NotificationData({required this.posts, required this.authors});

  final List<Post> posts;
  final Map<int, User> authors;
}
