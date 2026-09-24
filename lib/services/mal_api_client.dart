import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:miru/services/api_exception.dart';

/// Thin wrapper over the MAL v2 REST API.
///
/// Attaches the bearer token, encodes/decodes JSON, and converts non-2xx
/// responses into [ApiException]s.
class MalApiClient {
  MalApiClient({
    required this._httpClient,
    required this._accessTokenProvider,
  });

  static const String _host = "api.myanimelist.net";

  final http.Client _httpClient;
  final String? Function() _accessTokenProvider;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final http.Response response = await _httpClient.get(
      _uri(path, query),
      headers: _headers(),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, String>? body,
  }) async {
    final http.Response response = await _httpClient.patch(
      _uri(path),
      headers: _headers(json: false),
      body: body,
    );
    return _decode(response);
  }

  Future<void> delete(String path) async {
    final http.Response response = await _httpClient.delete(
      _uri(path),
      headers: _headers(json: false),
    );
    _decode(response);
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.https(_host, path, query);

  Map<String, String> _headers({bool json = true}) {
    final String? accessToken = _accessTokenProvider();
    return <String, String>{
      if (accessToken != null) "Authorization": "Bearer $accessToken",
      if (json) "Content-Type": "application/json",
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return <String, dynamic>{};
    return (jsonDecode(response.body) as Map).cast<String, dynamic>();
  }
}
