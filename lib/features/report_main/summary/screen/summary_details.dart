import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/global_map_box.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

import '../controller/summary_details_controller.dart';
import '../widgets/report_tab_widget.dart';
import '../widgets/summary_tab_widget.dart';
import '../widgets/weather_tab_widget.dart';

class SummaryScreen extends GetView<SummaryController> {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                const GlobalRealMapBox(
                  center: LatLng(25.7617, -80.1918),
                  zoom: 13.0,
                ),
                Positioned(
                  top: 50.h,
                  left: 20.w,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildTabSwitcher(),
                  SizedBox(height: 20.h),
                  Obx(() {
                    final selectedTab = controller.selectedTab.value;
                    if (selectedTab == 'Reports') {
                      return const ReportTabWidget();
                    }
                    if (selectedTab == 'Weather') {
                      return const WeatherTabWidget();
                    }
                    return const SummaryTabWidget();
                  }),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Row(
      children: ["Summary", "Reports", "Weather"]
          .map(
            (tab) => Expanded(
              child: Obx(
                () => GestureDetector(
                  onTap: () => controller.selectedTab.value = tab,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == tab
                          ? AppColors.tealColor117A88.withOpacity(0.4)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: controller.selectedTab.value == tab
                            ? AppColors.blue00F0FFColor
                            : AppColors.grey3A4B62Color,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab,
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
