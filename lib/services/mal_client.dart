import 'package:http/http.dart';
import 'package:miru/services/token.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:miru/services/oauth_request.dart';
import 'package:miru/services/pkce_code_gen.dart';
import 'package:miru/services/user_data_request.dart';

class MALClient {
  static const String CLIENTID = "b6cd1c6e3172ade1142272d4c288bdf2";
  String accessCode;
  Map tokenData;
  Client userClient = Client();
  LoginRequest loginRequest =
      LoginRequest(codeChallenge: CodeGenerator.genPKCEcode());
  Token token;

  String login() {
    String url;
    try {
      // Receive URL with PKCE challenge
      url = loginRequest.createRequest(this);
    } catch (e) {
      url = "Something happened here";
    }
    return url;
  }

  Future<void> getToken() async {
    this.token = await loginRequest.generateToken(this, this.accessCode);
    // this.accessToken = tokenData["access_token"];
    // this.refreshToken = tokenData["refresh_token"];
    print("DEBUG: Tokens received:");
    print("Access token: ${token.accessToken}");
    print("Refresh token: ${token.refreshToken}");
  }

  Future<void> getUserData() async {
    UserDataRequest.createRequest(this);
  }

  Future<void> updateList(UpdateListRequest updateListRequest) async {
    String response = await updateListRequest.createRequest(this);
    print(response);
  }

  void logout() {
    this.userClient.close();
  }
}
