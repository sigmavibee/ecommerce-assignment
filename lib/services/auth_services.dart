import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    return expiryString != null ? DateTime.parse(expiryString) : null;
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    final expiry = await getTokenExpiry();
    return expiry == null || expiry.isAfter(DateTime.now());
  }

  Future<bool> needsRefresh() async {
    final expiry = await getTokenExpiry();
    return expiry != null &&
        expiry.isBefore(DateTime.now().add(Duration(minutes: 5)));
  }

  Future<void> saveTokens(String token, String refreshToken,
      {Duration? expiresIn}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);

    if (expiresIn != null) {
      final expiry = DateTime.now().add(expiresIn);
      await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    }
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      print('Refresh token: $refreshToken');
      if (refreshToken == null) return false;

      // Implement your token refresh API call here
      // Example:
      // final response = await http.post(
      //   Uri.parse('https://your-api.com/token/refresh'),
      //   body: {'refresh_token': refreshToken},
      // );
      //
      // final newToken = response.body['token'];
      // final newRefreshToken = response.body['refresh_token'];
      // await saveTokens(newToken, newRefreshToken);
      // return true;

      return false; // Remove this when implementing actual refresh
    } catch (e) {
      await clearTokens();
      return false;
    }
  }
}
