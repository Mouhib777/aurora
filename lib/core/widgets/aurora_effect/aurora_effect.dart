import 'dart:async';
import 'dart:math';
import 'package:aurora/core/widgets/aurora_effect/aurora_provider.dart';
import 'package:flutter/material.dart';
import 'package:aurora/core/widgets/aurora_effect/aurora_painter.dart';
import 'package:aurora/core/widgets/aurora_effect/model/particle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/preferences/prefs_provider.dart';

class AuroraEffect extends ConsumerStatefulWidget {
  const AuroraEffect({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuroraEffectState();
}

class _AuroraEffectState extends ConsumerState<AuroraEffect>
    with SingleTickerProviderStateMixin {
  List<Particle> bigParticles = [];
  final int bigParticleCount = 40;
  late AnimationController _animationController;
  final Random _random = Random();

  Size? _lastSize;
  Timer? _colorTimer;

  // Color animation variables
  late List<Color> _currentBgColors;
  late List<Color> _targetBgColors;
  late List<double> _colorTransitionProgress;

  // Animation speed configuration
  double _currentLerpFactor = 0.09;
  double _currentWanderRadius = 80.0;
  double _currentOpacityChange = 0.05;
  double _currentTargetChangeChance = 0.02;
  Duration _currentUpdateInterval = const Duration(milliseconds: 16);

  // Speed presets
  static const double _normalLerpFactor = 0.09;
  static const double _normalWanderRadius = 80.0;
  static const double _normalOpacityChange = 0.05;
  static const double _normalTargetChangeChance = 0.02;
  static const Duration _normalUpdateInterval = Duration(milliseconds: 16);

  static const double _pausedLerpFactor = 0.03; // Much slower
  static const double _pausedWanderRadius = 40.0; // Smaller movement area
  static const double _pausedOpacityChange = 0.02; // Slower opacity changes
  static const double _pausedTargetChangeChance =
      0.01; // Less frequent direction changes
  static const Duration _pausedUpdateInterval = Duration(
    milliseconds: 100,
  ); // 10fps

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Initialize color arrays
    _currentBgColors = [];
    _targetBgColors = [];
    _colorTransitionProgress = [];

    // Set initial animation speed
    _setAnimationSpeed(false);
  }

  void _setAnimationSpeed(bool isPaused) {
    if (isPaused) {
      _currentLerpFactor = _pausedLerpFactor;
      _currentWanderRadius = _pausedWanderRadius;
      _currentOpacityChange = _pausedOpacityChange;
      _currentTargetChangeChance = _pausedTargetChangeChance;
      _currentUpdateInterval = _pausedUpdateInterval;
    } else {
      _currentLerpFactor = _normalLerpFactor;
      _currentWanderRadius = _normalWanderRadius;
      _currentOpacityChange = _normalOpacityChange;
      _currentTargetChangeChance = _normalTargetChangeChance;
      _currentUpdateInterval = _normalUpdateInterval;
    }
  }

  void _initializeParticles(Size size) {
    if (_lastSize == size) return;

    _lastSize = size;
    final bgColors = ref.read(preferencesNotifierProvider).bgColors;

    // Initialize color arrays
    _currentBgColors = List.generate(
      bigParticleCount,
      (index) => bgColors[_random.nextInt(bgColors.length)],
    );
    _targetBgColors = List.generate(
      bigParticleCount,
      (index) => bgColors[_random.nextInt(bgColors.length)],
    );
    _colorTransitionProgress = List.generate(bigParticleCount, (index) => 0.0);

    bigParticles = List.generate(bigParticleCount, (index) {
      final position = Offset(
        _random.nextDouble() * size.width,
        _random.nextDouble() * size.height,
      );

      return Particle(
        color: _currentBgColors[index],
        position: position,
        size: _random.nextDouble() * 40 + 20,
        opacity: _random.nextDouble() * 0.7 + 0.3,
        scale: _random.nextDouble() * 1.5 + 0.5,
        targetPosition: position,
        targetScale: _random.nextDouble() * 1.5 + 0.5,
      );
    });

    _animationController.repeat();
  }

  void _animateParticles() {
    for (int i = 0; i < bigParticles.length; i++) {
      Particle particle = bigParticles[i];

      if (_lastSize != null && _isParticleTooFar(particle)) {
        particle.position = Offset(
          _random.nextDouble() * _lastSize!.width,
          _random.nextDouble() * _lastSize!.height,
        );
        particle.targetPosition = particle.position;
        continue;
      }

      double dx =
          (particle.targetPosition.dx - particle.position.dx) *
          _currentLerpFactor;
      double dy =
          (particle.targetPosition.dy - particle.position.dy) *
          _currentLerpFactor;

      Offset newPosition = particle.position.translate(dx, dy);
      particle.position = newPosition;

      particle.scale +=
          (particle.targetScale - particle.scale) * _currentLerpFactor;
      particle.opacity += (_random.nextDouble() - 0.5) * _currentOpacityChange;
      particle.opacity = particle.opacity.clamp(0.3, 1.0);

      bool reachedTarget =
          (particle.position - particle.targetPosition).distance < 2;
      bool shouldChangeTarget =
          _random.nextDouble() < _currentTargetChangeChance;

      if (reachedTarget || shouldChangeTarget) {
        particle.targetPosition = _getNewTargetPosition(
          particle.position,
          _currentWanderRadius,
        );
        particle.targetScale = _random.nextDouble() * 1.5 + 0.5;
      }
    }
  }

  bool _isParticleTooFar(Particle particle) {
    if (_lastSize == null) return false;

    return particle.position.dx < -200 ||
        particle.position.dx > _lastSize!.width + 200 ||
        particle.position.dy < -200 ||
        particle.position.dy > _lastSize!.height + 200;
  }

  void _animateColors() {
    final bgColors = ref.read(preferencesNotifierProvider).bgColors;

    for (int i = 0; i < bigParticles.length; i++) {
      _colorTransitionProgress[i] += 0.02;

      if (_colorTransitionProgress[i] >= 1.0) {
        _colorTransitionProgress[i] = 0.0;
        _currentBgColors[i] = _targetBgColors[i];
        _targetBgColors[i] = bgColors[_random.nextInt(bgColors.length)];
      }

      final color = Color.lerp(
        _currentBgColors[i],
        _targetBgColors[i],
        _colorTransitionProgress[i],
      )!;

      bigParticles[i].color = color;
    }
  }

  Offset _getNewTargetPosition(Offset currentPosition, double maxRadius) {
    double angle = _random.nextDouble() * 2 * pi;
    double distance = _random.nextDouble() * maxRadius;

    return Offset(
      currentPosition.dx + cos(angle) * distance,
      currentPosition.dy + sin(angle) * distance,
    );
  }

  void _restartAnimation() {
    _animationController.stop();
    _colorTimer?.cancel();
    _lastSize = null;
    _setAnimationSpeed(false);
    if (mounted) {
      setState(() {});
    }
  }

  void _pauseAnimation() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _setAnimationSpeed(true);
    _startSlowerAnimation();
  }

  void _playAnimation() {
    _colorTimer?.cancel();
    _setAnimationSpeed(false);
    if (!_animationController.isAnimating) {
      _animationController.repeat();
    }
  }

  void _startSlowerAnimation() {
    _colorTimer?.cancel();
    _colorTimer = Timer.periodic(_currentUpdateInterval, (timer) {
      if (mounted && bigParticles.isNotEmpty) {
        _animateParticles();
        _animateColors();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(auroraAnimationProvider, (previous, next) {
      if (next.shouldRestart) {
        _restartAnimation();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            ref.read(auroraAnimationProvider.notifier).reset();
          }
        });
      }

      if (previous?.animationState != next.animationState) {
        if (next.animationState == AnimationState.paused) {
          _pauseAnimation();
        } else {
          _playAnimation();
        }
      }
    });

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_lastSize == null || _lastSize != size) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _initializeParticles(size);
            }
          });
        }

        return Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (bigParticles.isNotEmpty) {
                _animateParticles();
                _animateColors();
              }
              return CustomPaint(
                size: size,
                painter: AuroraPainter(bigParticles: bigParticles),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _colorTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}
