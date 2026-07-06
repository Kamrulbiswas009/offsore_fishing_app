import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/report_catch2/controller/report_catch2_controller.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';
import 'package:paytonpieper/features/success_submit_report/screen/succes_screen.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';

class VisibilitySharingController extends GetxController {
  // Selection States
  var isPublicSelected = false.obs;
  var selectedGroups = <String>[].obs; // Stores IDs of selected groups

  // Mock Groups Data
  final List<Map<String, dynamic>> privateGroups = [
    {"id": "a0613eb0-3ca8-4522-9080-a83571dd7d81", "name": "Miami Offshore Crew", "members": 24},
    {"id": "a0613eb0-3ca8-4522-9080-a83571dd7d82", "name": "Keys Anglers", "members": 56},
    {"id": "a0613eb0-3ca8-4522-9080-a83571dd7d83", "name": "Tournament Team", "members": 8},
  ];

  void togglePublic() => isPublicSelected.value = !isPublicSelected.value;

  void toggleGroup(String id) {
    if (selectedGroups.contains(id)) {
      selectedGroups.remove(id);
    } else {
      selectedGroups.add(id);
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

    final syncService = Get.find<SyncService>();
    final report2Ctrl = Get.find<ReportCatch2Controller>();
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
              final primarySpecies = payload['species'].isNotEmpty
                  ? payload['species'][0]['speciesName']
                  : 'Catch Report';
              final zone = payload['zoneId'] ?? 'Unknown Zone';

              Get.offAll(
                () => const ReportSuccessScreen(),
                arguments: {
                  "species": primarySpecies,
                  "zone": zone,
                  "sharingInfo": visibility == "PUBLIC"
                      ? "Public Feed"
                      : "Private Group",
                },
              );
            } else {
              // Fail -> Save offline as fallback
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
