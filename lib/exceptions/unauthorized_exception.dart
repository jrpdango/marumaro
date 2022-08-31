class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException({
    this.message = '401 Error: user is unauthorized.',
  });
}
