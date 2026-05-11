import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/services/permissions/location_permission_service.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/main_screen/widgets/filter_dialog.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';

import '../controller/map_screen_controller.dart';
import '../model/map_zone_model.dart';

class ZoneMapScreen extends StatefulWidget {
  /// When [isLocationPickerMode] is true the map acts as a location picker.
  /// Tapping any point on the map calls [onLocationPicked] with the lat/lng
  /// and the caller is responsible for navigating away.
  final bool isLocationPickerMode;
  final void Function(double lat, double lng)? onLocationPicked;

  const ZoneMapScreen({
    super.key,
    this.isLocationPickerMode = false,
    this.onLocationPicked,
  });

  @override
  State<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends State<ZoneMapScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<MapScreenController>();
  final _locationService = LocationPermissionService();

  late final AnimationController _panelAnim;
  late final Animation<Offset> _slideAnim;

  mapbox.MapboxMap? _mapboxMap;
  mapbox.ViewportState? _viewportState;
  bool _layersReady = false;
  bool _isLocating = false; // prevents double-tap on location button
  Timer? _gridDebounce;

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
  }

  @override
  void dispose() {
    _gridDebounce?.cancel();
    _panelAnim.dispose();
    super.dispose();
  }

  // ── Map lifecycle ────────────────────────────────────────────────────────

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _mapboxMap = map;
  }

  Future<void> _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    if (_layersReady) return;
    _layersReady = true;
    await controller.setupMapLayers(_mapboxMap!);
    // Enable native Mapbox location puck (blue pulsing dot)
    await _enableLocationComponent();
    // Populate grid for the initial camera position
    await _updateGridForViewport();
  }

  // ── Location component (native Mapbox puck) ──────────────────────────────

  Future<void> _enableLocationComponent() async {
    final map = _mapboxMap;
    if (map == null) return;
    try {
      await map.location.updateSettings(
        mapbox.LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          pulsingColor: const Color(0xFF00F0FF).value, // cyan pulsing ring
          pulsingMaxRadius: 60.0,
          showAccuracyRing: true,
          accuracyRingColor: const Color(0x2200F0FF).value,
          accuracyRingBorderColor: const Color(0x8800F0FF).value,
        ),
      );
    } catch (_) {
      // Location component unavailable (e.g. simulator without location)
    }
  }

  /// Requests permission then flies camera to the device position.
  Future<void> _goToMyLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final result = await _locationService.requestLocationWhenInUse();

      if (result != LocationPermissionResult.granted) {
        Get.snackbar(
          'Location Access',
          result == LocationPermissionResult.permanentlyDenied
              ? 'Location permission denied. Enable it in Settings.'
              : 'Location permission is required to find your position.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.blue0D2B43Color,
          colorText: Colors.white,
          margin: EdgeInsets.all(16.w),
          borderRadius: 14.r,
          duration: const Duration(seconds: 3),
          icon: Icon(Icons.location_off, color: AppColors.blue00F0FFColor),
        );
        return;
      }

      final map = _mapboxMap;
      if (map == null) return;

      // Get current position via Mapbox's location provider
      final style = await map.style.isStyleLoaded();
      if (!style) return;

      // Enable location component (ensure it's on)
      await _enableLocationComponent();
      // Fly to current position using Mapbox location manager
      // We use setCamera because LocationComponent keeps the puck position internally
      await map.location.updateSettings(
        mapbox.LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          pulsingColor: const Color(0xFF00F0FF).value,
          pulsingMaxRadius: 60.0,
          showAccuracyRing: true,
          accuracyRingColor: const Color(0x2200F0FF).value,
          accuracyRingBorderColor: const Color(0x8800F0FF).value,
        ),
      );

      // Use permission_handler to get coordinates, then fly camera
      await _flyToDeviceLocation(map);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  /// Uses the platform location API (via permission_handler ecosystem) to
  /// retrieve current coordinates and animate the camera there.
  Future<void> _flyToDeviceLocation(mapbox.MapboxMap map) async {
    try {
      // Mapbox LocationComponent stores position internally;
      // we animate camera by enabling tracking mode via StyleManager.
      // As a cross-platform alternative we request through Mapbox viewport.
      await map.easeTo(
        mapbox.CameraOptions(zoom: 12.0),
        mapbox.MapAnimationOptions(duration: 800),
      );

      // Access the device location through the system
      // Mapbox LocationComponent can provide the last known position via
      // setting the camera to follow the puck.
      // We set followPuckViewportState to center on user.
      // Since direct coordinate access needs geolocator, we use
      // a workaround: Mapbox handles internally via its own location engine.
      await map.location.updateSettings(
        mapbox.LocationComponentSettings(
          enabled: true,
          puckBearingEnabled: true,
          pulsingEnabled: true,
          pulsingColor: const Color(0xFF00F0FF).value,
          pulsingMaxRadius: 60.0,
          showAccuracyRing: true,
          accuracyRingColor: const Color(0x2200F0FF).value,
          accuracyRingBorderColor: const Color(0x8800F0FF).value,
        ),
      );

      // Use Mapbox's viewport to follow the puck
      // This is the idiomatic way without an extra geolocator package
      setStateWithViewportAnimation(
        () {
          _viewportState = mapbox.FollowPuckViewportState(
            zoom: 12.0,
            bearing: mapbox.FollowPuckViewportStateBearingConstant(0.0),
            pitch: 0.0,
          );
        },
        transition: mapbox.DefaultViewportTransition(
          maxDuration: const Duration(milliseconds: 1500),
        ),
      );
    } catch (_) {
      // Viewport transition or location unavailable — silently ignore
    }
  }

  // ── Camera change → grid refresh ────────────────────────────────────────

  void _onCameraChange(mapbox.CameraChangedEventData _) {
    _gridDebounce?.cancel();
    _gridDebounce = Timer(
      const Duration(milliseconds: 150),
      _updateGridForViewport,
    );
  }

  Future<void> _updateGridForViewport() async {
    final map = _mapboxMap;
    if (map == null || !_layersReady) return;
    try {
      // Get current camera state
      final cam = await map.getCameraState();

      // Derive viewport bounds from camera state
      final bounds = await map.coordinateBoundsForCamera(
        mapbox.CameraOptions(
          center: cam.center,
          zoom: cam.zoom,
          bearing: cam.bearing,
          pitch: cam.pitch,
          padding: mapbox.MbxEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        ),
      );

      final sw = LatLng(
        bounds.southwest.coordinates.lat.toDouble(),
        bounds.southwest.coordinates.lng.toDouble(),
      );
      final ne = LatLng(
        bounds.northeast.coordinates.lat.toDouble(),
        bounds.northeast.coordinates.lng.toDouble(),
      );

      await controller.updateGridForBounds(map, sw, ne);
    } catch (_) {
      // Skip transient errors during style/camera transitions
    }
  }

  // ── Tap handling ─────────────────────────────────────────────────────────

  Future<void> _onMapTap(mapbox.MapContentGestureContext ctx) async {
    final coord = ctx.point.coordinates;
    final lat = coord.lat.toDouble();
    final lng = coord.lng.toDouble();

    // ── Location-picker mode ─────────────────────────────────────────────
    if (widget.isLocationPickerMode) {
      widget.onLocationPicked?.call(lat, lng);
      return;
    }

    // ── Normal zone-detail mode ──────────────────────────────────────────
    final zone = controller.zoneForCoordinate(lat, lng);
    if (zone != null) {
      controller.selectZone(zone);
      _panelAnim.forward(from: 0);
    } else {
      _dismissPanel();
    }
  }

  void _dismissPanel() {
    _panelAnim.reverse().then((_) => controller.deselectZone());
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isPickerMode = widget.isLocationPickerMode;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Mapbox widget ──────────────────────────────────────────────
          mapbox.MapWidget(
            key: const ValueKey('zone-mapbox-widget'),
            styleUri: mapbox.MapboxStyles.SATELLITE_STREETS,
            viewport: _viewportState,
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
            onStyleLoadedListener: _onStyleLoaded,
            onCameraChangeListener: _onCameraChange,
            onTapListener: _onMapTap,
          ),

          // ── Marine dark overlay
          IgnorePointer(
            child: Container(
              color: AppColors.backgroundDarkColor.withValues(alpha: 0.25),
            ),
          ),

          // ── Fixed UI chrome
          _buildHeader(isPickerMode: isPickerMode),
          _buildLegend(),
          if (!isPickerMode) _buildActionButtons(),

          // ── Back button for picker mode
          if (isPickerMode) _buildPickerBackButton(),
          // ── My Location FAB (picker mode only)
          if (isPickerMode) _buildMyLocationButton(),
          // ── Zone detail panel (normal mode only)
          if (!isPickerMode)
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

  // ── UI widgets

  Widget _buildHeader({bool isPickerMode = false}) {
    return Positioned(
      top: 60.h,
      left: isPickerMode ? 70.w : 20.w,
      right: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPickerMode ? 'SELECT LOCATION' : 'ZONE ACTIVITY MAP',
            style: getTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            isPickerMode
                ? 'Tap anywhere on the map to select your grid location'
                : 'Tap any zone to view offshore intel',
            style: getTextStyle(fontSize: 13, color: AppColors.blue00F0FFColor),
          ),
        ],
      ),
    );
  }

  /// Back button shown only in picker mode
  Widget _buildPickerBackButton() {
    return Positioned(
      top: 60.h,
      left: 16.w,
      child: CircleAvatar(
        backgroundColor: AppColors.blue1B2134Color,
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
          onPressed: () => Get.back(),
        ),
      ),
    );
  }

  /// Raw location button widget
  Widget _myLocationButtonWidget() {
    return GestureDetector(
      onTap: _goToMyLocation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56.r,
        height: 56.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isLocating
              ? AppColors.teal163A42Color
              : AppColors.blue0D2B43Color,
          border: Border.all(color: AppColors.blue00F0FFColor, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue00F0FFColor.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: _isLocating
            ? Padding(
                padding: EdgeInsets.all(16.r),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.blue00F0FFColor,
                ),
              )
            : Icon(
                Icons.my_location,
                color: AppColors.blue00F0FFColor,
                size: 24.sp,
              ),
      ),
    );
  }

  /// Floating "My Location" button — visible in picker mode.
  Widget _buildMyLocationButton() {
    return Positioned(
      top: 120.h,
      right: 20.w,
      child: _myLocationButtonWidget(),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 85.h,
      left: 20.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.blue153A56Color),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ACTIVITY',
              style: getTextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.blue00F0FFColor,
              ),
            ),
            SizedBox(height: 8.h),
            _legendRow(AppColors.orangeColor, 'High'),
            _legendRow(AppColors.blue00F0FFColor, 'Medium'),
            _legendRow(AppColors.grey516173Color, 'Low'),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(label, style: getTextStyle(fontSize: 12, color: Colors.white)),
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
          _myLocationButtonWidget(),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => Get.dialog(
              const FilterDialog(),
              barrierColor: Colors.black.withValues(alpha: 0.5),
            ),
            child: _filterButton(),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => Get.to(ReportCatchStep1Screen()),
            child: _addButton(),
          ),
        ],
      ),
    );
  }

  Widget _filterButton() {
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

  Widget _addButton() {
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

// ── Zone Detail Panel

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
        border: const Border(top: BorderSide(color: Color(0xFF1E3A4C))),
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
          // drag handle
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

          // name + close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        zone.name,
                        style: getTextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

          // activity score
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

          // metric cards
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

          // trend
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

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              onPressed: () =>
                  Get.to(() => SummaryScreen(isReportMainScreen: false)),
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
}
