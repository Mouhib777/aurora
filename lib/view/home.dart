import 'package:aurora/core/services/image_getter/image_getter_provider.dart';
import 'package:aurora/core/services/preferences/prefs_provider.dart';
import 'package:aurora/core/widgets/offline_mode/offline_mode.dart';
import 'package:aurora/core/widgets/custom_button.dart';
import 'package:aurora/core/widgets/logo_button.dart';
import 'package:aurora/core/widgets/square_image.dart';
import 'package:aurora/view/widgets/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/widgets/aurora_effect/aurora_effect.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageGetterProvider.notifier).fetchRandomImageAndPalette();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(preferencesNotifierProvider);
    return Scaffold(
      floatingActionButton: LogoButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const PreferencesBottomSheet(),
          );
        },
      ),
      body: SizedBox(
        child: Stack(
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,

              child: AuroraEffect(),
            ),

            Center(
              child: prefsState.offlineMode == true
                  ? CachedColorsSwiper()
                  : SquareImageWidget(),
            ),

            Positioned(
              bottom: 100.h,
              left: 0.w,
              right: 0.w,
              child: Center(child: AnotherButton()),
            ),
          ],
        ),
      ),
    );
  }
}
