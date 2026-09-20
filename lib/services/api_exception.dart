/// Thrown when a MAL API request returns a non-successful response.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => "ApiException($statusCode): $message";
}
