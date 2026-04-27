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
  final bool isReportMainScreen;
  const SummaryScreen({super.key, required this.isReportMainScreen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  const GlobalRealMapBox(
                    center: LatLng(25.76721, -80.1918),
                    zoom: 13.0,
                  ),
                  // Positioned(
                  //   top: 50.h,
                  //   left: 20.w,
                  //   child: GestureDetector(
                  //     onTap: () => Get.back(),
                  //     child: CircleAvatar(
                  //       radius: 20.r,
                  //       backgroundColor: Colors.black.withOpacity(0.5),
                  //       child: const Icon(
                  //         Icons.arrow_back,
                  //         color: Colors.white,
                  //         size: 20,
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                      return  SummaryTabWidget(isReportMainScreen: isReportMainScreen,);
                    }),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final tabs = ["Summary", "Reports", "Weather"];

    return Obx(
      () => Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = controller.selectedTab.value == tab;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == tabs.length - 1 ? 0 : 12.w,
              ),
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = tab,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 40.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.tealColor117A88
                        : AppColors.transparentColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.tealColor117A88
                          : AppColors.grey516173Color,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.tealColor117A88.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 18,
                              offset: const Offset(10, 10),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    tab,
                    style: getTextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
