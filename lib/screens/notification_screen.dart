import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.notifications_none_rounded, size: 64),
            SizedBox(height: 12),
            Text(
              'No new notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              'DummyJSON does not expose a notifications resource.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
