import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/exceptions/not_found_exception.dart';
import 'package:miru/exceptions/unauthorized_exception.dart';
import 'package:miru/globals.dart';
import 'package:http/http.dart' as http;
import 'package:miru/utils/exception_checker.dart';

class BaseRequest {
  final Uri uri;
  final MiruHttpRequestType httpRequestType;
  Map<String, String>? headers;
  Map<String, dynamic>? body;

  BaseRequest({
    required this.uri,
    required this.httpRequestType,
    this.headers,
    this.body,
  });

  Future<Map<String, dynamic>> send() async {
    http.Response response;
    headers ??= <String, String>{
      'Authorization': 'Bearer ${Globals.client.tokenPair?.accessToken}'
    };
    // TODO: Make other requests
    switch (httpRequestType) {
      case MiruHttpRequestType.get:
        response = await Globals.client.userClient.get(
          uri,
          headers: headers,
        );
        break;
      case MiruHttpRequestType.post:
        response = await Globals.client.userClient.post(
          uri,
          headers: headers,
          body: body,
        );
        break;
      case MiruHttpRequestType.patch:
        response = await Globals.client.userClient.patch(
          uri,
          headers: headers,
          body: body,
        );
        break;
      case MiruHttpRequestType.delete:
        response = await Globals.client.userClient.delete(
          uri,
          headers: headers,
        );
        break;
      default:
        response = await Globals.client.userClient.get(
          uri,
          headers: headers,
        );
    }
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
      debugPrint(
        '${e.toString()} \n Uri: $uri \n Response: ${responseMap.toString()}',
      );
    }
    // If an exception is caught, return an empty map
    return <String, dynamic>{};
  }
}
