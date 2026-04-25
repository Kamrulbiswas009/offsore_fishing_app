import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';


class GlobalRealMapBox extends StatelessWidget {
  final double height;
  final LatLng center; // Real coordinates
  final double zoom;

  const GlobalRealMapBox({
    super.key,
    this.height = 250,
    required this.center, // e.g. LatLng(25.7617, -80.1918)
    this.zoom = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: double.infinity,
      child: Stack(
        children: [
          // 1. REAL SATELLITE MAP LAYER
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none, // Lock map interaction for the header box
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.paytonpieper.app',
              ),
            ],
          ),

          // 2. TACTICAL OVERLAY (Dark Tint)
          IgnorePointer(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 3. ORANGE HIGHLIGHTED ZONE SQUARE (Tactical UI)
          Center(
            child: Container(
              height: 100.h,
              width: 100.h,
              decoration: BoxDecoration(
                color: AppColors.orangeColor.withOpacity(0.15),
                border: Border.all(color: AppColors.orangeColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orangeColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
            ),
          ),

          // 4. TOP NAVIGATION (Back Button)
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.black.withOpacity(0.5),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}