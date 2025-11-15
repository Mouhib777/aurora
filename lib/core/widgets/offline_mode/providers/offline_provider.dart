import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_notifier.dart';
import 'offline_state.dart';

final offlineModeNotifierProvider =
    NotifierProvider<OfflineModeNotifier, OfflineModeState>(
      OfflineModeNotifier.new,
    );
