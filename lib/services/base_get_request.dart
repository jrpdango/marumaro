import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:miru/exceptions/not_found_exception.dart';
import 'package:miru/exceptions/unauthorized_exception.dart';
import 'package:miru/globals.dart';
import 'package:http/http.dart' as http;
import 'package:miru/utils/exception_checker.dart';

class BaseGetRequest {
  static Future<Map<String, dynamic>> send(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    headers ??= <String, String>{
      'Authorization': 'Bearer ${Globals.client.tokenPair.accessToken}'
    };
    http.Response response = await Globals.client.userClient.get(
      uri,
      headers: headers,
    );
    Map<String, dynamic> responseMap = json.decode(response.body);
    try {
      // If status code == 200, return the server's response
      ExceptionChecker.check(response.statusCode);
      return responseMap;
    } on UnauthorizedException catch (e) {
      debugPrint(e.message);
    } on NotFoundException catch (e) {
      debugPrint(e.message);
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('Uri: $uri');
      debugPrint('Response: ${responseMap.toString()}');
    }
    // If an exception is caught, return an empty map
    return <String, dynamic>{};
  }
}
