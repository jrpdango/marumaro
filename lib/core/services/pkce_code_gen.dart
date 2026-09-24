import 'dart:math';

class CodeGenerator {
  /// RFC 7636 section 4.1 unreserved characters.
  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  static final Random _random = Random.secure();

  /// Generates a PKCE code verifier (RFC 7636 section 4.1).
  ///
  /// MyAnimeList only supports the `plain` challenge method, so the verifier
  /// is also sent as the `code_challenge`. [length] must be between 43 and 128.
  static String genCodeVerifier([int length = 128]) {
    assert(length >= 43 && length <= 128);
    return List<String>.generate(
      length,
      (_) => _charset[_random.nextInt(_charset.length)],
    ).join();
  }
}
