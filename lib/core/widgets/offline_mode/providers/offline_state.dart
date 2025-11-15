class OfflineModeState {
  final List<Map<String, dynamic>> cachedData;
  final bool isLoading;
  final int currentIndex;
  final String error;

  const OfflineModeState({
    this.cachedData = const [],
    this.isLoading = false,
    this.currentIndex = 0,
    this.error = "",
  });

  OfflineModeState copyWith({
    List<Map<String, dynamic>>? cachedData,
    bool? isLoading,
    int? currentIndex,
    String? error,
  }) {
    return OfflineModeState(
      cachedData: cachedData ?? this.cachedData,
      isLoading: isLoading ?? this.isLoading,
      currentIndex: currentIndex ?? this.currentIndex,
      error: error ?? this.error,
    );
  }
}
