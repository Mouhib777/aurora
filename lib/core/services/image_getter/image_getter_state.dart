class ImageGetterState {
  final bool isLoading;
  final bool isProcessing;
  final String errorMessage;
  final String imageUrl;

  ImageGetterState({
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage = "",
    this.imageUrl = "",
  });
  factory ImageGetterState.initial() {
    return ImageGetterState(
      isLoading: false,
      isProcessing: false,
      errorMessage: "",
      imageUrl: "",
    );
  }
  ImageGetterState copyWith({
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    String? imageUrl,
  }) {
    return ImageGetterState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
