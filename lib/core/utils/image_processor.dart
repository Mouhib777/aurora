import 'dart:ui';
import 'package:aurora/core/config/app_color.dart';
import 'package:aurora/core/utils/kmeans_dominant_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageProcessorService {
  static final Map<String, List<Color>> _colorCache = {};

  static Future<List<Color>> processImageInIsolate(List<int> imageBytes) async {
    final key = _generateKey(imageBytes);
    if (_colorCache.containsKey(key)) {
      return _colorCache[key]!;
    }

    final colors = await compute(_parseImageAndGetColors, imageBytes);

    _colorCache[key] = colors;
    return colors;
  }

  static String _generateKey(List<int> bytes) {
    return '${bytes.length}_${bytes.hashCode}';
  }

  static List<Color> _parseImageAndGetColors(List<int> imageBytes) {
    try {
      final image = img.decodeImage(Uint8List.fromList(imageBytes));
      if (image == null) return [AppColor.auroraPrimaryColor];

      return kMeansDominantColors(image, k: 3);
    } catch (e) {
      return [AppColor.auroraPrimaryColor];
    }
  }
}
