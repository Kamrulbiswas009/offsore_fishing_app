import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

String _localNoonIso(DateTime day) {
  final noon = DateTime(day.year, day.month, day.day, 12);
  return noon.toUtc().toIso8601String();
}

String _dayLabel(DateTime day) => DateFormat('EEE d').format(day);

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
    test('Date parsing converts API timestamps to local calendar days', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final d1 = today.add(const Duration(days: 1));
      final d2 = today.add(const Duration(days: 2));

      final hours = [
        {'time': _localNoonIso(today)},
        {'time': _localNoonIso(d1)},
        {'time': _localNoonIso(d2)},
      ];

      controller.weatherData.value = {'hours': hours};
      mockProfileCtrl.premiumValue = true;
      controller.populateDaysList(hours);

      expect(controller.days.length, 3);
      expect(controller.days[0], 'Today');
      expect(controller.days[1], _dayLabel(d1));
      expect(controller.days[2], _dayLabel(d2));
    });

    test('Free Users: Limit weather forecast to maximum 3 days (Today + 2 days)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final hours = List.generate(5, (i) {
        return {'time': _localNoonIso(today.add(Duration(days: i)))};
      });

      controller.weatherData.value = {'hours': hours};
      mockProfileCtrl.premiumValue = false;

      controller.populateDaysList(hours);

      expect(controller.days.length, 3);
      expect(controller.days[0], 'Today');
      expect(controller.days[1], _dayLabel(today.add(const Duration(days: 1))));
      expect(controller.days[2], _dayLabel(today.add(const Duration(days: 2))));
    });

    test('Premium Users: Show all forecast dates available from API', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final hours = List.generate(5, (i) {
        return {'time': _localNoonIso(today.add(Duration(days: i)))};
      });

      controller.weatherData.value = {'hours': hours};
      mockProfileCtrl.premiumValue = true;

      controller.populateDaysList(hours);

      expect(controller.days.length, 5);
      expect(controller.days[0], 'Today');
      expect(controller.days[1], _dayLabel(today.add(const Duration(days: 1))));
      expect(controller.days[2], _dayLabel(today.add(const Duration(days: 2))));
      expect(controller.days[3], _dayLabel(today.add(const Duration(days: 3))));
      expect(controller.days[4], _dayLabel(today.add(const Duration(days: 4))));
    });

    test('Yesterday is never shown as a forecast day chip', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      // UTC midnight of "today" is still yesterday evening in US timezones.
      final utcMidnightToday =
          DateTime.utc(today.year, today.month, today.day).toIso8601String();

      final hours = [
        {'time': _localNoonIso(yesterday)},
        {'time': utcMidnightToday},
        {'time': _localNoonIso(today)},
        {'time': _localNoonIso(tomorrow)},
      ];

      controller.weatherData.value = {'hours': hours};
      mockProfileCtrl.premiumValue = true;
      controller.populateDaysList(hours);

      expect(controller.days.first, 'Today');
      expect(controller.days, isNot(contains(_dayLabel(yesterday))));
      expect(controller.days, contains(_dayLabel(tomorrow)));
    });

    test('extractSgValue prefers StormGlass sg over NOAA/ECMWF/DWD', () {
      expect(
        controller.extractSgValue({
          'ecmwf': 28.05,
          'noaa': 23.29,
          'dwd': 24.1,
          'sg': 27.5,
        }),
        27.5,
      );
      expect(controller.extractSgValue({'noaa': 10.0}), 10.0);
      expect(controller.extractSgValue(12.3), 12.3);
      expect(controller.extractSgValue(null), isNull);
    });
  });
}
