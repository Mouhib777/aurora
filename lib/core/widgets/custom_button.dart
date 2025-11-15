import 'package:animate_do/animate_do.dart';
import 'package:aurora/core/services/image_getter/image_getter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/preferences/prefs_provider.dart';
import '../utils/color_utils.dart';

class AnotherButton extends ConsumerWidget {
  const AnotherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final imageGetterState = ref.watch(imageGetterProvider);
    final prefsState = ref.watch(preferencesNotifierProvider);

    return prefsState.offlineMode
        ? const SizedBox.shrink()
        : imageGetterState.isProcessing && !imageGetterState.isLoading
        ? FadeIn(
            key: const Key("value1"),
            child: Text(
              "Detecting colors...",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : (imageGetterState.isLoading == false &&
              imageGetterState.isProcessing == false)
        ? FadeIn(
            delay: const Duration(milliseconds: 500),
            key: const Key("value2"),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref
                    .read(imageGetterProvider.notifier)
                    .fetchRandomImageAndPalette();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 40.h,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : prefsState.bgColors[0],
                  borderRadius: BorderRadius.circular(7.r),
                ),
                child: Center(
                  child: Text(
                    "Another",
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : ColorUtils.getContrastingTextColor(
                              prefsState.bgColors[0],
                            ),
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
