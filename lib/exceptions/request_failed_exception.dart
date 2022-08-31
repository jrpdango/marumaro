class RequestFailedException implements Exception {
  final String? message;
  const RequestFailedException({this.message});
}
