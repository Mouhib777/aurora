import 'package:aurora/core/widgets/aurora_effect/model/particle.dart';
import 'package:flutter/material.dart';

class AuroraPainter extends CustomPainter {
  final List<Particle> bigParticles;

  AuroraPainter({required this.bigParticles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in bigParticles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      final rect = Rect.fromCenter(
        center: particle.position,
        width: size.width * 0.25,
        height: size.height * 0.40,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
