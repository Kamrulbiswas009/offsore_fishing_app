import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Constants for preference keys
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _idKey = 'userId';
  static const String _offlineZonesKey = 'offline_zones';
  static const String _profileCacheKey = 'profile_cache_json';
  static const String _profileStatsCacheKey = 'profile_stats_cache_json';

  // --- Weather Alert Keys ---
  static const String _watchedZonesKey = 'watched_zones_json';
  static const String _weatherAlertCacheKey = 'weather_alert_cache_json';

  // Singleton instance for SharedPreferences
  static SharedPreferences? _preferences;

  // Retrieve the list of zones saved offline
  static List<String> getOfflineZones() {
    return _preferences?.getStringList(_offlineZonesKey) ?? [];
  }

  // Save the list of zones saved offline
  static Future<void> saveOfflineZones(List<String> zones) async {
    await _preferences?.setStringList(_offlineZonesKey, zones);
  }

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

  // --- Profile Cache (last internet state) ---

  /// Persists the raw JSON string of the last successful `/user/me` response.
  static Future<void> saveProfileCache(String json) async {
    await _preferences?.setString(_profileCacheKey, json);
  }

  /// Returns the last cached profile JSON string, or null if not set yet.
  static String? getCachedProfileJson() =>
      _preferences?.getString(_profileCacheKey);

  /// Persists the profile stats as a simple JSON string.
  static Future<void> saveProfileStatsCache(String json) async {
    await _preferences?.setString(_profileStatsCacheKey, json);
  }

  /// Returns the last cached profile stats JSON string, or null if not set yet.
  static String? getCachedProfileStatsJson() =>
      _preferences?.getString(_profileStatsCacheKey);

  // --- Weather Alert: Watched Zones ---

  /// Returns the raw JSON string for watched zones, or null if never set.
  static String? getWatchedZonesJson() =>
      _preferences?.getString(_watchedZonesKey);

  /// Persists the serialized list of watched zone configs.
  static Future<void> saveWatchedZonesJson(String json) async =>
      _preferences?.setString(_watchedZonesKey, json);

  // --- Weather Alert: Last-Sent Alert Cache ---

  /// Returns the raw JSON string for the alert snapshot map, or null.
  static String? getWeatherAlertCacheJson() =>
      _preferences?.getString(_weatherAlertCacheKey);

  /// Persists the serialized alert snapshot map.
  static Future<void> saveWeatherAlertCacheJson(String json) async =>
      _preferences?.setString(_weatherAlertCacheKey, json);
}
