// ignore_for_file: unused_field, deprecated_member_use

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/main_screen/widgets/filter_dialog.dart';
import 'package:paytonpieper/features/main_screen/controller/filter_controller.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/features/weather_alerts/controller/weather_alert_controller.dart';
import 'package:paytonpieper/features/weather_alerts/model/watched_zone_model.dart';
import 'package:paytonpieper/features/weather_alerts/widgets/zone_watch_settings_sheet.dart';
import 'package:paytonpieper/features/weather_alerts/controller/bite_watch_controller.dart';
import 'package:paytonpieper/features/weather_alerts/widgets/bite_watch_settings_sheet.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';
import 'package:paytonpieper/features/payment_service/controller/payment_service_controller.dart';
import 'package:paytonpieper/core/services/permissions/location_permission_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:paytonpieper/features/main_screen/controller/main_screen_controller.dart';
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final controller = Get.find<MapScreenController>();

  late final AnimationController _panelAnim;
  late final Animation<Offset> _slideAnim;

  mapbox.MapboxMap? _mapboxMap;
  mapbox.ViewportState? _viewportState;
  bool _layersReady = false;
  bool _isLocating = false; // prevents double-tap on location button
  Timer? _gridDebounce;
  final ValueNotifier<double> _bearingNotifier = ValueNotifier<double>(0.0);
  DateTime _lastBearingCheck = DateTime.fromMillisecondsSinceEpoch(0);

  StreamSubscription<Position>? _positionStream;
  Worker? _tabIndexWorker;

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

    // Reactively handle external zone selection (notification tap support)
    ever(controller.selectedZone, (zone) {
      if (zone != null) {
        if (_panelAnim.status != AnimationStatus.forward &&
            _panelAnim.status != AnimationStatus.completed) {
          _panelAnim.forward(from: 0);
        }
        final map = _mapboxMap;
        if (map != null) {
          map.easeTo(
            mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(
                  zone.location.longitude,
                  zone.location.latitude,
                ),
              ),
              zoom: 8.5,
            ),
            mapbox.MapAnimationOptions(duration: 1200),
          );
        }
      } else {
        if (_panelAnim.status != AnimationStatus.reverse &&
            _panelAnim.status != AnimationStatus.dismissed) {
          _panelAnim.reverse();
        }
      }
    });

    WidgetsBinding.instance.addObserver(this);

    if (Get.isRegistered<MainScreenController>()) {
      _tabIndexWorker = ever(Get.find<MainScreenController>().currentIndex, (
        _,
      ) {
        _updateLocationTracking();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabIndexWorker?.dispose();
    _stopLocationStream();
    _gridDebounce?.cancel();
    _bearingNotifier.dispose();
    _panelAnim.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateLocationTracking();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopLocationStream();
    }
  }

  void _startLocationStream() {
    if (_positionStream != null) return;
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            debugPrint(
              '[ZoneMapScreen] Location stream update: ${position.latitude}, ${position.longitude}',
            );
          },
          onError: (e) {
            debugPrint('[ZoneMapScreen] Location stream error: $e');
          },
        );
  }

  void _stopLocationStream() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> _updateLocationTracking() async {
    try {
      final permissionService = Get.find<LocationPermissionService>();
      final isGranted = await permissionService.isLocationPermissionGranted();

      bool isMapTabActive = true;
      if (Get.isRegistered<MainScreenController>()) {
        final mainController = Get.find<MainScreenController>();
        isMapTabActive = mainController.currentIndex.value == 0;
      }

      final isAppForeground =
          WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

      if (isGranted &&
          isMapTabActive &&
          isAppForeground &&
          _mapboxMap != null) {
        _startLocationStream();
        await controller.toggleMockUserLocation(_mapboxMap!, false);
        await _mapboxMap!.location.updateSettings(
          mapbox.LocationComponentSettings(
            enabled: true,
            pulsingEnabled: true,
            showAccuracyRing: true,
          ),
        );
      } else {
        _stopLocationStream();
        if (_mapboxMap != null) {
          await _mapboxMap!.location.updateSettings(
            mapbox.LocationComponentSettings(enabled: false),
          );
          await controller.toggleMockUserLocation(_mapboxMap!, true);
        }
      }
    } catch (e) {
      debugPrint('[ZoneMapScreen] Error in _updateLocationTracking: $e');
    }
  }

  // ── Map lifecycle ────────────────────────────────────────────────────────

  Future<void> _onMapCreated(mapbox.MapboxMap map) async {
    _mapboxMap = map;

    // Check if offline to log mapbox offline loading
    try {
      final syncService = Get.find<SyncService>();
      if (!syncService.isOnline.value) {
        debugPrint(
          '[ZoneMapScreen] Offline detected. Mapbox will serve cached offline TileRegion and StylePack.',
        );
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

    // Check if location permission is already granted
    try {
      final permissionService = Get.find<LocationPermissionService>();
      final isGranted = await permissionService.isLocationPermissionGranted();

      await _updateLocationTracking();

      if (isGranted && _mapboxMap != null) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 3),
          );
          await _mapboxMap!.setCamera(
            mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(pos.longitude, pos.latitude),
              ),
              zoom: 10.0,
            ),
          );
        } catch (_) {
          await _mapboxMap!.setCamera(
            mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(
                  controller.mapCenter.longitude,
                  controller.mapCenter.latitude,
                ),
              ),
              zoom: 8.0,
            ),
          );
        }
      } else if (_mapboxMap != null) {
        await _mapboxMap!.setCamera(
          mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(
                controller.mapCenter.longitude,
                controller.mapCenter.latitude,
              ),
            ),
            zoom: 8.0,
          ),
        );
      }
    } catch (e) {
      debugPrint('[ZoneMapScreen] Error setting up initial location: $e');
    }

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

      final permissionService = Get.find<LocationPermissionService>();
      var isGranted = await permissionService.isLocationPermissionGranted();
      LocationPermissionResult? result;

      if (!isGranted) {
        result = await permissionService.requestLocationWhenInUse();
        isGranted = (result == LocationPermissionResult.granted);
      }

      if (result == LocationPermissionResult.permanentlyDenied) {
        Get.dialog(
          AlertDialog(
            backgroundColor: AppColors.containerBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: const BorderSide(color: AppColors.blue00F0FFColor),
            ),
            title: Text(
              'Location Permission Required',
              style: getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            content: Text(
              'Location permission is permanently denied. Please enable it in app settings to use this feature.',
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.greyC8D0DBColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey516173Color,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  permissionService.openSettings();
                },
                child: Text(
                  'Settings',
                  style: getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue00F0FFColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      await _updateLocationTracking();

      if (isGranted) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        await map.easeTo(
          mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(pos.longitude, pos.latitude),
            ),
            zoom: 10.0,
          ),
          mapbox.MapAnimationOptions(duration: 1200),
        );
      } else {
        // Animate camera to the Gulf of Mexico offshore (default location fallback)
        await map.easeTo(
          mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(
                controller.mapCenter.longitude,
                controller.mapCenter.latitude,
              ),
            ),
            zoom: 9.0,
          ),
          mapbox.MapAnimationOptions(duration: 1000),
        );
        Get.snackbar(
          '🌊 Gulf of Mexico Location',
          'Location access denied. Displaying default Gulf of Mexico ocean location.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF0D2B43),
          colorText: Colors.white,
          borderColor: const Color(0xFF117A88),
          borderWidth: 1,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      debugPrint('[ZoneMapScreen] Error in _goToMyLocation: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── Camera change → grid refresh ────────────────────────────────────────

  void _onCameraChange(mapbox.CameraChangedEventData _) {
    _gridDebounce?.cancel();
    _gridDebounce = Timer(
      const Duration(milliseconds: 300),
      _updateGridForViewport,
    );

    final now = DateTime.now();
    if (now.difference(_lastBearingCheck).inMilliseconds > 100) {
      _lastBearingCheck = now;
      final map = _mapboxMap;
      if (map != null) {
        map.getCameraState().then((cam) {
          if (mounted && (_bearingNotifier.value - cam.bearing).abs() > 0.5) {
            _bearingNotifier.value = cam.bearing;
          }
        }).catchError((_) {});
      }
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
      if (!zone.id.startsWith('GOM')) {
        _dismissPanel();
        Get.dialog(
          AlertDialog(
            backgroundColor: AppColors.containerBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: const BorderSide(color: AppColors.blue00F0FFColor),
            ),
            title: Text(
              'Outside Service Area',
              style: getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            content: Text(
              'You are out of Gulf of Mexico area.',
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.greyC8D0DBColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'OK',
                  style: getTextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue00F0FFColor,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }
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
    final filterController = Get.put(FilterController());
    return Obx(() {
      final count = filterController.activeFilterCount;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue134D67Color.withValues(alpha: 0.9),
              border: Border.all(
                color: AppColors.blue00F0FFColor,
                width: 1.5.w,
              ),
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
          if (count > 0)
            Positioned(
              top: -2.r,
              right: -2.r,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF5252), // vibrant red badge
                ),
                constraints: BoxConstraints(minWidth: 18.r, minHeight: 18.r),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
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
              border: Border.all(
                color: AppColors.blue00F0FFColor,
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue00F0FFColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: ValueListenableBuilder<double>(
                valueListenable: _bearingNotifier,
                builder: (context, bearing, child) {
                  final angleRad = -bearing * 3.141592653589793 / 180.0;
                  return Transform.rotate(
                    angle: angleRad,
                    child: child,
                  );
                },
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
          ),
        ],
      ),
    );
  }
}

class CompassNeedlePainter extends CustomPainter {
  const CompassNeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

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
    _reportCount = widget.zone.reports;
    _activityScore = widget.zone.activityScore;
    _trend = widget.zone.trend;
    _topSpecies = widget.zone.topSpecies;
    _avgDepth = widget.zone.avgDepth;
    _lastUpdated = widget.zone.lastUpdated;
    _dominantMethod = '—';
    _peakWindow = '—';

    _fetchLiveData();
  }

  @override
  void didUpdateWidget(_ZoneDetailPanel old) {
    super.didUpdateWidget(old);
    if (old.zone.id != widget.zone.id) {
      setState(() {
        _loading = true;
        _reportCount = widget.zone.reports;
        _activityScore = widget.zone.activityScore;
        _trend = widget.zone.trend;
        _topSpecies = widget.zone.topSpecies;
        _avgDepth = widget.zone.avgDepth;
        _lastUpdated = widget.zone.lastUpdated;
        _dominantMethod = '—';
        _peakWindow = '—';
      });
      _fetchLiveData();
    }
  }

  Future<void> _fetchLiveData() async {
    final data = await _ctrl.fetchZoneSummary(widget.zone.id);
    if (!mounted) return;
    if (data != null) {
      setState(() {
        _activityScore = data['activityScore'] as double;
        _trend = data['trend'] as TrendDirection;

        final newTopSpecies = data['topSpecies'] as String;
        _topSpecies =
            (newTopSpecies == 'None' ||
                newTopSpecies.isEmpty ||
                newTopSpecies == 'Unknown')
            ? widget.zone.topSpecies
            : newTopSpecies;

        final newAvgDepth = data['avgDepth'] as String;
        _avgDepth = (newAvgDepth == '—' || newAvgDepth.isEmpty)
            ? widget.zone.avgDepth
            : newAvgDepth;

        _dominantMethod = data['dominantMethod'] as String;
        _peakWindow = data['peakWindow'] as String;
        _reportCount = data['reportCount'] as int;
        _lastUpdated = data['lastUpdated'] as String;
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // name + reports + close button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                          fontSize: 22,
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
                          style: getTextStyle(
                            fontSize: 13,
                            color: const Color(0xFF9EA6B4),
                          ),
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
                            'Last updated $_lastUpdated',
                            style: getTextStyle(
                              fontSize: 13,
                              color: const Color(0xFF9EA6B4),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1F242E),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // activity score
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1F242E),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activity Score',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A94A6),
                      ),
                    ),
                    _loading
                        ? _shimmerBox(48.w, 20.h)
                        : Text(
                            '${(_activityScore * 100).round()}%',
                            style: getTextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF6D00),
                            ),
                          ),
                  ],
                ),
                SizedBox(height: 16.h),
                _loading
                    ? _shimmerBox(double.infinity, 8.h)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final progress = _activityScore.clamp(0.0, 1.0);
                          final trackHeight = 8.h;
                          final thumbSize = 16.w;
                          final leftOffset =
                              (constraints.maxWidth * progress) -
                              (thumbSize / 2);
                          final clampedOffset = leftOffset.clamp(
                            0.0,
                            constraints.maxWidth - thumbSize,
                          );

                          return Stack(
                            alignment: Alignment.centerLeft,
                            clipBehavior: Clip.none,
                            children: [
                              // Track background
                              Container(
                                height: trackHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF151922),
                                  borderRadius: BorderRadius.circular(
                                    trackHeight / 2,
                                  ),
                                ),
                              ),
                              // Progress track
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: trackHeight,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B4D8),
                                    borderRadius: BorderRadius.circular(
                                      trackHeight / 2,
                                    ),
                                  ),
                                ),
                              ),
                              // Glowing thumb
                              Positioned(
                                left: clampedOffset,
                                child: Container(
                                  width: thumbSize,
                                  height: thumbSize,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6D00),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFF6D00,
                                        ).withValues(alpha: 0.6),
                                        blurRadius: 10,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // metric cards Row (Top Species, Avg Depth, Trend)
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  label: 'Top Species',
                  value: _topSpecies,
                  loading:
                      _loading &&
                      (_topSpecies == 'None' ||
                          _topSpecies.isEmpty ||
                          _topSpecies == 'Unknown'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _metricCard(
                  label: 'Avg Depth',
                  value: _avgDepth,
                  loading: _loading && (_avgDepth == '—' || _avgDepth.isEmpty),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _metricCard(
                  label: 'Trend',
                  value: trendLabel,
                  trendColor: trendColor,
                  trendIcon: trendIcon,
                  isTrend: true,
                  loading: _loading,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── CTA Buttons ──────────────────────────────────────────────────
          _buildCtaRow(),
        ],
      ),
    );
  }

  /// Dual-button CTA: Watch Zone bell + View Full Details.
  Widget _buildCtaRow() {
    // Safely look up the alert controller — may not be registered yet on
    // first launch before ControllerBinder runs.
    WeatherAlertController? alertCtrl;
    try {
      alertCtrl = Get.find<WeatherAlertController>();
    } catch (_) {}

    if (alertCtrl == null) {
      // Fallback — just show the View Full Details button.
      return _viewFullDetailsButton();
    }

    return Obx(() {
      final isWatched = alertCtrl!.isWatched(widget.zone.name);
      final alertsOn =
          alertCtrl.configFor(widget.zone.name)?.alertsEnabled ?? false;

      BiteWatchController? biteCtrl;
      try {
        biteCtrl = Get.find<BiteWatchController>();
      } catch (_) {}

      ProfileMainScreenController? profileCtrl;
      try {
        profileCtrl = Get.find<ProfileMainScreenController>();
      } catch (_) {}

      final isPro = profileCtrl?.isPremiumAccount ?? false;
      final isBiteWatched =
          biteCtrl != null && biteCtrl.isWatched(widget.zone.name);
      final biteConfig = biteCtrl?.getWatchFor(widget.zone.name);
      final biteAlertsOn = biteConfig?.watchBiteActivity ?? false;

      return Column(
        children: [
          // ── Watch Zone status banner (Weather) ─────────────────────────
          GestureDetector(
            onTap: () {
              if (isWatched) {
                // Toggle alerts enabled/disabled
                alertCtrl!.toggleAlerts(widget.zone.name, enabled: !alertsOn);
                final msg = alertsOn
                    ? 'Alerts paused for ${widget.zone.name}'
                    : 'Alerts re-enabled for ${widget.zone.name}';
                EasyLoading.showToast(msg);
              } else {
                ZoneWatchSettingsSheet.show(
                  config: WatchedZoneConfig(
                    zoneId: widget.zone.name,
                    zoneName: widget.zone.name,
                    lat: widget.zone.location.latitude,
                    lng: widget.zone.location.longitude,
                  ),
                );
              }
            },
            onLongPress: isWatched
                ? () {
                    final config = alertCtrl!.configFor(widget.zone.name);
                    if (config != null) {
                      ZoneWatchSettingsSheet.show(
                        config: config,
                        isEditing: true,
                      );
                    }
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isWatched
                      ? [
                          AppColors.tealColor117A88.withOpacity(0.22),
                          const Color(0xFF0D1B2A),
                        ]
                      : [const Color(0xFF1F242E), const Color(0xFF1F242E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isWatched
                      ? AppColors.tealColor117A88.withOpacity(0.55)
                      : const Color(0xFF2E3A4A),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Bell icon container
                  TweenAnimationBuilder<double>(
                    key: ValueKey(isWatched),
                    tween: Tween(begin: 0.7, end: 1.0),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: isWatched
                            ? AppColors.tealColor117A88.withOpacity(0.2)
                            : const Color(0xFF252B36),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        isWatched
                            ? (alertsOn
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_paused_rounded)
                            : Icons.notifications_none_rounded,
                        size: 18.sp,
                        color: isWatched
                            ? (alertsOn
                                  ? AppColors.teal0C98AFColor
                                  : Colors.orange)
                            : const Color(0xFF8A94A6),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Label column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWatched
                              ? (alertsOn
                                    ? 'Weather Alerts Active'
                                    : 'Alerts Paused')
                              : 'Watch This Zone (Weather)',
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isWatched
                                ? Colors.white
                                : const Color(0xFFC8D0DB),
                          ),
                        ),
                        Text(
                          isWatched
                              ? (alertsOn
                                    ? 'Tap to pause  •  Hold to edit'
                                    : 'Tap to re-enable  •  Hold to edit')
                              : 'Get notified on wave / wind changes',
                          style: getTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8A94A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  if (isWatched)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: alertsOn
                            ? AppColors.tealColor117A88.withOpacity(0.18)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: alertsOn
                              ? AppColors.tealColor117A88.withOpacity(0.5)
                              : Colors.orange.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        alertsOn ? 'On' : 'Paused',
                        style: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: alertsOn
                              ? AppColors.teal0C98AFColor
                              : Colors.orange,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF8A94A6),
                      size: 18.sp,
                    ),
                ],
              ),
            ),
          ),

          // ── Watch Zone status banner (Bite Activity) ───────────────────
          GestureDetector(
            onTap: () {
              if (!isPro) {
                try {
                  Get.find<PaymentServiceController>().openUnlockProFlow();
                } catch (_) {}
                return;
              }
              if (biteCtrl == null) return;

              if (isBiteWatched) {
                biteCtrl.updateWatchSettings(
                  widget.zone.name,
                  watchBiteActivity: !biteAlertsOn,
                );
              } else {
                BiteWatchSettingsSheet.show(
                  zoneId: widget.zone.name,
                  isEditing: false,
                );
              }
            },
            onLongPress: isBiteWatched && isPro
                ? () {
                    BiteWatchSettingsSheet.show(
                      zoneId: widget.zone.name,
                      config: biteConfig,
                      isEditing: true,
                    );
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isBiteWatched && isPro
                      ? [
                          const Color(0xFFFF6D00).withOpacity(0.18),
                          const Color(0xFF0D1B2A),
                        ]
                      : [const Color(0xFF1F242E), const Color(0xFF1F242E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isBiteWatched && isPro
                      ? const Color(0xFFFF6D00).withOpacity(0.5)
                      : const Color(0xFF2E3A4A),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: isBiteWatched && isPro
                          ? const Color(0xFFFF6D00).withOpacity(0.15)
                          : const Color(0xFF252B36),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      !isPro
                          ? Icons.lock_outline_rounded
                          : isBiteWatched
                          ? (biteAlertsOn
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_paused_rounded)
                          : Icons.notifications_none_rounded,
                      size: 18.sp,
                      color: !isPro
                          ? Colors.amber
                          : isBiteWatched
                          ? (biteAlertsOn
                                ? const Color(0xFFFF6D00)
                                : Colors.orange)
                          : const Color(0xFF8A94A6),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          !isPro
                              ? 'Watch Bite Activity (PRO)'
                              : isBiteWatched
                              ? (biteAlertsOn
                                    ? 'Bite Alerts Active'
                                    : 'Bite Alerts Paused')
                              : 'Watch Bite Activity',
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isBiteWatched && isPro
                                ? Colors.white
                                : const Color(0xFFC8D0DB),
                          ),
                        ),
                        Text(
                          !isPro
                              ? 'Unlock to receive activity spike alerts'
                              : isBiteWatched
                              ? 'Notify: ≥${biteConfig?.biteThreshold ?? 3} reports / ${biteConfig?.biteThresholdDays ?? 7}d'
                              : 'Get notified when recent reports spike',
                          style: getTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8A94A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isBiteWatched && isPro)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: biteAlertsOn
                            ? const Color(0xFFFF6D00).withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: biteAlertsOn
                              ? const Color(0xFFFF6D00).withOpacity(0.4)
                              : Colors.orange.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        biteAlertsOn ? 'On' : 'Paused',
                        style: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: biteAlertsOn
                              ? const Color(0xFFFF6D00)
                              : Colors.orange,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF8A94A6),
                      size: 18.sp,
                    ),
                ],
              ),
            ),
          ),

          // ── View Full Details button ─────────────────────────────────
          _viewFullDetailsButton(),
        ],
      );
    });
  }

  Widget _viewFullDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D4FF),
          foregroundColor: const Color(0xFF0A1628),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        onPressed: () {
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
            color: const Color(0xFF0A1628),
          ),
        ),
      ),
    );
  }

  /// Animated shimmer placeholder for loading state
  Widget _shimmerBox(double width, double height) =>
      _ShimmerBox(width: width, height: height);

  Widget _metricCard({
    required String label,
    required String value,
    bool loading = false,
    bool isTrend = false,
    Color? trendColor,
    IconData? trendIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1F242E),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: getTextStyle(fontSize: 12, color: const Color(0xFF8A94A6)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          loading
              ? _shimmerBox(50.w, 16.h)
              : isTrend
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trendIcon != null)
                      Icon(
                        trendIcon,
                        color: trendColor ?? Colors.white,
                        size: 16.sp,
                      ),
                    if (trendIcon != null) SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        value.isEmpty ? '—' : value,
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: trendColor ?? Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  value.isEmpty ? '—' : value,
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable looping shimmer box — matches the dark card background.
// ---------------------------------------------------------------------------
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Base card colour used across the bottom sheet.
    const Color baseColor = Color(0xFF121F2E);
    // Highlight — slightly lighter with a cyan-tinted sheen.
    const Color highlightColor = Color(0xFF1E3347);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: const [baseColor, highlightColor, baseColor],
              transform: _SlidingGradientTransform(slidePercent: _anim.value),
            ),
          ),
        );
      },
    );
  }
}

/// Shifts a gradient horizontally by [slidePercent] (range −1.5 → +2.0).
class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
}
