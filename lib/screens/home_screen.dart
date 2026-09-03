import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../widgets/custom_font.dart';

import '../screens/notification_screen.dart';
import '../screens/newsfeed_screen.dart';
import '../screens/profile_screen.dart';

import '../session/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<String> _titles;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final user = Session.authenticatedUser;

    _titles = ['pongkan', 'Notifications', user?.fullName ?? 'Profile'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: FB_TEXT_COLOR_WHITE,
        elevation: 2,
        title: CustomFont(
          text: _titles[_selectedIndex],
          fontSize: ScreenUtil().setSp(25),
          color: _selectedIndex == 0 ? FB_PRIMARY : Colors.black,
          fontFamily: 'Klavika',
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          if (Session.authenticatedUser case final user?)
            NewsFeedScreen(currentUser: user)
          else
            const SizedBox.shrink(),
          if (Session.authenticatedUser case final user?)
            NotificationScreen(currentUser: user)
          else
            const SizedBox.shrink(),
          if (Session.authenticatedUser case final user?)
            ProfileScreen(user: user)
          else
            const SizedBox.shrink(),
        ],
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: false,
        onTap: _onTappedBar,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: FB_PRIMARY,
        currentIndex: _selectedIndex,
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
