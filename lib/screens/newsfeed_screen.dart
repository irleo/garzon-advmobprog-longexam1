import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/post_card.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  late Future<_FeedData> _feed;

  @override
  void initState() {
    super.initState();
    _feed = _loadFeed();
  }

  Future<_FeedData> _loadFeed() async {
    try {
      final posts = await _postService.getPosts(limit: 30);
      final userIds = posts.map((post) => post.userId).toSet();
      final authors = await Future.wait<User>(
        userIds.map(_getAuthorOrFallback),
      );
      return _FeedData(
        posts: posts,
        authors: <int, User>{for (final author in authors) author.id: author},
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<User> _getAuthorOrFallback(int userId) async {
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

  Future<void> _refresh() async {
    final nextFeed = _loadFeed();
    setState(() => _feed = nextFeed);
    try {
      await nextFeed;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to refresh: $error')),
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
    return FutureBuilder<_FeedData>(
      future: _feed,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(message: snapshot.error.toString(), onRetry: _refresh);
        }
        final data = snapshot.data;
        if (data == null || data.posts.isEmpty) {
          return _ErrorState(
            message: 'No posts were returned by DummyJSON.',
            onRetry: _refresh,
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: data.posts.length,
            itemBuilder: (context, index) {
              final post = data.posts[index];
              final author = data.authors[post.userId] ?? widget.currentUser;
              return PostCard(
                post: post,
                author: author,
                currentUser: widget.currentUser,
              );
            },
          ),
        );
      },
    );
  }
}

class _FeedData {
  const _FeedData({required this.posts, required this.authors});

  final List<Post> posts;
  final Map<int, User> authors;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
