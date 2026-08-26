import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/features/groups/presentation/screen/group_main_screen.dart';
import 'package:paytonpieper/features/map/screen/zone_map_screen.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/profile_main_screen.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';
import 'package:paytonpieper/core/common/widgets/offline_banner_widget.dart';
import '../controller/main_screen_controller.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainScreenController>();

    return Scaffold(
      extendBody: true, // Allows content to flow behind the floating nav bar
      body: Stack(
        children: [
          // The body switches based on Nav Bar selection (Lazy mounted)
          Obx(() {
            final currentIndex = controller.currentIndex.value;
            final loaded = controller.loadedIndices;

            return IndexedStack(
              index: currentIndex,
              children: [
                loaded.contains(0)
                    ? const ZoneMapScreen()
                    : const SizedBox.shrink(),
                loaded.contains(1)
                    ? const SummaryScreen(isReportMainScreen: true)
                    : const SizedBox.shrink(),
                loaded.contains(2)
                    ? SafeArea(
                        bottom: false,
                        child: GroupMainScreen(),
                      )
                    : const SizedBox.shrink(),
                loaded.contains(3)
                    ? ProfileMainScreen()
                    : const SizedBox.shrink(),
              ],
            );
          }),

          // Floating Offline Banner
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: OfflineBannerWidget(),
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(
              () => CustomBottomNavBar(
                currentIndex: controller.currentIndex.value,
                onTap: (index) {
                  controller.changeIndex(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
