import 'package:animate_do/animate_do.dart';
import 'package:aurora/core/config/app_images.dart';
import 'package:aurora/core/services/image_getter/image_getter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SquareImageWidget extends ConsumerWidget {
  const SquareImageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageGetterState = ref.watch(imageGetterProvider);
    final imageUrl = ref.watch(imageGetterProvider).imageUrl;

    return imageGetterState.isLoading
        ? FadeIn(
            duration: Duration(milliseconds: 300),
            child: Center(
              child: SizedBox(
                width: 300.w,
                height: 300.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.aurora),
                    SizedBox(height: 15.h),
                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.aurora),
                    SizedBox(height: 15.h),
                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: FadeIn(
                  child: Text(
                    "Something went wrong , please try again",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
