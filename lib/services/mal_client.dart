import 'package:http/http.dart';
import 'package:miru/services/add_anime_request.dart';
import 'package:miru/services/login_request.dart';
import 'package:miru/services/pkce_code_gen.dart';

class MALClient {
  static const String CLIENTID = "b6cd1c6e3172ade1142272d4c288bdf2";
  final String pathMAL = "https://myanimelist.net";
  Client userClient = Client();

  String login() {
    String url;
    try {
      LoginRequest loginRequest = LoginRequest(
          clientID: CLIENTID, codeChallenge: CodeGenerator.genPKCEcode());
      // Receive URL with PKCE challenge
      url = loginRequest.createRequest(this);
      // Overlay webview of MAL Auth
      // Get access code after user accepts MAL Auth
      // loginRequest.generateToken(this,
      //     "IyItjwkQZqvGZCZWQbsllDAOLmCnrhLiuQZTRoHpNjDwSFAVZadAnQAZkSo_m_TcrcXtGjPaVeLgbZryCaleYjnqfHCrmnqoWJEWjUXPMYtkXw_QSEGnOtjcRCESOvwy");
      // loginRequest.print_user_info(this);
    } catch (e) {
      url = "Something happened here";
    }
    return url;
  }

  Future<void> addAnime(AddAnimeRequest addAnimeRequest) async {
    addAnimeRequest.createRequest(this);
  }

  void logout() {
    this.userClient.close();
  }
}
