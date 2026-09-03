import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import 'custom_font.dart';

class LikeWidget extends StatelessWidget {
  final int numOfLikes;
  final bool isLiked; // new
  final VoidCallback? onPressed;

  const LikeWidget({
    super.key,
    required this.numOfLikes,
    this.isLiked = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
        color: isLiked ? FB_DARK_PRIMARY : FB_DARK_PRIMARY, 
      ),
      label: CustomFont(
        text: numOfLikes.toString(),
        fontSize: ScreenUtil().setSp(12),
        color: FB_DARK_PRIMARY,
      ),
    );
  }
}

