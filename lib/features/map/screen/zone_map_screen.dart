import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/main_screen/widgets/filter_dialog.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';

import '../controller/map_screen_controller.dart';
import '../model/map_zone_model.dart';

class ZoneMapScreen extends StatefulWidget {
  const ZoneMapScreen({super.key});

  @override
  State<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends State<ZoneMapScreen>
    with TickerProviderStateMixin {
  final controller = Get.find<MapScreenController>();

  late final AnimationController _panelAnim;
  late final Animation<Offset> _slideAnim;
  late final AnimationController _pulseAnim;
  late final Animation<double> _pulseScale;

  mapbox.MapboxMap? _mapboxMap;
  Worker? _zonesWorker;
  Timer? _markerProjectionDebounce;
  final Map<String, Offset> _markerOffsets = <String, Offset>{};

  @override
  void initState() {
    super.initState();

    _panelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelAnim, curve: Curves.easeOutCubic));

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));

    _zonesWorker = ever(
      controller.activeZones,
      (_) => _scheduleMarkerProjection(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleMarkerProjection();
    });
  }

  @override
  void dispose() {
    _markerProjectionDebounce?.cancel();
    _zonesWorker?.dispose();
    _panelAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  void _onMapCreated(mapbox.MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _scheduleMarkerProjection();
  }

  void _onZoneTap(MapZoneModel zone) {
    controller.selectZone(zone);
    _panelAnim.forward(from: 0);
  }

  void _dismissPanel() {
    _panelAnim.reverse().then((_) => controller.deselectZone());
  }

  void _scheduleMarkerProjection() {
    _markerProjectionDebounce?.cancel();
    _markerProjectionDebounce = Timer(const Duration(milliseconds: 16), () {
      unawaited(_refreshMarkerOffsets());
    });
  }

  Future<void> _refreshMarkerOffsets() async {
    final mapboxMap = _mapboxMap;
    if (!mounted || mapboxMap == null || controller.activeZones.isEmpty) {
      return;
    }

    try {
      final pixels = await mapboxMap.pixelsForCoordinates(
        controller.activeZones.map(_pointForZone).toList(),
      );

      if (!mounted) {
        return;
      }

      final offsets = <String, Offset>{};
      for (var i = 0; i < controller.activeZones.length; i++) {
        final pixel = pixels[i];
        if (pixel == null) {
          continue;
        }
        offsets[controller.activeZones[i].id] = Offset(pixel.x, pixel.y);
      }

      setState(() {
        _markerOffsets
          ..clear()
          ..addAll(offsets);
      });
    } catch (_) {
      // Skip transient map projection errors while the style/camera is settling.
    }
  }

  mapbox.Point _pointForZone(MapZoneModel zone) {
    return mapbox.Point(
      coordinates: mapbox.Position(
        zone.location.longitude,
        zone.location.latitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markerSize = 50.w;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          mapbox.MapWidget(
            key: const ValueKey('zone-mapbox-widget'),
            styleUri: mapbox.MapboxStyles.SATELLITE_STREETS,
            cameraOptions: mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(
                  controller.mapCenter.longitude,
                  controller.mapCenter.latitude,
                ),
              ),
              zoom: 9.5,
            ),
            onMapCreated: _onMapCreated,
            onMapLoadedListener: (_) => _scheduleMarkerProjection(),
            onMapIdleListener: (_) => _scheduleMarkerProjection(),
            onCameraChangeListener: (_) => _scheduleMarkerProjection(),
            onTapListener: (_) => _dismissPanel(),
          ),

          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
          ),

          ClipRect(
            child: Obx(
              () => Stack(
                children: controller.activeZones.map((zone) {
                  final offset = _markerOffsets[zone.id];
                  if (offset == null) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: offset.dx - (markerSize / 2),
                    top: offset.dy - (markerSize / 2),
                    width: markerSize,
                    height: markerSize,
                    child: GestureDetector(
                      onTap: () => _onZoneTap(zone),
                      child: Obx(() {
                        final isSelected =
                            controller.selectedZone.value?.id == zone.id;
                        if (isSelected) {
                          return AnimatedBuilder(
                            animation: _pulseScale,
                            builder: (_, child) => Transform.scale(
                              scale: _pulseScale.value,
                              child: child,
                            ),
                            child: _MarkerBox(zone: zone, isSelected: true),
                          );
                        }
                        return _MarkerBox(zone: zone, isSelected: false);
                      }),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          IgnorePointer(
            child: Container(
              color: AppColors.backgroundDarkColor.withValues(alpha: 0.30),
            ),
          ),

          _buildHeader(),
          _buildCompass(),
          _buildLegend(),
          _buildActionButtons(),

          Obx(() {
            final zone = controller.selectedZone.value;
            if (zone == null) return const SizedBox.shrink();
            return Positioned(
              bottom: 60.h,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnim,
                child: _ZoneDetailPanel(zone: zone, onClose: _dismissPanel),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 60.h,
      left: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ZONE ACTIVITY MAP',
            style: getTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Tap any zone to view offshore intel',
            style: getTextStyle(fontSize: 14, color: AppColors.blue00F0FFColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return Positioned(
      top: 140.h,
      left: 20.w,
      child: CircleAvatar(
        radius: 25.r,
        backgroundColor: AppColors.blue1B2134Color.withValues(alpha: 0.85),
        child: Icon(Icons.explore, color: AppColors.orangeColor, size: 28.sp),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 85.h,
      left: 20.w,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.blue153A56Color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legendRow(AppColors.orangeColor, 'High Activity'),
            _legendRow(AppColors.blue00F0FFColor, 'Medium'),
            _legendRow(AppColors.grey516173Color, 'Low'),
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
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8.w),
          Text(text, style: getTextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 85.h,
      right: 20.w,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Get.dialog(
              const FilterDialog(),
              barrierColor: Colors.black.withValues(alpha: 0.5),
            ),
            child: _badgeButton(Icons.tune),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              Get.to(ReportCatchStep1Screen());
            },
            child: _gradientAddButton(),
          ),
        ],
      ),
    );
  }

  Widget _badgeButton(IconData icon) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blue00D4FFColor, width: 1.5.w),
          ),
          child: CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColors.blue134D67Color,
            child: Image.asset(IconPath.filterIcon, height: 33.h, width: 33.w),
          ),
        ),
        CircleAvatar(
          radius: 9.r,
          backgroundColor: Colors.red,
          child: Text(
            '3',
            style: TextStyle(fontSize: 10.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _gradientAddButton() {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C42), Color(0xFFE25301)],
        ),
      ),
      child: Icon(Icons.add, color: Colors.white, size: 30.sp),
    );
  }
}

class _MarkerBox extends StatelessWidget {
  final MapZoneModel zone;
  final bool isSelected;
  const _MarkerBox({required this.zone, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: zone.color.withValues(alpha: isSelected ? 1.0 : 0.85),
        borderRadius: BorderRadius.circular(6.r),
        border: isSelected
            ? Border.all(color: const Color(0xFFFF8C42), width: 2.5)
            : Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFFFF8C42).withValues(alpha: 0.8),
              blurRadius: 18,
              spreadRadius: 4,
            )
          else if (zone.level == ActivityLevel.high)
            BoxShadow(
              color: zone.color.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        zone.count.toString(),
        style: getTextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.12)
      ..strokeWidth = 0.6;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ZoneDetailPanel extends StatelessWidget {
  final MapZoneModel zone;
  final VoidCallback onClose;
  const _ZoneDetailPanel({required this.zone, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final trendColor = zone.trend == TrendDirection.rising
        ? const Color(0xFF00E676)
        : zone.trend == TrendDirection.falling
        ? const Color(0xFFFF5252)
        : Colors.white70;
    final trendIcon = zone.trend == TrendDirection.rising
        ? Icons.trending_up
        : zone.trend == TrendDirection.falling
        ? Icons.trending_down
        : Icons.trending_flat;
    final trendLabel = zone.trend == TrendDirection.rising
        ? 'Rising'
        : zone.trend == TrendDirection.falling
        ? 'Falling'
        : 'Stable';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: const Border(
          top: BorderSide(color: Color(0xFF1E3A4C), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDynamicZoneName(zone.name, fontSize: 26),
                    SizedBox(height: 4.h),
                    Text(
                      '${zone.reports} reports  •  Last updated ${zone.lastUpdated}',
                      style: getTextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white12,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF121F2E),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activity Score',
                      style: getTextStyle(fontSize: 14, color: Colors.white54),
                    ),
                    Text(
                      '${(zone.activityScore * 100).round()}%',
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF8C42),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: zone.activityScore,
                    minHeight: 10.h,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8C42)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.set_meal,
                  label: 'Top Species',
                  value: zone.topSpecies,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _metricCard(
                  icon: Icons.water,
                  label: 'Avg Depth',
                  value: zone.avgDepth,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFF121F2E),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Icon(trendIcon, color: trendColor, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  'Trend: ',
                  style: getTextStyle(fontSize: 14, color: Colors.white54),
                ),
                Text(
                  trendLabel,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00D4FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              onPressed: () {
                Get.to(() => SummaryScreen(isReportMainScreen: false));
              },
              child: Text(
                'View Full Details',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF121F2E),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00F0FF), size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getTextStyle(fontSize: 12, color: Colors.white54),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicZoneName(String text, {double fontSize = 26}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        style: getTextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
