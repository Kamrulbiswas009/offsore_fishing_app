import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/report_catch2/controller/report_catch2_controller.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/routes/app_routes.dart';
import 'package:paytonpieper/features/report_main/summary/controller/summary_details_controller.dart';
import 'package:paytonpieper/features/map/controller/map_screen_controller.dart';

class VisibilitySharingController extends GetxController {
  // Selection States
  var isPublicSelected = false.obs;
  var selectedGroups = <String>[].obs; // Stores IDs of selected groups

  var privateGroups = <Map<String, dynamic>>[].obs;
  var isLoadingGroups = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    isLoadingGroups.value = true;
    try {
      final network = NetworkCaller();
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await network.cachedGetRequest(
        ApiConstants.featchGroupListApi,
        token: token,
        cacheKey: "group_list",
      );

      if (response.isSuccess) {
        final body = response.responseData;
        final rawList = body is Map ? body['data'] : null;
        if (rawList is List) {
          final mapped = rawList.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            final countMap = map['_count'] as Map?;
            final membersCount = countMap != null ? (countMap['members'] as num?)?.toInt() ?? 1 : 1;
            return {
              "id": map['groupId'] ?? '',
              "name": map['name'] ?? '',
              "members": membersCount,
            };
          }).toList();
          privateGroups.assignAll(mapped);
        }
      } else {
        AppLoggerHelper.error(
          '[VisibilitySharingController] fetchGroups failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[VisibilitySharingController] fetchGroups exception', e);
    } finally {
      isLoadingGroups.value = false;
    }
  }

  void togglePublic() => isPublicSelected.value = !isPublicSelected.value;

  void toggleGroup(String id) {
    if (selectedGroups.contains(id)) {
      selectedGroups.clear();
    } else {
      selectedGroups.assignAll([id]);
    }
  }

  bool get hasSelection => isPublicSelected.value || selectedGroups.isNotEmpty;

  void submitReport() {
    if (!hasSelection) {
      Get.snackbar(
        "Selection Required",
        "Please select at least one sharing option",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDA605C),
        colorText: Colors.white,
      );
      return;
    }

    final report2Ctrl = Get.find<ReportCatch2Controller>();
    final validationError = report2Ctrl.validateInputs();
    if (validationError != null) {
      Get.snackbar(
        "Required Field Missing",
        validationError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDA605C),
        colorText: Colors.white,
      );
      return;
    }

    final syncService = Get.find<SyncService>();
    final visibility = isPublicSelected.value ? "PUBLIC" : "PRIVATE";
    final groupId = selectedGroups.isNotEmpty
        ? selectedGroups.first.toString()
        : null;

    final payload = report2Ctrl.buildReportPayload(
      visibility: visibility,
      groupId: groupId,
    );

    if (syncService.isOnline.value) {
      Get.showOverlay(
        asyncFunction: () async {
          try {
            final network = NetworkCaller();
            final accessToken = StorageService.token;
            final token = (accessToken != null && accessToken.isNotEmpty)
                ? 'Bearer $accessToken'
                : null;

            final response = await network.postRequest(
              ApiConstants.submitReportApi,
              body: payload,
              token: token,
            );

            if (response.isSuccess) {
              AppLoggerHelper.info(
                "Report submitted online successfully. Response: ${response.responseData}",
              );
              final patterns = payload['fishingPatterns'];
              String primarySpecies = 'Catch Report';
              if (patterns is List && patterns.isNotEmpty) {
                final firstPattern = patterns[0];
                if (firstPattern is Map) {
                  final speciesList = firstPattern['species'];
                  if (speciesList is List && speciesList.isNotEmpty) {
                    primarySpecies = speciesList[0]['speciesName'] ?? 'Catch Report';
                  }
                }
              }
              final zone = payload['zoneId'] ?? 'Unknown Zone';

              final resData = response.responseData;
              String? reportId;
              if (resData is Map) {
                final dataMap = resData['data'];
                if (dataMap is Map) {
                  reportId = dataMap['reportId']?.toString() ?? dataMap['id']?.toString();
                } else {
                  reportId = resData['reportId']?.toString() ?? resData['id']?.toString();
                }
              }

              // Refresh controllers reactively
              if (Get.isRegistered<SummaryController>()) {
                final summaryController = Get.find<SummaryController>();
                summaryController.fetchReports(forceRefresh: true);
                summaryController.fetchSummary(forceRefresh: true);
                summaryController.fetchWeather(forceRefresh: true);
              }
              if (Get.isRegistered<MapScreenController>()) {
                Get.find<MapScreenController>().forceRefreshZones();
              }

              Get.offNamedUntil(
                AppRoute.succesScreen,
                (route) => route.isFirst,
                arguments: {
                  "species": primarySpecies,
                  "zone": zone,
                  "sharingInfo": visibility == "PUBLIC"
                      ? "Public Feed"
                      : "Private Group",
                  "reportId": reportId,
                },
              );
            } else {
              // Check if it is a client-side validation error (e.g. 400 or 422)
              if (response.statusCode == 400 || response.statusCode == 422) {
                AppLoggerHelper.error(
                  "Online report validation failed. StatusCode: ${response.statusCode}, Response: ${response.responseData}, Error: ${response.errorMessage}",
                );
                Get.snackbar(
                  "Submission Failed",
                  response.errorMessage.isNotEmpty
                      ? response.errorMessage
                      : "Invalid input data. Please check your submission.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFDA605C),
                  colorText: Colors.white,
                );
              } else {
                // Fail -> Save offline as fallback for network/server issues
                AppLoggerHelper.error(
                  "Online report submission failed. StatusCode: ${response.statusCode}, Response: ${response.responseData}, Error: ${response.errorMessage}",
                );
                await syncService.saveReportLocally(payload);
                Get.snackbar(
                  "Report Saved Offline",
                  "Submission failed (${response.statusCode}). Saved to local queue to sync later.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.orangeColor,
                  colorText: Colors.white,
                );
                Get.offAll(() => const OfflineReportsScreen());
              }
            }
          } catch (e) {
            // Exception -> Save offline as fallback
            AppLoggerHelper.error("Online report submission exception: $e");
            await syncService.saveReportLocally(payload);
            Get.snackbar(
              "Report Saved Offline",
              "An error occurred. Saved to local queue to sync later.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.orangeColor,
              colorText: Colors.white,
            );
            Get.offAll(() => const OfflineReportsScreen());
          }
        },
        loadingWidget: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeColor),
          ),
        ),
      );
    } else {
      // Save offline directly
      syncService.saveReportLocally(payload).then((_) {
        Get.snackbar(
          "Offline Mode",
          "Device is offline. Report saved to sync later.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.orangeColor,
          colorText: Colors.white,
        );
        Get.offAll(() => const OfflineReportsScreen());
      });
    }
  }
}
