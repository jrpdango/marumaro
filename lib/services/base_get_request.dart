import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:miru/globals.dart';
import 'package:http/http.dart' as http;

class BaseGetRequest {
  final Uri uri;
  final String successMessage;
  final String unknownErrorMessage;
  Map<String, String>? headers;

  BaseGetRequest({
    required this.uri,
    this.headers,
    this.successMessage = 'Request successful.',
    this.unknownErrorMessage = 'Request failed.',
  });

  Future<Map<String, dynamic>> get() async {
    headers ??= <String, String>{
      'Authorization': 'Bearer ${Globals.client.tokenPair.accessToken}'
    };
    http.Response response = await Globals.client.userClient.get(
      uri,
    );
    Map<String, dynamic> responseMap = json.decode(response.body);
    return <String, dynamic>{'data': <String, dynamic>{}};
  }
}
