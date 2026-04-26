import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/main_screen/widgets/filter_dialog.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';

import '../controller/map_screen_controller.dart';
import '../model/map_zone_model.dart';

// ─── Mapbox API Key ────────────────────────────────────────────────────────────
const _mapboxToken =
    'pk.eyJ1Ijoib250aGViaXRlIiwiYSI6ImNtb2VheTVndjA3YzAycXE0NnJkcXFremQifQ.KLolpMGFvBjx0-zJe4njCA';

const _mapboxSatelliteUrl =
    'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/{z}/{x}/{y}?access_token=$_mapboxToken';

// ─── Screen ────────────────────────────────────────────────────────────────────
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
  }

  @override
  void dispose() {
    _panelAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  void _onZoneTap(MapZoneModel zone) {
    controller.selectZone(zone);
    _panelAnim.forward(from: 0);
  }

  void _dismissPanel() {
    _panelAnim.reverse().then((_) => controller.deselectZone());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. Mapbox Satellite Map ──────────────────────────────────────
          FlutterMap(
            options: MapOptions(
              initialCenter: controller.mapCenter,
              initialZoom: 9.5,
              onTap: (tapPos, latLng) => _dismissPanel(),
            ),
            children: [
              TileLayer(
                urlTemplate: _mapboxSatelliteUrl,
                tileDimension: 512,
                zoomOffset: -1,
                userAgentPackageName: 'com.paytonpieper.app',
                additionalOptions: const {'access_token': _mapboxToken},
              ),

              // Tactical Grid Overlay
              _TacticalGridLayer(),

              // Zone Markers (interactive)
              Obx(
                () => MarkerLayer(
                  markers: controller.activeZones
                      .map((z) => _buildMarker(z))
                      .toList(),
                ),
              ),
            ],
          ),

          // ── 2. Dark tint ─────────────────────────────────────────────────
          IgnorePointer(
            child: Container(
              color: AppColors.backgroundDarkColor.withValues(alpha: 0.30),
            ),
          ),

          // ── 3. Header ────────────────────────────────────────────────────
          _buildHeader(),

          // ── 4. Compass ───────────────────────────────────────────────────
          _buildCompass(),

          // ── 5. Legend ────────────────────────────────────────────────────
          _buildLegend(),

          // ── 6. Action Buttons ────────────────────────────────────────────
          _buildActionButtons(),

          // ── 7. Bottom Detail Panel ───────────────────────────────────────
          Obx(() {
            final zone = controller.selectedZone.value;
            if (zone == null) return const SizedBox.shrink();
            // Sit panel above the floating nav bar (75.h bar + 25.h margin)
            return Positioned(
              bottom: 100.h,
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

  // ─── Marker builder ────────────────────────────────────────────────────────
  Marker _buildMarker(MapZoneModel zone) {
    return Marker(
      point: zone.location,
      width: 50.w,
      height: 50.w,
      child: GestureDetector(
        onTap: () => _onZoneTap(zone),
        child: Obx(() {
          final isSelected = controller.selectedZone.value?.id == zone.id;
          if (isSelected) {
            return AnimatedBuilder(
              animation: _pulseScale,
              builder: (_, child) =>
                  Transform.scale(scale: _pulseScale.value, child: child),
              child: _MarkerBox(zone: zone, isSelected: true),
            );
          }
          return _MarkerBox(zone: zone, isSelected: false);
        }),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────
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

  // ─── Compass ───────────────────────────────────────────────────────────────
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

  // ─── Legend ────────────────────────────────────────────────────────────────
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

  // ─── Action Buttons ────────────────────────────────────────────────────────
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
            border: Border.all(
              color: AppColors.blue00D4FF66Color,
              width: 1.5.w,
            ),
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

// ─── Marker Box ───────────────────────────────────────────────────────────────
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

// ─── Tactical Grid Layer ──────────────────────────────────────────────────────
class _TacticalGridLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MobileLayerTransformer(
      child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.12)
      ..strokeWidth = 0.6;
    final step = 40.0;
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

// ─── Zone Detail Panel ────────────────────────────────────────────────────────
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
          // ── Handle bar ────────────────────────────────────────────────
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

          // ── Title row ─────────────────────────────────────────────────
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
                  decoration: BoxDecoration(
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

          // ── Activity Score ────────────────────────────────────────────
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
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: zone.activityScore,
                    minHeight: 8.h,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      zone.activityScore > 0.7
                          ? const Color(0xFFFF8C42)
                          : zone.activityScore > 0.4
                          ? const Color(0xFF00F0FF)
                          : const Color(0xFF516173),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // ── Stat Cards ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Top Species',
                  value: zone.topSpecies,
                  valueColor: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'Avg Depth',
                  value: zone.avgDepth,
                  valueColor: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'Trend',
                  value: trendLabel,
                  valueColor: trendColor,
                  leadingIcon: Icon(trendIcon, color: trendColor, size: 16.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── View Full Details Button ──────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00D4F5), Color(0xFF00AACC)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/summary-details', arguments: zone);
                  },
                  splashColor: Colors.white24,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: Center(
                      child: Text(
                        'View Full Details',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 8.h),
        ],
      ),
    );
  }

  Widget _buildDynamicZoneName(String name, {required double fontSize}) {
    final parts = name.split('-');
    if (parts.length >= 2) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: parts[0],
              style: getTextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: '-${parts.sublist(1).join("-")}',
              style: getTextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.blue00F0FFColor,
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      name,
      style: getTextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Widget? leadingIcon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF121F2E),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: getTextStyle(fontSize: 11, color: Colors.white38)),
          SizedBox(height: 6.h),
          Row(
            children: [
              if (leadingIcon != null) ...[leadingIcon!, SizedBox(width: 4.w)],
              Flexible(
                child: Text(
                  value,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
