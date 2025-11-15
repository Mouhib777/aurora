import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aurora/core/services/image_getter/image_getter_notifier.dart';
import 'package:aurora/core/services/image_getter/image_getter_state.dart';

final imageGetterProvider =
    NotifierProvider<ImageGetterNotifier, ImageGetterState>(
      ImageGetterNotifier.new,
    );
