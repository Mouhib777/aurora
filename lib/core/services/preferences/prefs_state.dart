import 'package:flutter/material.dart';
import '../../config/app_color.dart';

class PreferencesState {
  final ThemeData theme;
  final bool isDarkMode;
  final bool offlineMode;
  final bool multicolorBackground;
  final bool backgroundAnimation;
  final List<Color> bgColors;
  final List<Color> lastColorState;

  const PreferencesState({
    required this.theme,
    this.isDarkMode = false,
    this.offlineMode = false,
    this.multicolorBackground = true,
    this.backgroundAnimation = true,
    this.bgColors = const [AppColor.auroraPrimaryColor],
    this.lastColorState = const [AppColor.auroraPrimaryColor],
  });

  factory PreferencesState.initial() {
    return PreferencesState(
      theme: lightTheme,
      isDarkMode: false,
      offlineMode: false,
      multicolorBackground: true,
      backgroundAnimation: true,
      bgColors: [AppColor.auroraPrimaryColor],
      lastColorState: [AppColor.auroraPrimaryColor],
    );
  }

  PreferencesState copyWith({
    ThemeData? theme,
    bool? isDarkMode,
    bool? offlineMode,
    bool? multicolorBackground,
    bool? backgroundAnimation,
    List<Color>? bgColors,
    List<Color>? lastColorState,
  }) {
    return PreferencesState(
      theme: theme ?? this.theme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      offlineMode: offlineMode ?? this.offlineMode,
      multicolorBackground: multicolorBackground ?? this.multicolorBackground,
      backgroundAnimation: backgroundAnimation ?? this.backgroundAnimation,
      bgColors: bgColors ?? this.bgColors,
      lastColorState: lastColorState ?? this.lastColorState,
    );
  }

  static final lightTheme = ThemeData.light().copyWith(
    primaryColor: AppColor.auroraPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.auroraPrimaryColor,
      brightness: Brightness.light,
    ),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: AppColor.auroraPrimaryColor,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.auroraPrimaryColor,
      brightness: Brightness.dark,
    ),
  );
}
