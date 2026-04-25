import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/main_screen/widgets/filter_dialog.dart';

import '../controller/map_screen_controller.dart';
import '../model/map_zone_model.dart';

class ZoneMapScreen extends GetView<MapScreenController> {
  const ZoneMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Real Satellite Map Layer
          FlutterMap(
            options: MapOptions(
              initialCenter: controller.mapCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.paytonpieper.app',
              ),
              
              // Tactical Grid Overlay
              _buildTacticalGrid(),

              // Active Zone Markers
              Obx(() => MarkerLayer(
                markers: controller.activeZones.map((zone) => _buildMarker(zone)).toList(),
              )),
            ],
          ),

          // 2. Tactical Tint Overlay
          IgnorePointer(
            child: Container(color: AppColors.backgroundDarkColor.withOpacity(0.35)),
          ),

          // 3. UI Elements
          _buildHeader(),
          _buildCompass(),
          _buildLegend(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // --- Sub-Widgets ---

  Marker _buildMarker(MapZoneModel zone) {
    return Marker(
      point: zone.location,
      width: 45.w,
      height: 45.w,
      child: Container(
        decoration: BoxDecoration(
          color: zone.color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: zone.level == ActivityLevel.high 
            ? [BoxShadow(color: zone.color, blurRadius: 15, spreadRadius: 2)] 
            : [],
        ),
        alignment: Alignment.center,
        child: Text(
          zone.count.toString(),
          style: getTextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTacticalGrid() {
    return MobileLayerTransformer(
      child: CustomPaint(
        painter: GridPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 60.h, left: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ZONE ACTIVITY MAP", style: getTextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Tap any zone to view offshore intel", style: getTextStyle(fontSize: 14, color: AppColors.blue00F0FFColor)),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return Positioned(
      top: 140.h, left: 20.w,
      child: CircleAvatar(
        radius: 25.r,
        backgroundColor: AppColors.blue1B2134Color.withOpacity(0.8),
        child: Icon(Icons.explore, color: AppColors.orangeColor, size: 28.sp),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 120.h, left: 20.w,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.blue153A56Color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendRow(AppColors.orangeColor, "High Activity"),
            _legendRow(AppColors.blue00F0FFColor, "Medium"),
            _legendRow(AppColors.grey516173Color, "Low"),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(Color color, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(width: 12.w, height: 12.h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          SizedBox(width: 8.w),
          Text(text, style: getTextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 120.h, right: 20.w,
      child: Column(
        children: [
   GestureDetector(
  onTap: () {
    Get.dialog(
      const FilterDialog(),
      barrierColor: Colors.black.withOpacity(0.5),
    );
  },
  child: _badgeButton(Icons.tune),
),
          SizedBox(height: 16.h),
          _gradientAddButton(),
        ],
      ),
    );
  }

  Widget _badgeButton(IconData icon) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        CircleAvatar(radius: 28.r, backgroundColor: AppColors.blue134D67Color, child: Icon(icon, color: Colors.white)),
        CircleAvatar(radius: 9.r, backgroundColor: Colors.red, child: Text("3", style: TextStyle(fontSize: 10.sp, color: Colors.white))),
      ],
    );
  }

  Widget _gradientAddButton() {
    return Container(
      width: 56.r, height: 56.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFFFF8C42), Color(0xFFE25301)]),
      ),
      child: Icon(Icons.add, color: Colors.white, size: 30.sp),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00F0FF).withOpacity(0.1)..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40.w) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i < size.height; i += 40.w) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}