import 'package:flutter/material.dart';
import 'package:paytonpieper/features/groups/presentation/screen/group_main_screen.dart';
import 'package:paytonpieper/features/map/screen/zone_map_screen.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/profile_main_screen.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';
import '../widgets/custom_bottom_nav_bar.dart';
// Import your Map Screen here

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to flow behind the floating nav bar
      body: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            // The body switches based on Nav Bar selection
            IndexedStack(
              index: _currentIndex,
              children: [
                const ZoneMapScreen(), // The Map Content (Code below)
                const SummaryScreen(isReportMainScreen: true),
                GroupMainScreen(),
                ProfileMainScreen(),
              ],
            ),

            // Floating Bottom Navigation Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
