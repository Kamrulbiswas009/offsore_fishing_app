import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:paytonpieper/core/utils/constants/colors.dart';

class GlobalRealMapBox extends StatelessWidget {
  final double height;
  final LatLng center;
  final double zoom;

  const GlobalRealMapBox({
    super.key,
    this.height = 200,
    required this.center,
    this.zoom = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: double.infinity,
      child: Stack(
        children: [
          mapbox.MapWidget(
            key: ValueKey(
              'global-mapbox-${center.latitude}-${center.longitude}',
            ),
            styleUri: mapbox.MapboxStyles.SATELLITE,
            cameraOptions: mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(center.longitude, center.latitude),
              ),
              zoom: zoom,
            ),
            onMapCreated: (mapboxMap) {
              mapboxMap.gestures.updateSettings(
                mapbox.GesturesSettings(
                  scrollEnabled: false,
                  pinchToZoomEnabled: false,
                  rotateEnabled: false,
                  pitchEnabled: false,
                  quickZoomEnabled: false,
                  doubleTapToZoomInEnabled: false,
                  doubleTouchToZoomOutEnabled: false,
                  pinchPanEnabled: false,
                ),
              );
            },
          ),

          IgnorePointer(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          Center(
            child: Container(
              height: 60.h,
              width: 60.h,
              decoration: BoxDecoration(
                color: AppColors.orangeColor.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.orangeColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orangeColor.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
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
                backgroundColor: Colors.black.withValues(alpha: 0.5),
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
    );
  }
}
