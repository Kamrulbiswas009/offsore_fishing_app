import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class OfflineBannerWidget extends StatelessWidget {
  const OfflineBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = Get.find<SyncService>();

    return Obx(() {
      if (syncService.isOnline.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        color: AppColors.orangeColor.withOpacity(0.95),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: AppColors.whiteColor,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              "Offline Mode — Showing Cached Data",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
