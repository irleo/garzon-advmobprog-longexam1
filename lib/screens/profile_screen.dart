import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/newsfeed_screen.dart';
import '../constants.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_button.dart';
import '../models/user.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User get user => widget.user;

  Future<void> _openSettings() async {
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (_) => SettingsScreen(user: user)),
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://pbs.twimg.com/media/E159qBjXMAIKYpq.jpg",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.grey[400],
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: ScreenUtil().setWidth(15),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.image,
                                  width: ScreenUtil().setWidth(130),
                                  height: ScreenUtil().setWidth(130),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: ScreenUtil().setWidth(130),
                                    height: ScreenUtil().setWidth(130),
                                    color: Colors.grey[400],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: ScreenUtil().setWidth(130),
                                        height: ScreenUtil().setWidth(130),
                                        color: Colors.grey[400],
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(40)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomFont(
                          text: '${user.firstName} ${user.lastName}',
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(20),
                          color: Colors.black,
                        ),
                        Row(
                          children: [
                            CustomFont(
                              text: '200',
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(5)),
                            CustomFont(
                              text: 'followers',
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.grey,
                              fontWeight: FontWeight.w100,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(8)),
                            Transform.translate(
                              offset: Offset(0, -2),
                              child: Icon(
                                Icons.circle,
                                size: ScreenUtil().setSp(5),
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: ScreenUtil().setWidth(8)),
                            CustomFont(
                              text: '55',
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(5)),
                            CustomFont(
                              text: 'following',
                              fontSize: ScreenUtil().setSp(14),
                              color: Colors.grey,
                              fontWeight: FontWeight.w100,
                            ),
                          ],
                        ),
                        SizedBox(height: ScreenUtil().setHeight(12)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(0),
                          ),
                          child: Wrap(
                            spacing: ScreenUtil().setWidth(10),
                            runSpacing: ScreenUtil().setHeight(8),
                            children: [
                              CustomButton(
                                icon: Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.black,
                                ),
                                buttonName: 'Add to story',
                                onPressed: () {},
                              ),
                              CustomButton(
                                icon: Icon(
                                  Icons.create_rounded,
                                  color: Colors.black,
                                ),
                                buttonName: 'Edit Profile',
                                onPressed: () {},
                                buttonType: 'outlined',
                              ),
                              CustomButton(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Colors.black,
                                ),
                                onPressed: _openSettings,
                                buttonType: 'outlined',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  TabBar(
                    indicatorColor: FB_DARK_PRIMARY,
                    tabs: [
                      Tab(text: 'Posts'),
                      Tab(text: 'About'),
                      Tab(text: 'Photos'),
                    ],
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              NewsFeedScreen(
                currentUser: user,
                userId: user.id,
                showAds: false,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, size: 24, color: Colors.grey[700]),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bio',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '@${user.username}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(12)),
                      Row(
                        children: [
                          Icon(Icons.email, size: 24, color: Colors.grey[700]),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(12)),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 24,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                user.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(12)),
                      Row(
                        children: [
                          Icon(Icons.school, size: 24, color: Colors.grey[700]),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Education',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                user.university,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(12)),
                      Row(
                        children: [
                          Icon(Icons.person, size: 24, color: Colors.grey[700]),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gender',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                user.gender,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(12)),
                      Row(
                        children: [
                          Icon(Icons.cake, size: 24, color: Colors.grey[700]),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Birthday',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                user.birthDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      SizedBox(height: ScreenUtil().setHeight(2)),
                      GridView.builder(
                        itemCount: photoSources.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final src = photoSources[index];
                          final isNetwork = src.startsWith('http');

                          return InkWell(
                            onTap: () =>
                                customShowImageDialog(context, src: src),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isNetwork
                                  ? CachedNetworkImage(
                                      imageUrl: src,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.image),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                    )
                                  : Image.asset(src, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<String> photoSources = [
  'assets/images/photo1.jpg',
  'assets/images/photo2.jpg',
  'assets/images/photo3.jpg',
  'assets/images/photo4.png',
  'assets/images/higanbana.jpg',
  'assets/images/photo5.png',
  'https://cdn11.bigcommerce.com/s-1b9100svju/product_images/uploaded_images/all-about-lily-of-the-valley5.jpg',
  'https://floweraura-blog-img.s3.ap-south-1.amazonaws.com/Lotus.jpg',
  'https://www.newnessplant.com/uploads/8c9ade2529aa43042abf5ada4360b304.jpg',
];
