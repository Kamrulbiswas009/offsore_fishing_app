import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/features/map/screen/zone_map_screen.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';
import '../controller/main_screen_controller.dart';
import '../widgets/custom_bottom_nav_bar.dart';
// Import your Map Screen here

class MainScreen extends GetView<MainScreenController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to flow behind the floating nav bar
      body: Stack(
        children: [
          // The body switches based on Nav Bar selection
          Obx(
            () => IndexedStack(
              index: controller.currentIndex.value,
              children: [
                const ZoneMapScreen(), // The Map Content (Code below)
                const SummaryScreen(),
                const Center(child: Text("Groups")),
                const Center(child: Text("Profile")),
              ],
            ),
          ),

          // Floating Bottom Navigation Bar
          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavBar(),
          ),
        ],
      ),
    );
  }
}
