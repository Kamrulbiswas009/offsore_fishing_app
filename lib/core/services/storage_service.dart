import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Constants for preference keys
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _idKey = 'userId';

  // Singleton instance for SharedPreferences
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences (call this during app startup)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Check if a token exists in local storage
  static bool hasToken() {
    final token = _preferences?.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Save the token and user ID to local storage
  static Future<void> saveToken(String token, String id) async {
    await _preferences?.setString(_tokenKey, token);
    await _preferences?.setString(_idKey, id);
  }

  static Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _preferences?.setString(_tokenKey, accessToken);
    await _preferences?.setString(_refreshTokenKey, refreshToken);
  }

  static Future<void> saveUserId(String userId) async {
    await _preferences?.setString(_idKey, userId);
  }

  // Remove all locally persisted data for a clean logout.
  static Future<void> logoutUser() async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    _preferences = preferences;
    await preferences.clear();
  }

  // Getter for user ID
  static String? get userId => _preferences?.getString(_idKey);

  // Getter for token
  static String? get token => _preferences?.getString(_tokenKey);

  static String? get refreshToken => _preferences?.getString(_refreshTokenKey);
}
