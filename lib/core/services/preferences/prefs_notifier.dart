import 'dart:developer';
import 'package:aurora/core/services/image_getter/image_getter_provider.dart';
import 'package:aurora/core/services/preferences/prefs_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/aurora_effect/aurora_provider.dart';

class PreferencesNotifier extends Notifier<PreferencesState> {
  @override
  PreferencesState build() {
    return PreferencesState.initial();
  }

  void toggleTheme() {
    final newIsDark = !state.isDarkMode;
    state = state.copyWith(
      isDarkMode: newIsDark,
      theme: newIsDark
          ? PreferencesState.darkTheme
          : PreferencesState.lightTheme,
    );
  }

  void setTheme(bool darkMode) {
    state = state.copyWith(
      isDarkMode: darkMode,
      theme: darkMode
          ? PreferencesState.darkTheme
          : PreferencesState.lightTheme,
    );
  }

  void toggleOfflineMode() {
    if (state.offlineMode == true) {
      ref.read(imageGetterProvider.notifier).fetchRandomImageAndPalette();
    }
    state = state.copyWith(offlineMode: !state.offlineMode);
  }

  void enableMulticolorBackground(bool value) {
    state = state.copyWith(multicolorBackground: value);
    if (value == true) {
      setColors(
        bgColors: state.lastColorState,
        lastColorState: state.lastColorState,
      );
    } else {
      setColors(
        bgColors: [state.lastColorState[0]],
        lastColorState: state.lastColorState,
      );
    }
  }

  void setColors({
    required List<Color> bgColors,
    required List<Color> lastColorState,
  }) async {
    log("setColors===> colors: $lastColorState");
    if (state.backgroundAnimation == false) {
      ref.read(auroraAnimationProvider.notifier).playAnimation();
      state = state.copyWith(
        bgColors: bgColors,
        lastColorState: lastColorState,
      );
      await Future.delayed(Duration(milliseconds: 2000));
      ref.read(auroraAnimationProvider.notifier).pauseAnimation();
    } else {
      state = state.copyWith(
        bgColors: bgColors,
        lastColorState: lastColorState,
      );
    }
  }

  void toggleBackgroundAnimation(bool value) {
    state = state.copyWith(backgroundAnimation: value);
    if (value == true) {
      ref.read(auroraAnimationProvider.notifier).playAnimation();
    } else {
      ref.read(auroraAnimationProvider.notifier).pauseAnimation();
    }
  }
}
