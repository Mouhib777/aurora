import 'dart:developer';
import 'package:aurora/core/config/app_color.dart';
import 'package:aurora/core/config/app_constant.dart';
import 'package:aurora/core/services/cache/color_cache.dart';
import 'package:aurora/core/services/image_getter/image_getter_state.dart';
import 'package:aurora/core/utils/image_processor.dart';
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/prefs_provider.dart';

class ImageGetterNotifier extends Notifier<ImageGetterState> {
  Dio? _dio;

  late final ColorCacheService _colorCacheService;

  @override
  ImageGetterState build() {
    log("ImageGetterNotifier initialized");

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstant.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    )..interceptors.add(AwesomeDioInterceptor());

    _colorCacheService = ColorCacheService();

    ref.onDispose(() {
      _dio?.close(force: true);
      _colorCacheService.close();
      log("ImageGetterNotifier disposed");
    });

    return ImageGetterState.initial();
  }

  Future<void> fetchRandomImageAndPalette() async {
    final prefsState = ref.read(preferencesNotifierProvider);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    state = state.copyWith(
      isLoading: true,
      isProcessing: true,
      errorMessage: "",
    );
    prefsNotifier.setColors(
      lastColorState: [AppColor.auroraPrimaryColor],
      bgColors: [AppColor.auroraPrimaryColor],
    );

    try {
      final response = await _dio?.get('/image');
      final String imageUrl = response?.data['url'] ?? "";

      if (response?.statusCode == 200 && imageUrl.isNotEmpty) {
        state = state.copyWith(
          imageUrl: imageUrl,
          isLoading: false,
          isProcessing: true,
        );

        // check cached colors first (if found)
        final cachedColors = await _colorCacheService.getCachedColors(imageUrl);

        if (cachedColors != null && cachedColors.isNotEmpty) {
          log('using cached colors for: $imageUrl');
          state = state.copyWith(isLoading: false, isProcessing: false);
          prefsNotifier.setColors(
            lastColorState: cachedColors,
            bgColors: prefsState.multicolorBackground
                ? cachedColors
                : [cachedColors[0]],
          );
        } else {
          // no cached colors founded, fetch image and process
          await fetchImageAndProcessColors(imageUrl);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isProcessing: false,
          errorMessage: 'No ImageUrl',
        );
        prefsNotifier.setColors(
          lastColorState: [Colors.red],
          bgColors: [Colors.red],
        );
      }
    } catch (e, st) {
      log('exception in fetchRandomImageAndPalette ===> $e\n$st');
      state = state.copyWith(
        isLoading: false,
        isProcessing: false,
        errorMessage: 'Error fetching image, try again later',
      );
      prefsNotifier.setColors(
        lastColorState: [Colors.red],
        bgColors: [Colors.red],
      );
    }
  }

  Future<void> fetchImageAndProcessColors(String imageUrl) async {
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    try {
      // i removed interceptor here to avoid big logs
      final dioNoInterceptor = Dio(
        BaseOptions(
          connectTimeout: const Duration(
            seconds:
                10, // increased timeout for image download (big image size)
          ),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final imageResponse = await dioNoInterceptor.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (imageResponse.statusCode == 200 && imageResponse.data != null) {
        final imageBytes = imageResponse.data as List<int>;

        // processing colors in background
        await processColorsAndCache(imageUrl, imageBytes);
      } else {
        log(
          '=====> failed processColorsAndCache to fetch image bytes: ${imageResponse.statusCode}',
        );
      }
    } catch (e, st) {
      log('exception in fetchImageAndProcessColors ===> $e\n$st');
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Error downloading image',
      );
      prefsNotifier.setColors(
        lastColorState: [Colors.red],
        bgColors: [Colors.red],
      );
    }
  }

  Future<void> processColorsAndCache(
    String imageUrl,
    List<int> imageBytes,
  ) async {
    final prefsState = ref.read(preferencesNotifierProvider);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    try {
      state = state.copyWith(isProcessing: true);
      final List<Color> dominantColors =
          await ImageProcessorService.processImageInIsolate(imageBytes);

      // cache the colors
      await _colorCacheService.cacheColors(imageUrl, dominantColors);
      log('Colors cached for: $imageUrl');

      state = state.copyWith(isLoading: false, isProcessing: false);
      prefsNotifier.setColors(
        lastColorState: dominantColors,
        bgColors: prefsState.multicolorBackground
            ? dominantColors
            : [dominantColors[0]],
      );
    } catch (e) {
      log('color detecting error: $e');
      state = state.copyWith(isLoading: false, isProcessing: false);
      prefsNotifier.setColors(
        lastColorState: [AppColor.auroraPrimaryColor],
        bgColors: [AppColor.auroraPrimaryColor],
      );
    }
  }

  Future<void> clearColorCache() async {
    _colorCacheService.clearMemoryCache();
    log('color memory cache cleared');
  }

  void clearError() {
    state = state.copyWith(errorMessage: "");
  }

  void resetState() {
    state = ImageGetterState.initial();
  }
}
