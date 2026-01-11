class AuthState {
  final bool isLoading;
  final bool obscurePassword;

  const AuthState({this.isLoading = false, this.obscurePassword = true});

  AuthState copyWith({bool? isLoading, bool? obscurePassword}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}
