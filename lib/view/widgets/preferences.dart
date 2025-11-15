import 'package:aurora/core/services/preferences/prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesBottomSheet extends ConsumerStatefulWidget {
  const PreferencesBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PreferencesBottomSheetState();
}

class _PreferencesBottomSheetState
    extends ConsumerState<PreferencesBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(preferencesNotifierProvider);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        runSpacing: 12,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Center(
            child: Text(
              'App Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Multicolor background'),
            value: prefsState.multicolorBackground,
            onChanged: (v) {
              prefsNotifier.enableMulticolorBackground(v);
            },
          ),

          SwitchListTile(
            title: const Text('Aurora effect'),
            value: prefsState.backgroundAnimation,
            onChanged: (v) {
              prefsNotifier.toggleBackgroundAnimation(v);
            },
          ),
          SwitchListTile(
            title: const Text('Dark theme'),
            value: prefsState.isDarkMode,
            onChanged: (v) {
              prefsNotifier.toggleTheme();
            },
          ),
          SwitchListTile(
            title: const Text('Offline mode'),
            value: prefsState.offlineMode,
            onChanged: (v) {
              prefsNotifier.toggleOfflineMode();
            },
          ),
        ],
      ),
    );
  }
}
