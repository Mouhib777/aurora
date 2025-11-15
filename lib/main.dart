import 'package:aurora/core/services/preferences/prefs_provider.dart'
    show preferencesNotifierProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'view/home.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Consumer(
          builder: (context, ref, _) {
            final prefsState = ref.watch(preferencesNotifierProvider);

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: prefsState.theme,
              home: child,
            );
          },
          child: child,
        );
      },
      child: const HomeScreen(),
    );
  }
}
