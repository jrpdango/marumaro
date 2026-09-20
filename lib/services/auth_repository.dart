import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart';
import 'package:miru/constants.dart' as constants;
import 'package:miru/services/pkce_code_gen.dart';
import 'package:miru/services/token_store.dart';

/// Handles the MyAnimeList OAuth2 PKCE flow and token lifecycle.
class AuthRepository {
  AuthRepository({required Client httpClient, required TokenStore tokenStore})
      : _httpClient = httpClient,
        _tokenStore = tokenStore,
        _codeVerifier = CodeGenerator.genCodeVerifier();

  static final Uri _authorizeEndpoint =
      Uri.parse("https://myanimelist.net/v1/oauth2/authorize");
  static final Uri _tokenEndpoint =
      Uri.parse("https://myanimelist.net/v1/oauth2/token");
  static final Uri _userEndpoint =
      Uri.parse("https://api.myanimelist.net/v2/users/@me");

  final Client _httpClient;
  final TokenStore _tokenStore;
  String _codeVerifier;

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null;

  Uri authorizationUrl() {
    // MAL only supports the `plain` PKCE method, so the verifier doubles as
    // the challenge.
    _codeVerifier = CodeGenerator.genCodeVerifier();
    return _authorizeEndpoint.replace(queryParameters: {
      "response_type": "code",
      "client_id": constants.malClientId,
      "redirect_uri": constants.malRedirectUri,
      "code_challenge": _codeVerifier,
      "code_challenge_method": "plain",
    });
  }

  /// Restores a session from secure storage, refreshing it if needed.
  Future<bool> restoreSession() async {
    final StoredToken? stored = await _tokenStore.read();
    if (stored == null) return false;
    _accessToken = stored.accessToken;
    _refreshToken = stored.refreshToken;
    if (await _hasValidAccessToken()) return true;
    return _refreshSession();
  }

  /// Runs the interactive PKCE flow. Returns true when tokens were obtained.
  Future<bool> signIn() async {
    try {
      final String callback = await FlutterWebAuth2.authenticate(
        url: authorizationUrl().toString(),
        callbackUrlScheme: "miru",
      );
      final String? code = Uri.parse(callback).queryParameters["code"];
      if (code == null) return false;
      return await _exchangeCode(code);
    } on PlatformException {
      // The user cancelled or the browser could not be opened.
      return false;
    }
  }

  Future<void> signOut() async {
    _accessToken = null;
    _refreshToken = null;
    await _tokenStore.clear();
  }

  Future<bool> _hasValidAccessToken() async {
    if (_accessToken == null) return false;
    try {
      final Response response = await _httpClient.get(
        _userEndpoint,
        headers: {"Authorization": "Bearer $_accessToken"},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _refreshSession() async {
    if (_refreshToken == null) return false;
    final Response response = await _httpClient.post(_tokenEndpoint, body: {
      "client_id": constants.malClientId,
      "grant_type": "refresh_token",
      "refresh_token": _refreshToken!,
    });
    if (response.statusCode != 200) return false;
    await _persistTokens(jsonDecode(response.body));
    return true;
  }

  Future<bool> _exchangeCode(String code) async {
    final Response response = await _httpClient.post(_tokenEndpoint, body: {
      "client_id": constants.malClientId,
      "code": code,
      "code_verifier": _codeVerifier,
      "grant_type": "authorization_code",
      "redirect_uri": constants.malRedirectUri,
    });
    if (response.statusCode != 200) return false;
    await _persistTokens(jsonDecode(response.body));
    return true;
  }

  Future<void> _persistTokens(Map<String, dynamic> body) async {
    _accessToken = body["access_token"] as String;
    _refreshToken = body["refresh_token"] as String;
    await _tokenStore.write(StoredToken(
      accessToken: _accessToken!,
      refreshToken: _refreshToken!,
    ));
  }
}
