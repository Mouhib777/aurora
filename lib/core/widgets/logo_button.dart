import 'package:aurora/core/config/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoButton extends StatelessWidget {
  final VoidCallback onPressed;
  const LogoButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: 50.h,
        width: 50.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(AppImages.logo, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
