import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// extracts the k most dominant colors in an image using K-Means clustering.
///
/// to make things faster, the image is first resized, then each pixel's RGB values
/// are grouped into clusters using the K-Means algorithm. The result is a list of
/// colors that best represent the image.
///
/// This approach is inspired by OpenCV techniques and this article:
/// https://medium.com/@ys3372/deconstructing-an-image-with-pixels-4c65c3a2268c
///
/// There isn’t a Dart/Flutter package that perfectly extracts dominant colors (based on my research),
/// so it’s a custom solution (with helping of DeepSeek), and i plan to package it up and share it on https://pub.dev/.
/// update====>  Published the custom dominant color extraction solution as a package on pub.dev:
/// https://pub.dev/packages/kmeans_dominant_colors
///
/// - [image]: the image to analyze.
/// - [k]: how many colors you want to extract (i make default : 3).
/// - [maxIterations]: maximum number of iterations for the clustering.
///
/// returns a list of Colors, sorted by how dominant they are in the image.

List<Color> kMeansDominantColors(
  img.Image image, {
  int k = 3,
  int maxIterations = 10,
}) {
  final resized = img.copyResize(image, width: 100);

  final pixels = <List<int>>[];
  for (int y = 0; y < resized.height; y++) {
    for (int x = 0; x < resized.width; x++) {
      final pixel = resized.getPixel(x, y);
      pixels.add([pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()]);
    }
  }

  List<List<int>> centroids = initializeCentroids(pixels, k);
  List<List<List<int>>> clusters = List.generate(k, (_) => []);

  for (int iteration = 0; iteration < maxIterations; iteration++) {
    for (var cluster in clusters) {
      cluster.clear();
    }

    for (var pixel in pixels) {
      int nearestIndex = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < centroids.length; i++) {
        final distance = colorDistance(pixel, centroids[i]);
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }

      clusters[nearestIndex].add(pixel);
    }

    List<List<int>> newCentroids = [];
    for (var cluster in clusters) {
      if (cluster.isEmpty) continue;

      final avgR =
          (cluster.map((p) => p[0]).reduce((a, b) => a + b) / cluster.length)
              .round();
      final avgG =
          (cluster.map((p) => p[1]).reduce((a, b) => a + b) / cluster.length)
              .round();
      final avgB =
          (cluster.map((p) => p[2]).reduce((a, b) => a + b) / cluster.length)
              .round();

      newCentroids.add([avgR, avgG, avgB]);
    }

    if (centroidsEqual(centroids, newCentroids)) {
      break;
    }

    centroids = newCentroids;
  }

  final colorClusters = clusters
      .asMap()
      .entries
      .where((entry) => entry.value.isNotEmpty)
      .map(
        (entry) => (
          color: Color.fromRGBO(
            centroids[entry.key][0],
            centroids[entry.key][1],
            centroids[entry.key][2],
            1.0,
          ),
          size: entry.value.length,
        ),
      )
      .toList();

  colorClusters.sort((a, b) => b.size.compareTo(a.size));

  return colorClusters.take(k).map((cluster) => cluster.color).toList();
}

List<List<int>> initializeCentroids(List<List<int>> pixels, int k) {
  return List.generate(k, (i) {
    final index = (i * pixels.length ~/ k).clamp(0, pixels.length - 1);
    return List.from(pixels[index]);
  });
}

double colorDistance(List<int> color1, List<int> color2) {
  final dr = color1[0] - color2[0];
  final dg = color1[1] - color2[1];
  final db = color1[2] - color2[2];
  return (dr * dr + dg * dg + db * db).toDouble();
}

bool centroidsEqual(List<List<int>> a, List<List<int>> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i][0] != b[i][0] || a[i][1] != b[i][1] || a[i][2] != b[i][2]) {
      return false;
    }
  }
  return true;
}
