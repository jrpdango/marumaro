import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:miru/exceptions/unauthorized_exception.dart';
import 'package:miru/globals.dart';
import 'package:http/http.dart' as http;
import 'package:miru/utils/exception_checker.dart';

class BaseGetRequest {
  final Uri uri;
  Map<String, String>? headers;

  BaseGetRequest({
    required this.uri,
    this.headers,
  });

  Future<Map<String, dynamic>> get() async {
    headers ??= <String, String>{
      'Authorization': 'Bearer ${Globals.client.tokenPair.accessToken}'
    };
    http.Response response = await Globals.client.userClient.get(
      uri,
    );
    Map<String, dynamic> responseMap = json.decode(response.body);
    try {
      ExceptionChecker.check(response.statusCode);
    } on UnauthorizedException catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint(e.toString());
    }
    return <String, dynamic>{'data': <String, dynamic>{}};
  }
}
