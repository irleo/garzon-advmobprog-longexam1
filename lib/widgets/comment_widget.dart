import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import 'custom_font.dart';

class CommentWidget extends StatelessWidget {
  final VoidCallback? onPressed;

  const CommentWidget({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.comment_outlined, 
        color: FB_DARK_PRIMARY
      ),
      label: CustomFont(
        text: 'Comment',
        fontSize: ScreenUtil().setSp(12),
        color: FB_DARK_PRIMARY,
      ),
    );
  }
}
