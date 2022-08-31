import 'package:miru/exceptions/unauthorized_exception.dart';

class ExceptionChecker {
  const ExceptionChecker();

  static bool check(
    int statusCode, {
    String? successMessage = 'Request successful.',
    String? unauthorizedExceptionMessage = 'Error: user is unauthorized.',
  }) {
    switch (statusCode) {
      case 200:
        return true;
      case 401:
        throw const UnauthorizedException();
      default:
    }
    return true;
  }
}
