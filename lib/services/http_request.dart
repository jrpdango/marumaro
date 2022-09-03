import 'package:http/http.dart';
import 'package:miru/globals.dart';

class HttpRequest {
  HttpRequest();

  Future<Response> get(Uri uri, {Map<String, String>? headers}) async {
    return await Globals.client.userClient.get(uri, headers: headers);
  }
}
