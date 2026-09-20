import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A pair of OAuth tokens persisted in platform secure storage.
class StoredToken {
  const StoredToken({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

/// Persists MAL OAuth tokens using the platform keychain/keystore.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'mal_access_token';
  static const String _refreshTokenKey = 'mal_refresh_token';

  final FlutterSecureStorage _storage;

  Future<StoredToken?> read() async {
    final String? accessToken = await _storage.read(key: _accessTokenKey);
    final String? refreshToken = await _storage.read(key: _refreshTokenKey);
    if (accessToken == null || refreshToken == null) return null;
    return StoredToken(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> write(StoredToken token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
