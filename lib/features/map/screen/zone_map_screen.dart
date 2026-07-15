// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/main_screen/widgets/filter_dialog.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';
import 'package:paytonpieper/core/services/sync_service.dart';

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

  late final AnimationController _panelAnim;
  late final Animation<Offset> _slideAnim;

  mapbox.MapboxMap? _mapboxMap;
  mapbox.ViewportState? _viewportState;
  bool _layersReady = false;
  bool _isLocating = false; // prevents double-tap on location button
  Timer? _gridDebounce;
  double _bearing = 0.0;

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

    // Reactively refresh grid when zones are loaded/updated from API
    ever(controller.activeZones, (_) {
      final map = _mapboxMap;
      if (map != null && _layersReady) {
        controller.refreshGridOnMap(map);
      }
    });
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
    
    // Check if offline to log mapbox offline loading
    try {
      final syncService = Get.find<SyncService>();
      if (!syncService.isOnline.value) {
        debugPrint('[ZoneMapScreen] Offline detected. Mapbox will serve cached offline TileRegion and StylePack.');
      }
    } catch (_) {}

    await map.gestures.updateSettings(
      mapbox.GesturesSettings(
        scrollEnabled: true,
        pinchToZoomEnabled: true,
        rotateEnabled: true,
        pitchEnabled: true,
        doubleTapToZoomInEnabled: true,
        doubleTouchToZoomOutEnabled: true,
        quickZoomEnabled: true,
        pinchPanEnabled: true,
      ),
    );
  }

  Future<void> _onStyleLoaded(mapbox.StyleLoadedEventData _) async {
    if (_layersReady) return;
    _layersReady = true;
    await controller.setupMapLayers(_mapboxMap!);
    // Populate grid for the initial camera position
    await _updateGridForViewport();
  }



  /// Requests permission then flies camera to the device position.
  Future<void> _goToMyLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final map = _mapboxMap;
      if (map == null) return;

      final style = await map.style.isStyleLoaded();
      if (!style) return;

      // Animate camera to the Gulf of Mexico offshore (mock device location)
      await map.easeTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              controller.mapCenter.longitude,
              controller.mapCenter.latitude,
            ),
          ),
          zoom: 10.0,
        ),
        mapbox.MapAnimationOptions(duration: 1000),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }



  // ── Camera change → grid refresh ────────────────────────────────────────

  void _onCameraChange(mapbox.CameraChangedEventData _) async {
    _gridDebounce?.cancel();
    _gridDebounce = Timer(
      const Duration(milliseconds: 150),
      _updateGridForViewport,
    );

    final map = _mapboxMap;
    if (map != null) {
      try {
        final cam = await map.getCameraState();
        if (mounted && _bearing != cam.bearing) {
          setState(() {
            _bearing = cam.bearing;
          });
        }
      } catch (_) {}
    }
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
              zoom: 8.0,
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
          if (!isPickerMode) _buildCompass(),
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
            isPickerMode ? 'Select Location' : 'Zone Activity Map',
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
            // Text(
            //   'ACTIVITY',
            //   style: getTextStyle(
            //     fontSize: 10,
            //     fontWeight: FontWeight.bold,
            //     color: AppColors.blue00F0FFColor,
            //   ),
            // ),
            // SizedBox(height: 8.h),
            _legendRow(AppColors.orangeColor, 'High Activity'),
            _legendRow(AppColors.blue00F0FFColor, 'Medium Activity'),
            _legendRow(AppColors.grey516173Color, 'Low Activity'),
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
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blue134D67Color.withValues(alpha: 0.9),
            border: Border.all(color: AppColors.blue00F0FFColor, width: 1.5.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue00F0FFColor.withValues(alpha: 0.25),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              IconPath.filterIcon, 
              height: 24.r, 
              width: 24.r,
              color: AppColors.blue00F0FFColor,
            ),
          ),
        ),
        // Positioned(
        //   top: -2.r,
        //   right: -2.r,
        //   child: Container(
        //     padding: EdgeInsets.all(4.r),
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Color(0xFFFF5252), // vibrant red badge
        //     ),
        //     constraints: BoxConstraints(
        //       minWidth: 18.r,
        //       minHeight: 18.r,
        //     ),
        //     child: Center(
        //       child: Text(
        //         '3',
        //         style: TextStyle(
        //           fontSize: 10.sp, 
        //           color: Colors.white, 
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _addButton() {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C42), Color(0xFFE25301)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE25301).withValues(alpha: 0.45),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.add, color: Colors.white, size: 30.sp),
    );
  }

  Widget _buildCompass() {
    final angleRad = -_bearing * 3.141592653589793 / 180.0;
    return Positioned(
      top: 130.h,
      left: 20.w,
      child: Column(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue0D2B43Color.withValues(alpha: 0.8),
              border: Border.all(color: AppColors.blue00F0FFColor, width: 1.5.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue00F0FFColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                )
              ]
            ),
            child: Center(
              child: Transform.rotate(
                angle: angleRad,
                child: CustomPaint(
                  size: Size(18.w, 24.h),
                  painter: const CompassNeedlePainter(),
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "N",
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.blue00F0FFColor,
            ),
          )
        ],
      ),
    );
  }
}

class CompassNeedlePainter extends CustomPainter {
  const CompassNeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final path = ui.Path();
    // Draw top half (orange)
    paint.color = const Color(0xFFFF8C42);
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * 0.75);
    path.close();
    canvas.drawPath(path, paint);

    // Draw left half shade (dark orange) for 3D effect
    final pathLeft = ui.Path();
    paint.color = const Color(0xFFE25301);
    pathLeft.moveTo(size.width / 2, 0);
    pathLeft.lineTo(0, size.height);
    pathLeft.lineTo(size.width / 2, size.height * 0.75);
    pathLeft.close();
    canvas.drawPath(pathLeft, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Zone Detail Panel (StatefulWidget — fetches real data from backend)

class _ZoneDetailPanel extends StatefulWidget {
  final MapZoneModel zone;
  final VoidCallback onClose;
  const _ZoneDetailPanel({required this.zone, required this.onClose});

  @override
  State<_ZoneDetailPanel> createState() => _ZoneDetailPanelState();
}

class _ZoneDetailPanelState extends State<_ZoneDetailPanel> {
  final _ctrl = Get.find<MapScreenController>();

  bool _loading = true;

  // Live data from backend (populated after fetch)
  late int _reportCount;
  late double _activityScore;
  late TrendDirection _trend;
  late String _topSpecies;
  late String _avgDepth;
  late String _lastUpdated;
  late String _dominantMethod;
  late String _peakWindow;

  @override
  void initState() {
    super.initState();
    // Seed with whatever the controller already knows from the /zones call
    _reportCount     = widget.zone.reports;
    _activityScore   = widget.zone.activityScore;
    _trend           = widget.zone.trend;
    _topSpecies      = widget.zone.topSpecies;
    _avgDepth        = widget.zone.avgDepth;
    _lastUpdated     = widget.zone.lastUpdated;
    _dominantMethod  = '—';
    _peakWindow      = '—';

    _fetchLiveData();
  }

  @override
  void didUpdateWidget(_ZoneDetailPanel old) {
    super.didUpdateWidget(old);
    if (old.zone.id != widget.zone.id) {
      setState(() {
        _loading        = true;
        _reportCount    = widget.zone.reports;
        _activityScore  = widget.zone.activityScore;
        _trend          = widget.zone.trend;
        _topSpecies     = widget.zone.topSpecies;
        _avgDepth       = widget.zone.avgDepth;
        _lastUpdated    = widget.zone.lastUpdated;
        _dominantMethod = '—';
        _peakWindow     = '—';
      });
      _fetchLiveData();
    }
  }

  Future<void> _fetchLiveData() async {
    final data = await _ctrl.fetchZoneSummary(widget.zone.id);
    if (!mounted) return;
    if (data != null) {
      setState(() {
        _activityScore  = data['activityScore']  as double;
        _trend          = data['trend']           as TrendDirection;
        _topSpecies     = data['topSpecies']      as String;
        _avgDepth       = data['avgDepth']        as String;
        _dominantMethod = data['dominantMethod']  as String;
        _peakWindow     = data['peakWindow']      as String;
        _reportCount    = data['reportCount']     as int;
        _lastUpdated    = data['lastUpdated']     as String;
      });
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final trendColor = _trend == TrendDirection.rising
        ? const Color(0xFF00E676)
        : _trend == TrendDirection.falling
        ? const Color(0xFFFF5252)
        : Colors.white70;
    final trendIcon = _trend == TrendDirection.rising
        ? Icons.trending_up
        : _trend == TrendDirection.falling
        ? Icons.trending_down
        : Icons.trending_flat;
    final trendLabel = _trend == TrendDirection.rising
        ? 'Rising'
        : _trend == TrendDirection.falling
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
                        widget.zone.name,
                        style: getTextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '$_reportCount reports  •  ',
                          style: getTextStyle(fontSize: 13, color: Colors.white54),
                        ),
                        if (_loading)
                          SizedBox(
                            width: 12.w,
                            height: 12.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: const Color(0xFF00D4FF),
                            ),
                          )
                        else
                          Text(
                            'Updated $_lastUpdated',
                            style: getTextStyle(fontSize: 13, color: Colors.white54),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onClose,
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
                    _loading
                        ? _shimmerBox(48.w, 20.h)
                        : Text(
                            '${(_activityScore * 100).round()}%',
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
                    value: _loading ? null : _activityScore,
                    minHeight: 10.h,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8C42)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),

          // metric cards — Top Species + Avg Depth
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.set_meal,
                  label: 'Top Species',
                  value: _topSpecies,
                  loading: _loading,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _metricCard(
                  icon: Icons.water,
                  label: 'Avg Depth',
                  value: _avgDepth,
                  loading: _loading,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // second row — Dominant Method + Peak Window
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.navigation,
                  label: 'Top Method',
                  value: _dominantMethod,
                  loading: _loading,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _metricCard(
                  icon: Icons.access_time,
                  label: 'Peak Window',
                  value: _peakWindow,
                  loading: _loading,
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
                if (_loading)
                  _shimmerBox(60.w, 16.h)
                else
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
              onPressed: () {
                // Rebuild the zone model so the SummaryScreen receives the
                // live-fetched data AND the original boundary coords
                // (north/south/east/west) that are needed to compute the
                // correct weather-fetch centre in SummaryController.
                final liveZone = MapZoneModel(
                  id: widget.zone.id,
                  name: widget.zone.name,
                  location: widget.zone.location,
                  count: widget.zone.count,
                  level: _activityScore >= 0.7
                      ? ActivityLevel.high
                      : _activityScore >= 0.4
                          ? ActivityLevel.medium
                          : ActivityLevel.low,
                  reports: _reportCount,
                  lastUpdated: _lastUpdated,
                  activityScore: _activityScore,
                  topSpecies: _topSpecies,
                  avgDepth: _avgDepth,
                  trend: _trend,
                  // preserve boundary coords for weather centre calculation
                  north: widget.zone.north,
                  south: widget.zone.south,
                  east: widget.zone.east,
                  west: widget.zone.west,
                );
                Get.to(
                  () => SummaryScreen(isReportMainScreen: false),
                  arguments: liveZone,
                );
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

  /// Animated shimmer placeholder for loading state
  Widget _shimmerBox(double width, double height) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 800),
      builder: (_, val, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: val),
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    bool loading = false,
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
                SizedBox(height: 4.h),
                loading
                    ? _shimmerBox(double.infinity, 14.h)
                    : Text(
                        value.isEmpty ? '—' : value,
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

