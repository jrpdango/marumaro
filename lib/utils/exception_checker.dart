import 'package:miru/exceptions/not_found_exception.dart';
import 'package:miru/exceptions/unauthorized_exception.dart';

class ExceptionChecker {
  const ExceptionChecker();

  static bool check(int statusCode) {
    switch (statusCode) {
      case 200:
      case 201:
      case 202:
        return true;
      case 401:
        throw UnauthorizedException();
      case 404:
        throw NotFoundException();
      default:
        throw Exception('$statusCode Error');
    }
  }
}
