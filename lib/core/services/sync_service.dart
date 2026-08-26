import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/routes/app_routes.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';
import 'package:paytonpieper/features/report_main/summary/controller/summary_details_controller.dart';
import 'package:paytonpieper/features/map/controller/map_screen_controller.dart';

class SyncService extends GetxService {
  static SyncService get to => Get.find<SyncService>();

  Database? _db;
  Completer<Database>? _dbCompleter;
  final NetworkCaller _networkCaller = NetworkCaller();
  
  // Reactive sync states
  final RxBool isOnline = true.obs;
  final RxInt pendingCount = 0.obs;
  final RxBool isSyncing = false.obs; // Initialized to false to prevent stuck states on launch

  // Last prefetch timestamp to throttle back-to-back executions
  DateTime? _lastPrefetchTime;
  
  StreamSubscription? _connectivitySubscription;
  Timer? _retryTimer;
  Timer? _connectivityDebounce;

  // Asynchronous database getter with thread-safe Completer
  Future<Database> get db async {
    if (_db != null) return _db!;
    if (_dbCompleter != null) return _dbCompleter!.future;

    _dbCompleter = Completer<Database>();
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, 'offline_sync.db');
      final database = await openDatabase(
        path,
        version: 1,
        onOpen: (databaseInstance) async {
          await databaseInstance.execute('''
            CREATE TABLE IF NOT EXISTS pending_reports (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              frontendReportId TEXT UNIQUE,
              payload TEXT,
              createdAt TEXT,
              queueStatus TEXT
            )
          ''');
          await databaseInstance.execute('''
            CREATE TABLE IF NOT EXISTS pending_profile_updates (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              imagePath TEXT,
              createdAt TEXT
            )
          ''');
        },
        onCreate: (databaseInstance, version) async {
          await databaseInstance.execute('''
            CREATE TABLE IF NOT EXISTS pending_reports (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              frontendReportId TEXT UNIQUE,
              payload TEXT,
              createdAt TEXT,
              queueStatus TEXT
            )
          ''');
          await databaseInstance.execute('''
            CREATE TABLE IF NOT EXISTS pending_profile_updates (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              imagePath TEXT,
              createdAt TEXT
            )
          ''');
        },
      );
      _db = database;
      _dbCompleter!.complete(database);
      return database;
    } catch (e, stack) {
      debugPrint("Failed to initialize database: $e\n$stack");
      _dbCompleter!.completeError(e);
      _dbCompleter = null;
      rethrow;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  Future<void> _initService() async {
    try {
      await db; // Trigger async database open on startup
      await _updatePendingCount();
    } catch (e) {
      debugPrint("Startup database opening failed: $e");
    }
    await checkConnectivityAndSync();
    _startConnectivityListener();
    _startPeriodicRetryTimer();
    
    if (isOnline.value) {
      Future.delayed(const Duration(seconds: 3), () {
        prefetchAppData();
      });
    }
  }

  // True internet check: verifies connection to API IP or generic DNS lookup
  static Future<bool> hasActualInternet() async {
    try {
      // 1. First try to reach the report API backend directly on port 8000 (very fast TCP handshake)
      final socket = await Socket.connect('172.252.13.68', 8000, timeout: const Duration(seconds: 3));
      await socket.close();
      return true;
    } catch (_) {
      // 2. Fallback: try general DNS lookup for internet connectivity
      try {
        final lookupResult = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 3));
        return lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  // Checks connectivity, updates reactive state, and triggers sync if online
  Future<void> checkConnectivityAndSync() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConn = _isConnected(connectivityResult);
      if (hasConn) {
        // Double-check with a lightweight ping to verify actual internet
        final online = await hasActualInternet();
        isOnline.value = online;
      } else {
        isOnline.value = false;
      }
    } catch (_) {
      isOnline.value = false;
    }

    if (isOnline.value && pendingCount.value > 0) {
      triggerBackgroundSync();
    }
  }

  void _startConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _connectivityDebounce?.cancel();
      _connectivityDebounce = Timer(const Duration(seconds: 2), () async {
        final hasConn = _isConnected(result);
        final wasOffline = !isOnline.value;
        
        if (hasConn) {
          final online = await hasActualInternet();
          if (isOnline.value != online) {
            isOnline.value = online;
          }
        } else {
          if (isOnline.value != false) {
            isOnline.value = false;
          }
        }

        if (isOnline.value && wasOffline) {
          // Trigger auto-sync and prefetch when network is restored
          triggerBackgroundSync();
          prefetchAppData();
        }
      });
    });
  }

  bool _isConnected(dynamic result) {
    if (result is List) {
      return result.any((r) => r != ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }

  // Periodic retry: runs every 5 minutes to clean up pending queues
  void _startPeriodicRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (pendingCount.value > 0) {
        debugPrint("=== PERIODIC RETRY TRIGGERED ===");
        await checkConnectivityAndSync();
      }
    });
  }

  Future<void> _updatePendingCount() async {
    try {
      final database = await db;
      final reportCount = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM pending_reports'),
      ) ?? 0;
      final profileCount = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM pending_profile_updates'),
      ) ?? 0;
      pendingCount.value = reportCount + profileCount;
    } catch (e) {
      debugPrint("Failed to update pending count: $e");
    }
  }

  // Get all pending reports in correct FIFO order (id ASC)
  Future<List<Map<String, dynamic>>> getPendingReports() async {
    try {
      final database = await db;
      return await database.query('pending_reports', orderBy: 'id ASC');
    } catch (e) {
      debugPrint("Failed to query pending reports: $e");
      return [];
    }
  }

  // Save report locally
  Future<void> saveReportLocally(Map<String, dynamic> payload) async {
    final frontendId = payload['frontendReportId'] ?? '';
    
    // Mark capturedOfflineAt with current time
    payload['capturedOfflineAt'] = DateTime.now().toUtc().toIso8601String();
    
    try {
      final database = await db;
      await database.insert(
        'pending_reports',
        {
          'frontendReportId': frontendId,
          'payload': jsonEncode(payload),
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'queueStatus': 'PENDING',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await _updatePendingCount();
      debugPrint("=== Report saved locally (Offline Mode) | ID: $frontendId ===");
    } catch (e) {
      debugPrint("Failed to save report locally: $e");
    }
  }

  // Save pending profile update locally
  Future<void> saveProfileUpdateLocally({
    required String name,
    String? imagePath,
  }) async {
    try {
      final database = await db;
      // Keep only the latest pending profile update
      await database.delete('pending_profile_updates');
      await database.insert(
        'pending_profile_updates',
        {
          'name': name,
          'imagePath': imagePath,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        },
      );

      await _updatePendingCount();
      debugPrint("=== Profile update saved locally (Offline Mode) | Name: $name ===");
    } catch (e) {
      debugPrint("Failed to save profile update locally: $e");
    }
  }

  Future<void> _syncPendingProfileUpdates() async {
    try {
      final database = await db;
      final pendingUpdates = await database.query('pending_profile_updates', orderBy: 'id ASC');
      if (pendingUpdates.isEmpty) return;

      for (final row in pendingUpdates) {
        final id = row['id'];
        final name = row['name'] as String?;
        final imagePath = row['imagePath'] as String?;

        if (name == null || name.isEmpty) {
          await database.delete('pending_profile_updates', where: 'id = ?', whereArgs: [id]);
          continue;
        }

        File? fileToUpload;
        if (imagePath != null && imagePath.isNotEmpty) {
          final file = File(imagePath);
          if (file.existsSync()) {
            fileToUpload = file;
          }
        }

        final accessToken = StorageService.token;
        final token = (accessToken != null && accessToken.isNotEmpty)
            ? 'Bearer $accessToken'
            : null;

        var response = await _networkCaller.patchMultipartRequest(
          ApiConstants.updateProfileApi,
          fields: {'userName': name},
          file: fileToUpload,
          fileFieldName: 'file',
          token: token,
        );

        if (response.statusCode == 401) {
          final didRefresh = await _refreshAccessToken();
          if (didRefresh) {
            final newAccessToken = StorageService.token;
            final newToken = (newAccessToken != null && newAccessToken.isNotEmpty)
                ? 'Bearer $newAccessToken'
                : null;
            response = await _networkCaller.patchMultipartRequest(
              ApiConstants.updateProfileApi,
              fields: {'userName': name},
              file: fileToUpload,
              fileFieldName: 'file',
              token: newToken,
            );
          }
        }

        if (response.isSuccess) {
          debugPrint("=== OFFLINE PROFILE UPDATE SYNC SUCCESS for name: $name ===");
          await database.delete('pending_profile_updates', where: 'id = ?', whereArgs: [id]);

          if (Get.isRegistered<ProfileMainScreenController>()) {
            Get.find<ProfileMainScreenController>().getAuthMe();
          }

          Get.snackbar(
            "Profile Synced",
            "Your offline profile changes have been automatically synced!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF00E676),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        } else {
          debugPrint("=== OFFLINE PROFILE UPDATE SYNC FAILED: ${response.errorMessage} ===");
        }
      }
    } catch (e) {
      debugPrint("Failed to sync pending profile updates: $e");
    }
  }

  // Background Sync logic
  Future<void> triggerBackgroundSync() async {
    if (isSyncing.value) return;
    
    // Ensure we actually have internet before starting
    final online = await hasActualInternet();
    isOnline.value = online;
    if (!online) return;

    isSyncing.value = true;

    // 1. Sync pending profile updates first
    await _syncPendingProfileUpdates();

    final pending = await getPendingReports();
    if (pending.isEmpty) {
      await _updatePendingCount();
      isSyncing.value = false;
      return;
    }

    debugPrint("=== STARTING BACKGROUND SYNC: ${pending.length} reports pending ===");

    bool didSyncAny = false;

    try {
      final database = await db;
      for (final row in pending) {
        // Re-verify actual internet before processing each item
        final onlineCheck = await hasActualInternet();
        isOnline.value = onlineCheck;
        if (!onlineCheck) {
          debugPrint("=== SYNC PAUSED: Lost connection mid-batch ===");
          break;
        }

        final id = row['id'];
        final frontendReportId = row['frontendReportId'];
        final payloadMap = Map<String, dynamic>.from(jsonDecode(row['payload']));

        try {
          final accessToken = StorageService.token;
          final token = (accessToken != null && accessToken.isNotEmpty)
              ? 'Bearer $accessToken'
              : null;

          var response = await _networkCaller.postRequest(
            ApiConstants.submitReportApi,
            body: payloadMap,
            token: token,
          );

          if (response.statusCode == 401) {
            debugPrint("=== SYNC UNAUTHORIZED (401) for report ID: $frontendReportId. Attempting token refresh... ===");
            final didRefresh = await _refreshAccessToken();
            if (didRefresh) {
              final newAccessToken = StorageService.token;
              final newToken = (newAccessToken != null && newAccessToken.isNotEmpty)
                  ? 'Bearer $newAccessToken'
                  : null;
              
              // Retry posting report with fresh token
              response = await _networkCaller.postRequest(
                ApiConstants.submitReportApi,
                body: payloadMap,
                token: newToken,
              );
            }
          }

          if (response.isSuccess) {
            debugPrint("=== SYNC SUCCESS for report ID: $frontendReportId ===");
            didSyncAny = true;
            // Remove from local storage upon success
            await database.delete('pending_reports', where: 'id = ?', whereArgs: [id]);

            // Notify user of successful auto-sync
            try {
              final speciesList = payloadMap['species'] as List?;
              final firstSpecies = (speciesList != null && speciesList.isNotEmpty)
                  ? speciesList[0]['speciesName']
                  : 'Catch Report';
              Get.snackbar(
                "Offline Report Synced",
                "Your offline report for $firstSpecies has been automatically synced!",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF00E676),
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
            } catch (_) {}
          } else {
            // If response indicates a validation/server error, log it and continue
            debugPrint("=== SYNC FAILURE for report ID: $frontendReportId. Code: ${response.statusCode}, Error: ${response.errorMessage} ===");
            // We continue to subsequent items in the batch to avoid blocking the queue
          }
        } catch (e) {
          debugPrint("=== SYNC EXCEPTION for report ID: $frontendReportId. Error: $e ===");
          // Continue to the next item
        }
      }
    } catch (e) {
      debugPrint("Sync batch failed: $e");
    }

    await _updatePendingCount();
    isSyncing.value = false;
    debugPrint("=== BACKGROUND SYNC FINISHED ===");

    if (didSyncAny) {
      if (Get.isRegistered<SummaryController>()) {
        final summaryController = Get.find<SummaryController>();
        summaryController.fetchReports(forceRefresh: true);
        summaryController.fetchSummary(forceRefresh: true);
        summaryController.fetchWeather(forceRefresh: true);
      }
      if (Get.isRegistered<MapScreenController>()) {
        Get.find<MapScreenController>().forceRefreshZones();
      }
      if (Get.currentRoute != AppRoute.homeMainScreen) {
        Get.offAllNamed(AppRoute.homeMainScreen);
      }
    }
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = StorageService.refreshToken;
    final userId = StorageService.userId ?? _userIdFromToken(refreshToken);

    if (refreshToken == null || refreshToken.isEmpty || userId == null) {
      debugPrint('[SyncService] Token refresh skipped because userId or refreshToken is missing.');
      return false;
    }

    final response = await _networkCaller.postRequest(
      ApiConstants.getAccessTokenApi,
      body: {'userId': userId, 'refreshToken': refreshToken},
    );

    if (!response.isSuccess) {
      debugPrint('[SyncService] Token refresh failed: ${response.errorMessage}');
      return false;
    }

    final responseBody = response.responseData;
    final data = responseBody is Map ? responseBody['data'] : null;
    final newAccessToken = data is Map ? data['accessToken'] : null;
    final newRefreshToken = data is Map ? data['refreshToken'] : null;

    if (newAccessToken is! String ||
        newAccessToken.isEmpty ||
        newRefreshToken is! String ||
        newRefreshToken.isEmpty) {
      debugPrint('[SyncService] Token refresh response contained invalid tokens.');
      return false;
    }

    await StorageService.saveAuthTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
    await StorageService.saveUserId(userId);
    return true;
  }

  String? _userIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return payload is Map ? payload['sub'] as String? : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> prefetchAppData() async {
    final token = StorageService.token;
    if (token == null || token.isEmpty) {
      debugPrint('[SyncService] Prefetch skipped: No auth token found.');
      return;
    }
    
    final online = await hasActualInternet();
    if (!online) {
      debugPrint('[SyncService] Prefetch skipped: Device is offline.');
      return;
    }

    if (_lastPrefetchTime != null && 
        DateTime.now().difference(_lastPrefetchTime!) < const Duration(seconds: 30)) {
      debugPrint('[SyncService] Prefetch skipped: run within last 30 seconds.');
      return;
    }
    _lastPrefetchTime = DateTime.now();

    debugPrint('[SyncService] Starting foreground prefetch of all key app data...');
    
    final bearerToken = 'Bearer $token';
    
    try {
      // 1. User Profile
      await _networkCaller.cachedGetRequest(
        ApiConstants.authMeApi,
        token: bearerToken,
        cacheKey: "auth_me",
      );
      await Future.delayed(const Duration(milliseconds: 200));

      // 2. Group List
      await _networkCaller.cachedGetRequest(
        ApiConstants.featchGroupListApi,
        token: bearerToken,
        cacheKey: "group_list",
      );
      await Future.delayed(const Duration(milliseconds: 200));

      // 3. Region Reports
      await _networkCaller.cachedGetRequest(
        ApiConstants.getRegionReportsApi,
        token: bearerToken,
        cacheKey: "region_reports",
      );
      await Future.delayed(const Duration(milliseconds: 200));

      // 4. Region Summary
      await _networkCaller.cachedGetRequest(
        "${ApiConstants.getZoneSummaryApi}?regionCode=GOM&page=1&limit=20",
        token: bearerToken,
        cacheKey: "zone_summary_region",
      );
      await Future.delayed(const Duration(milliseconds: 200));

      // 5. Default Zone Map bounds (south: 28.0, north: 29.0, west: -90.0, east: -88.0)
      final defaultZonesUrl = ApiConstants.getZonesApi(
        south: 28.0,
        north: 29.0,
        west: -90.0,
        east: -88.0,
      );
      final defaultZonesCacheKey = "zones_bounds_28.00_29.00_-90.00_-88.00_filtering_false_sp_null_time_24h_m_null_d_0_250_v_PUBLIC";
      await _networkCaller.cachedGetRequest(
        defaultZonesUrl,
        token: bearerToken,
        cacheKey: defaultZonesCacheKey,
      );
      await Future.delayed(const Duration(milliseconds: 200));

      // 6. Default Weather (lat: 28.375, lng: -89.125)
      final defaultWeatherUrl = "https://api.stormglass.io/v2/weather/point?lat=28.375&lng=-89.125&params=windSpeed,windDirection,waveHeight,waterTemperature,airTemperature,cloudCover,swellDirection,swellPeriod";
      await _networkCaller.cachedGetRequest(
        defaultWeatherUrl,
        token: ApiConstants.stormGlassApiKey,
        cacheKey: "weather_28.375_-89.125",
      );

      debugPrint('[SyncService] Foreground prefetch completed successfully.');
    } catch (e) {
      debugPrint('[SyncService] Error during prefetch: $e');
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _connectivityDebounce?.cancel();
    super.onClose();
  }
}
