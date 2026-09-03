import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../widgets/custom_font.dart';

class CustomInformation extends StatelessWidget {
  final String name;
  final String post;
  final String description;
  final String? notificationIcon;
  final String? postId;
  final VoidCallback? onTap;

  const CustomInformation({
    super.key,
    required this.name,
    required this.post,
    required this.description,
    this.notificationIcon,
    this.postId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = notificationIcon == null || notificationIcon!.isEmpty
        ? null
        : notificationIcon!.startsWith('http')
        ? NetworkImage(notificationIcon!) as ImageProvider<Object>
        : AssetImage(notificationIcon!);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setSp(8),
          horizontal: ScreenUtil().setSp(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar != null
                ? CircleAvatar(
                    radius: ScreenUtil().setSp(25),
                    backgroundImage: avatar,
                  )
                : const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person, size: 28),
                  ),

            SizedBox(width: ScreenUtil().setWidth(10)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$name ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(14),
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: post,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: ScreenUtil().setSp(14),
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ScreenUtil().setHeight(4)),

                  CustomFont(
                    text: description,
                    fontSize: ScreenUtil().setSp(12),
                    color: FB_PRIMARY,
                    fontStyle: FontStyle.italic,
                  ),
                ],
              ),
            ),

            SizedBox(width: ScreenUtil().setWidth(5)),

            const Icon(Icons.more_horiz),
          ],
        ),
      ),
    );
  }
}
