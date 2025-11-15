import 'package:flutter_riverpod/legacy.dart';

enum AnimationState { playing, paused }

class AuroraAnimationState {
  final bool shouldRestart;
  final AnimationState animationState;

  AuroraAnimationState({
    this.shouldRestart = false,
    this.animationState = AnimationState.playing,
  });

  AuroraAnimationState copyWith({
    bool? shouldRestart,
    AnimationState? animationState,
  }) {
    return AuroraAnimationState(
      shouldRestart: shouldRestart ?? this.shouldRestart,
      animationState: animationState ?? this.animationState,
    );
  }
}

final auroraAnimationProvider =
    StateNotifierProvider<AuroraAnimationNotifier, AuroraAnimationState>(
      (ref) => AuroraAnimationNotifier(),
    );

class AuroraAnimationNotifier extends StateNotifier<AuroraAnimationState> {
  AuroraAnimationNotifier() : super(AuroraAnimationState());

  void restartAnimation() {
    state = state.copyWith(shouldRestart: true);
  }

  void reset() {
    state = state.copyWith(shouldRestart: false);
  }

  void pauseAnimation() {
    state = state.copyWith(animationState: AnimationState.paused);
  }

  void playAnimation() {
    state = state.copyWith(animationState: AnimationState.playing);
  }
}
