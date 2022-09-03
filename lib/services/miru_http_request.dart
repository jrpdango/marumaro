import 'package:http/http.dart';
import 'package:miru/globals.dart';

class HttpRequest {
  static Future<Response> get(Uri uri, {Map<String, String>? headers}) async {
    headers ??= <String, String>{
      'Authorization': 'Bearer ${Globals.client.tokenPair.accessToken}'
    };
    return await Globals.client.userClient.get(uri, headers: headers);
  }
}
