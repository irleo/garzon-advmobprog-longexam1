import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import '../widgets/user_avatar.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _postService.getPostsByUser(widget.user.id);
  }

  @override
  void dispose() {
    _postService.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() => _posts = _postService.getPostsByUser(widget.user.id));
  }

  Future<void> _openSettings() async {
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => SettingsScreen(user: widget.user),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open settings: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _posts,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? const <Post>[];
        return ListView(
          children: <Widget>[
            _ProfileHeader(user: widget.user, onSettings: _openSettings),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 4),
              child: Text(
                'Posts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: <Widget>[
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    TextButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (posts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('This user has no posts.')),
              )
            else
              ...posts.map(
                (post) => PostCard(
                  post: post,
                  author: widget.user,
                  currentUser: widget.user,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.onSettings});

  final User user;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Settings',
                onPressed: onSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ),
            UserAvatar(imageUrl: user.image, radius: 56),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text('@${user.username}'),
            const SizedBox(height: 18),
            _ProfileInformation(icon: Icons.email_outlined, value: user.email),
            _ProfileInformation(icon: Icons.phone_outlined, value: user.phone),
            _ProfileInformation(
              icon: Icons.school_outlined,
              value: user.university,
            ),
            _ProfileInformation(
              icon: Icons.location_on_outlined,
              value: user.address,
            ),
            _ProfileInformation(
              icon: Icons.cake_outlined,
              value: user.birthDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInformation extends StatelessWidget {
  const _ProfileInformation({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
