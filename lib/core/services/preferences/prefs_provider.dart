import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs_notifier.dart';
import 'prefs_state.dart';

final preferencesNotifierProvider =
    NotifierProvider<PreferencesNotifier, PreferencesState>(
      PreferencesNotifier.new,
    );
