import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/weather_alerts/model/bite_watch_model.dart';

class BiteWatchController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  
  final RxList<BiteWatchModel> watchedZones = <BiteWatchModel>[].obs;
  final RxBool isLoading = false.obs;
  
  // Local cache key for fallbacks in offline or dev testing
  static const String _localBiteWatchesKey = 'local_bite_watches_backup';

  String? get _token {
    final token = StorageService.token;
    return token == null || token.isEmpty ? null : 'Bearer $token';
  }

  @override
  void onInit() {
    super.onInit();
    _loadLocalBackup();
    fetchWatchedZones();
    uploadFcmToken();
  }

  // --- CRUD Operations ---

  Future<void> fetchWatchedZones() async {
    if (_token == null) return;
    isLoading.value = true;
    try {
      final response = await _networkCaller.getRequest(
        ApiConstants.watchedZonesListApi,
        token: _token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        final data = body is Map ? body['data'] : null;
        if (data is List) {
          final loaded = data
              .whereType<Map>()
              .map((item) => BiteWatchModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          watchedZones.assignAll(loaded);
          _saveLocalBackup();
          AppLoggerHelper.info('[BiteWatch] Loaded ${loaded.length} watched zones from server.');
          return;
        }
      }
      AppLoggerHelper.warning('[BiteWatch] Failed to fetch from server: ${response.errorMessage}. Using cached data.');
    } catch (e) {
      AppLoggerHelper.error('[BiteWatch] Exception fetching watched zones', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> watchZone(
    String zoneId, {
    String? displayLabel,
    int threshold = 3,
    int days = 7,
  }) async {
    if (_token == null) return false;
    isLoading.value = true;
    try {
      final payload = {
        'displayLabel': displayLabel ?? zoneId,
        'watchBiteActivity': true,
        'biteThreshold': threshold,
        'biteThresholdDays': days,
      };

      final response = await _networkCaller.postRequest(
        ApiConstants.watchZoneApi(zoneId),
        body: payload,
        token: _token,
      );

      if (response.isSuccess) {
        await fetchWatchedZones();
        return true;
      }
      
      // Fallback/Mock behavior in case server returns error
      AppLoggerHelper.warning('[BiteWatch] Server watch failed. Falling back to local simulation.');
      final mock = BiteWatchModel(
        watchId: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        zoneId: zoneId,
        displayLabel: displayLabel ?? zoneId,
        watchBiteActivity: true,
        biteThreshold: threshold,
        biteThresholdDays: days,
      );
      watchedZones.removeWhere((w) => w.zoneId == zoneId);
      watchedZones.add(mock);
      _saveLocalBackup();
      return true;
    } catch (e) {
      AppLoggerHelper.error('[BiteWatch] Exception watching zone', e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateWatchSettings(
    String zoneId, {
    bool? watchBiteActivity,
    int? biteThreshold,
    int? biteThresholdDays,
  }) async {
    if (_token == null) return false;
    isLoading.value = true;
    try {
      final payload = <String, dynamic>{};
      if (watchBiteActivity != null) payload['watchBiteActivity'] = watchBiteActivity;
      if (biteThreshold != null) payload['biteThreshold'] = biteThreshold;
      if (biteThresholdDays != null) payload['biteThresholdDays'] = biteThresholdDays;

      final response = await _networkCaller.patchRequest(
        ApiConstants.watchZoneApi(zoneId),
        body: payload,
        token: _token,
      );

      if (response.isSuccess) {
        await fetchWatchedZones();
        return true;
      }

      // Fallback update locally
      final idx = watchedZones.indexWhere((w) => w.zoneId == zoneId);
      if (idx != -1) {
        watchedZones[idx] = watchedZones[idx].copyWith(
          watchBiteActivity: watchBiteActivity,
          biteThreshold: biteThreshold,
          biteThresholdDays: biteThresholdDays,
        );
        _saveLocalBackup();
        return true;
      }
      return false;
    } catch (e) {
      AppLoggerHelper.error('[BiteWatch] Exception updating watch settings', e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> unwatchZone(String zoneId) async {
    if (_token == null) return false;
    isLoading.value = true;
    try {
      final response = await _networkCaller.deleteRequest(
        ApiConstants.watchZoneApi(zoneId),
        token: _token,
      );

      if (response.isSuccess) {
        await fetchWatchedZones();
        return true;
      }

      // Local fallback removal
      watchedZones.removeWhere((w) => w.zoneId == zoneId);
      _saveLocalBackup();
      return true;
    } catch (e) {
      AppLoggerHelper.error('[BiteWatch] Exception unwatching zone', e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- FCM Device Token Sync ---

  Future<void> uploadFcmToken() async {
    if (_token == null) return;
    try {
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          AppLoggerHelper.warning('[FCM] APNS token is not available yet on this iOS device/simulator. Skipping FCM upload.');
          return;
        }
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      AppLoggerHelper.info('[FCM] Registering device token with backend: $fcmToken');
      final response = await _networkCaller.patchRequest(
        ApiConstants.fcmTokenApi,
        body: {'fcmToken': fcmToken},
        token: _token,
      );
      if (response.isSuccess) {
        AppLoggerHelper.info('[FCM] Device token registered successfully on server.');
      } else {
        AppLoggerHelper.warning('[FCM] Device token registration failed: ${response.errorMessage}');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        AppLoggerHelper.warning('[FCM] APNS token is not available on this iOS device/simulator.');
      } else {
        AppLoggerHelper.error('[FCM] FirebaseException uploading FCM token', e);
      }
    } catch (e) {
      if (e.toString().contains('apns-token-not-set')) {
        AppLoggerHelper.warning('[FCM] APNS token is not available on this iOS device/simulator.');
      } else {
        AppLoggerHelper.error('[FCM] Exception uploading FCM token', e);
      }
    }
  }

  // --- Helpers ---

  bool isWatched(String zoneId) =>
      watchedZones.any((w) => w.zoneId == zoneId);

  BiteWatchModel? getWatchFor(String zoneId) {
    try {
      return watchedZones.firstWhere((w) => w.zoneId == zoneId);
    } catch (_) {
      return null;
    }
  }

  // --- Local Persistence Backup ---

  void _loadLocalBackup() {
    try {
      final raw = StorageService.getWatchedZonesJson(); // Reuses general storage or custom backing
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        final items = decoded
            .whereType<Map>()
            .map((item) => BiteWatchModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        if (items.isNotEmpty) {
          watchedZones.assignAll(items);
        }
      }
    } catch (_) {}
  }

  void _saveLocalBackup() {
    try {
      final raw = jsonEncode(watchedZones.map((w) => w.toJson()).toList());
      StorageService.saveWatchedZonesJson(raw);
    } catch (_) {}
  }
}
