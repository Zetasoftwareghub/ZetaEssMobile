class LocalAuthState {
  final bool hasPin;
  final String? savedPin;
  final bool isAuthenticated;
  final bool urlExist;

  LocalAuthState({
    this.hasPin = false,
    this.savedPin,
    this.isAuthenticated = false,
    this.urlExist = false,
  });

  LocalAuthState copyWith({
    bool? hasPin,
    bool? isAuthenticated,
    bool? urlExist,
    String? savedPin,
  }) {
    return LocalAuthState(
      hasPin: hasPin ?? this.hasPin,
      urlExist: urlExist ?? this.urlExist,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      savedPin: savedPin ?? this.savedPin,
    );
  }
}
