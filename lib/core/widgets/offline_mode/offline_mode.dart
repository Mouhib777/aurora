import 'package:animate_do/animate_do.dart';
import 'package:aurora/core/services/preferences/prefs_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../config/app_images.dart';
import 'providers/offline_provider.dart';

class CachedColorsSwiper extends ConsumerStatefulWidget {
  const CachedColorsSwiper({super.key});

  @override
  ConsumerState<CachedColorsSwiper> createState() => _CachedColorsSwiperState();
}

class _CachedColorsSwiperState extends ConsumerState<CachedColorsSwiper> {
  final SwiperController _swiperController = SwiperController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offlineModeNotifierProvider.notifier).loadCachedColors();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offlineModeNotifierProvider);
    final notifier = ref.read(offlineModeNotifierProvider.notifier);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final prefsState = ref.watch(preferencesNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.cachedData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.collections, size: 64, color: Colors.grey),
                  SizedBox(height: 16.h),
                  const Text(
                    'No cached colors found',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (state.error.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    color: Colors.redAccent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.error,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Swiper(
                    controller: _swiperController,
                    itemCount: state.cachedData.length,
                    itemBuilder: (context, index) {
                      final item = state.cachedData[index];
                      final imageUrl = item['imageUrl'] as String;
                      final createdAt = item['createdAt'] as DateTime;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat(
                              'MMM dd, yyyy - HH:mm',
                            ).format(createdAt),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),

                          Container(
                            width: 300.w,
                            height: 300.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                    const Text(
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
                                  child: const Text(
                                    "Something went wrong , please try again",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    layout: SwiperLayout.STACK,
                    itemWidth: MediaQuery.of(context).size.width * 0.8,
                    itemHeight: MediaQuery.of(context).size.height * 0.7,
                    duration: 300,
                    curve: Curves.easeInOut,
                    onIndexChanged: (index) {
                      notifier.setCurrentIndex(index);
                      if (index < state.cachedData.length) {
                        final item = state.cachedData[index];
                        final colors = item['colors'] as List<Color>;
                        prefsNotifier.setColors(
                          lastColorState: colors,
                          bgColors: prefsState.multicolorBackground
                              ? colors
                              : [colors[0]],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
