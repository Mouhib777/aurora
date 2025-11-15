import 'dart:ui';

import 'package:aurora/core/services/preferences/prefs_provider.dart';
import 'package:aurora/core/widgets/offline_mode/providers/offline_state.dart'
    show OfflineModeState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/cache/color_cache.dart';

class OfflineModeNotifier extends Notifier<OfflineModeState> {
  @override
  OfflineModeState build() {
    return const OfflineModeState();
  }

  ColorCacheService get _colorCache => ColorCacheService();

  Future<void> loadCachedColors() async {
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final prefsState = ref.read(preferencesNotifierProvider);
    state = state.copyWith(isLoading: true, error: "");

    try {
      final data = await _colorCache.getAllCachedColorsWithTimestamp();

      state = state.copyWith(cachedData: data, isLoading: false);

      if (data.isNotEmpty) {
        final firstItem = data[0];
        final colors = firstItem['colors'] as List<Color>;

        prefsNotifier.setColors(
          bgColors: prefsState.multicolorBackground ? colors : [colors[0]],
          lastColorState: colors,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load cached colors: $e',
      );
    }
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}
