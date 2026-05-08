import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  const TokenStorage();

  static const _tokenKey = 'access_token';
  static const _tokenTypeKey = 'token_type';

  Future<void> save({
    required String accessToken,
    required String tokenType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_tokenTypeKey, tokenType);
  }

  Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> readTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
  }
}
