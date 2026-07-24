import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/features/report_main/summary/controller/summary_details_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';
import 'package:paytonpieper/core/services/offline_cache_service.dart';
import 'package:paytonpieper/core/services/sync_service.dart';

class FakeOfflineCacheService extends GetxService implements OfflineCacheService {
  @override
  Future<dynamic> getCache(String key, {bool ignoreExpiry = false, Duration? maxAge}) async => null;
  @override
  Future<void> setCache(String key, dynamic data, {int? ttlMinutes}) async {}
  @override
  Future<void> deleteCache(String key) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSyncService extends GetxService implements SyncService {
  @override
  final RxBool isOnline = true.obs;
  @override
  final RxInt pendingCount = 0.obs;
  @override
  final RxBool isSyncing = false.obs;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProfileMainScreenController extends GetxController implements ProfileMainScreenController {
  bool premiumValue = false;

  @override
  bool get isPremiumAccount => premiumValue;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SummaryController controller;
  late FakeProfileMainScreenController mockProfileCtrl;

  setUp(() {
    Get.testMode = true;
    Get.put<OfflineCacheService>(FakeOfflineCacheService());
    Get.put<SyncService>(FakeSyncService());
    mockProfileCtrl = Get.put<ProfileMainScreenController>(FakeProfileMainScreenController()) as FakeProfileMainScreenController;
    controller = Get.put(SummaryController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Weather Timezone and Subscription Limit Tests', () {
    test('Date parsing constructs strict UTC DateTime independent of device timezone', () {
      // Mock forecast data with hourly entries
      final hours = [
        {'time': '2026-07-24T12:00:00+00:00'},
        {'time': '2026-07-25T00:00:00Z'},
        {'time': '2026-07-26T06:00:00-05:00'},
      ];

      controller.weatherData.value = {'hours': hours};
      
      // Accessing internal parsing logic through getSelectedDayNowEntry or _populateDaysList
      // Check that the dates are correctly identified
      mockProfileCtrl.premiumValue = true; // Premium user -> show all
      controller.populateDaysList(hours); // This will trigger _populateDaysList
      
      // Let's verify the populated days list
      // 2026-07-24 (Today)
      // 2026-07-25 (Sat 25)
      // 2026-07-26 (Sun 26)
      expect(controller.days.length, 3);
      expect(controller.days[0], 'Today');
      expect(controller.days[1], 'Sat 25');
      expect(controller.days[2], 'Sun 26');
    });

    test('Free Users: Limit weather forecast to maximum 3 days (Today + 2 days)', () {
      final hours = [
        {'time': '2026-07-24T12:00:00Z'},
        {'time': '2026-07-25T12:00:00Z'},
        {'time': '2026-07-26T12:00:00Z'},
        {'time': '2026-07-27T12:00:00Z'},
        {'time': '2026-07-28T12:00:00Z'},
      ];

      controller.weatherData.value = {'hours': hours};
      mockProfileCtrl.premiumValue = false; // Free user
      
      controller.populateDaysList(hours);
      
      // Today + 2 days = 3 days maximum
      expect(controller.days.length, 3);
      expect(controller.days[0], 'Today');
      expect(controller.days[1], 'Sat 25');
      expect(controller.days[2], 'Sun 26');
    });

    test('Premium Users: Show all forecast dates available from API', () {
      final hours = [
        {'time': '2026-07-24T12:00:00Z'},
        {'time': '2026-07-25T12:00:00Z'},
        {'time': '2026-07-26T12:00:00Z'},
        {'time': '2026-07-27T12:00:00Z'},
        {'time': '2026-07-28T12:00:00Z'},
      ];

      controller.weatherData.value = {'hours': hours};
      mockProfileCtrl.premiumValue = true; // Premium user
      
      controller.populateDaysList(hours);
      
      // All 5 days should be shown
      expect(controller.days.length, 5);
      expect(controller.days[0], 'Today');
      expect(controller.days[1], 'Sat 25');
      expect(controller.days[2], 'Sun 26');
      expect(controller.days[3], 'Mon 27');
      expect(controller.days[4], 'Tue 28');
    });
  });
}
