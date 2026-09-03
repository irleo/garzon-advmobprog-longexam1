import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/post_card.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({
    super.key,
    required this.currentUser,
    this.userId,
    this.showAds = true,
  });

  final User currentUser;
  final int? userId;
  final bool showAds;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  static const int _adBlocksToShow = 4;
  static const int _postsPerAd = 2;

  final PostService _postService = PostService();
  final UserService _userService = UserService();
  late Future<_FeedData> _feed;

  @override
  void initState() {
    super.initState();
    _feed = _loadFeed();
  }

  Future<_FeedData> _loadFeed() async {
    final posts = widget.userId == null
        ? await _postService.getPosts(limit: 30)
        : await _postService.getPostsByUser(widget.userId!);
    final authorIds = posts.map((post) => post.userId).toSet();
    final authors = await Future.wait<User>(authorIds.map(_loadAuthor));
    return _FeedData(
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

  Future<void> _refresh() async {
    final refreshedFeed = _loadFeed();
    setState(() => _feed = refreshedFeed);
    try {
      await refreshedFeed;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to refresh posts: $error')),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  TextButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null || data.posts.isEmpty) {
          return const Center(child: Text('No posts available.'));
        }
        return _buildFeed(data);
      },
    );
  }

  Widget _buildFeed(_FeedData data) {
    final maxBlocks = data.posts.length ~/ _postsPerAd;
    final blocks = widget.showAds ? _adBlocksToShow.clamp(0, maxBlocks) : 0;
    final totalItems = data.posts.length + blocks;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          const cycleLength = _postsPerAd + 1;
          final isAdSlot =
              (index + 1) % cycleLength == 0 && (index ~/ cycleLength) < blocks;
          if (isAdSlot) return _adCarouselBlock();

          final adsBefore = index ~/ cycleLength;
          final post = data.posts[index - adsBefore];
          final author = data.authors[post.userId] ?? widget.currentUser;
          return PostCard(
            postId: post.postId.toString(),
            apiPostId: post.id,
            userName: author.fullName,
            postContent: '${post.title}\n\n${post.body}',
            numOfLikes: post.likes,
            isLiked: false,
            date: 'DummyJSON · Public',
            userAvatar: author.image,
            currentUser: widget.currentUser,
            commentAvatar: widget.currentUser.image,
          );
        },
      ),
    );
  }

  Widget _adCarouselBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Advertisement / Promotion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          CarouselSlider(
            options: CarouselOptions(
              height: 420,
              viewportFraction: 0.93,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              pageSnapping: true,
              scrollPhysics: const ClampingScrollPhysics(),
            ),
            items: _adPosts
                .map((ad) {
                  return PostCard(
                    postId: ad.postId,
                    userName: ad.userName,
                    postContent: ad.postContent,
                    numOfLikes: 0,
                    isLiked: false,
                    date: 'Sponsored',
                    userAvatar: ad.userAvatar,
                    postImage: ad.postImage,
                    isAds: true,
                    adsMarket: ad.market,
                    currentUser: widget.currentUser,
                    commentAvatar: widget.currentUser.image,
                    cardMargin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _FeedData {
  const _FeedData({required this.posts, required this.authors});

  final List<Post> posts;
  final Map<int, User> authors;
}

class _AdPost {
  const _AdPost({
    required this.postId,
    required this.userName,
    required this.postContent,
    required this.userAvatar,
    required this.postImage,
    required this.market,
  });

  final String postId;
  final String userName;
  final String postContent;
  final String userAvatar;
  final String postImage;
  final String market;
}

const List<_AdPost> _adPosts = <_AdPost>[
  _AdPost(
    postId: 'ad_1',
    userName: 'pongkan',
    postContent: 'Get foodborne disease updates near you.',
    userAvatar: 'assets/images/pongkan.jpg',
    postImage: 'assets/images/foodsafe_manila.png',
    market: 'Free alerts · Local updates',
  ),
  _AdPost(
    postId: 'ad_2',
    userName: 'Higanbana',
    postContent: 'GGEZ!',
    userAvatar: 'assets/images/higanbana.jpg',
    postImage: 'assets/images/post2.png',
    market: "It's play time!",
  ),
  _AdPost(
    postId: 'ad_3',
    userName: 'Lizu Besu',
    postContent: 'A quick escape by the sea.',
    userAvatar: 'assets/images/lizu_besu.jpg',
    postImage: 'assets/images/post4.jpg',
    market: 'Plan your next getaway',
  ),
];
