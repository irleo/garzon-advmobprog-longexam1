import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../widgets/custom_font.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  late String buttonType;
  late Color fontColor, outlineColor;
  late dynamic onPressed;
  final String? buttonName;
  final Icon? icon;
  final Color? backgroundColor;

  CustomButton({
    super.key,
    this.buttonType = 'elevated',
    this.buttonName,
    this.fontColor = Colors.black,
    required this.onPressed,
    this.outlineColor = Colors.black,
    this.icon,
    this.backgroundColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    widget.buttonType = widget.buttonType.toLowerCase();
    if (widget.buttonType == 'outlined') {
      return OutlinedButton(
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(27),
            vertical: ScreenUtil().setHeight(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: widget.outlineColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) widget.icon!,
            if (widget.buttonName != null && widget.buttonName!.isNotEmpty) ...[
              if (widget.icon != null) SizedBox(width: 5),
              CustomFont(
                text: widget.buttonName!,
                color: widget.fontColor,
                fontSize: ScreenUtil().setSp(12),
              ),
            ],
          ],
        ),
      );
    } else if (widget.buttonType == 'text') {
      return TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(27),
            vertical: ScreenUtil().setHeight(10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) widget.icon!,
            if (widget.buttonName != null && widget.buttonName!.isNotEmpty) ...[
              if (widget.icon != null) SizedBox(width: 5),
              CustomFont(
                text: widget.buttonName!,
                color: widget.fontColor,
                fontSize: ScreenUtil().setSp(12),
              ),
            ],
          ],
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? FB_PRIMARY,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(27),
            vertical: ScreenUtil().setHeight(10)
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) widget.icon!,
            if (widget.buttonName != null && widget.buttonName!.isNotEmpty) ...[
              if (widget.icon != null) SizedBox(width: 5),
              CustomFont(
                text: widget.buttonName!,
                color: widget.fontColor,
                fontSize: ScreenUtil().setSp(12),
              ),
            ],
          ],
        ),
      );
    }
  }
}
