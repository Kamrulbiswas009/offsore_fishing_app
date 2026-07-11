import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';
import 'package:paytonpieper/features/submit_report/screen/submit_report_screen.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/features/report_main/report_catch/controller/report_catch_step1_screen.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';

class ReportCatch2Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateFormat('MM/dd/yyyy').format(DateTime.now());
    selectedTime.value = DateFormat('hh:mm a').format(DateTime.now());
  }

  // ── Selected location from map picker ─────────────────────────────────────
  var selectedLat = Rxn<double>();
  var selectedLng = Rxn<double>();

  void setSelectedLocation(double lat, double lng) {
    selectedLat.value = lat;
    selectedLng.value = lng;
  }

  // Pattern Toggle
  var isSamePattern = true.obs;
  var isNothingCaught = false.obs;

  // Species Selection options
  var speciesOptions = speciesHierarchy.expand((node) => node.allSelectableLeafNames).toList().obs;
  var selectedSpeciesList = <String>[].obs;

  // Fishing Details (Dynamic Quantities)
  var quantities = <String, int>{}.obs;

  // Water Position
  var waterPosition = "Suspended".obs; // Topwater, Suspended, Bottom

  // Dropdown Options
  var methodOptions = [
    "Anchor/Spot Fishing",
    "Casting",
    "Chunking",
    "Jigging",
    "Spearing",
    "Trolling",
  ].obs;

  // Selected values
  var selectedMethod = "".obs;
  var selectedBait = "".obs;

  List<String> get filteredBaitOptions {
    final method = selectedMethod.value;
    if (method.isEmpty || method == "Select Method") {
      return ["Other"];
    }

    final list = <String>[];

    if (method == "Trolling") {
      list.add("Diving Lure");
    }
    if (method == "Anchor/Spot Fishing" ||
        method == "Casting" ||
        method == "Chunking" ||
        method == "Trolling") {
      list.add("Cut Bait");
    }
    if (method == "Anchor/Spot Fishing" ||
        method == "Casting" ||
        method == "Trolling") {
      list.add("Live Bait");
    }
    if (method == "Casting") {
      list.add("Popper");
    }
    if (method == "Trolling") {
      list.add("Plug Lure");
    }
    if (method == "Trolling") {
      list.add("Skirted Lure");
    }
    if (method == "Jigging") {
      list.add("Slow Jig");
    }
    if (method == "Casting") {
      list.add("Soft Plastic");
    }
    if (method == "Casting") {
      list.add("Stickbait");
    }
    if (method == "Jigging") {
      list.add("Vertical Jig");
    }
    list.add("Other");

    return list;
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
    if (!filteredBaitOptions.contains(selectedBait.value)) {
      selectedBait.value = "";
    }
  }

  // Form Controllers
  final depthController = TextEditingController(text: "120");
  final strikeZoneController = TextEditingController(text: "80");
  final notesController = TextEditingController();

  var selectedDate = DateFormat('MM/dd/yyyy').format(DateTime.now()).obs;
  var selectedTime = DateFormat('hh:mm a').format(DateTime.now()).obs;

  void setSamePattern(bool value) {
    isSamePattern.value = value;
    if (!value) {
      if (selectedSpeciesList.length > 1) {
        selectedSpeciesList.assignAll([selectedSpeciesList.first]);
      }
      if (selectedSpeciesList.isNotEmpty) {
        final singleSpecies = selectedSpeciesList.first;
        final currentQty = quantities[singleSpecies] ?? 1;
        quantities.assignAll({singleSpecies: currentQty});
      } else if (quantities.length > 1) {
        final firstKey = quantities.keys.first;
        quantities.assignAll({firstKey: quantities[firstKey]!});
      }
    }
  }

  void addSpecies(String name) {
    if (!isSamePattern.value) {
      selectedSpeciesList.assignAll([name]);
      final currentQty = quantities[name] ?? 1;
      quantities.assignAll({name: currentQty});
    } else {
      if (!selectedSpeciesList.contains(name)) {
        selectedSpeciesList.add(name);
      }
    }
  }

  void removeSpecies(String name) {
    selectedSpeciesList.remove(name);
    quantities.remove(name);
  }

  void updateQuantity(String species, int qty) {
    quantities[species] = qty;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.blue00F0FFColor,
              onPrimary: Colors.white,
              surface: AppColors.blue1B2134Color,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.blue00F0FFColor,
              onPrimary: Colors.white,
              surface: AppColors.blue1B2134Color,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // Check if picked time is in the future if the selected date is today
      final selectedDateObj = DateFormat(
        'MM/dd/yyyy',
      ).parse(selectedDate.value);
      final today = DateTime(now.year, now.month, now.day);

      if (selectedDateObj.isAtSameMomentAs(today)) {
        if (dt.isAfter(now)) {
          Get.snackbar(
            "Invalid Time",
            "You cannot select a future time for today.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      selectedTime.value = DateFormat('hh:mm a').format(dt);
    }
  }

  // Helper to generate local UUID v4
  String _generateUuid() {
    final random = Random.secure();
    final hexDigits = '0123456789abcdef';
    final charCodes = List<int>.generate(36, (index) {
      if (index == 8 || index == 13 || index == 18 || index == 23) {
        return 45; // '-'
      }
      final r = random.nextInt(16);
      if (index == 14) {
        return 52; // '4'
      }
      if (index == 19) {
        return hexDigits.codeUnitAt((r & 0x3) | 0x8);
      }
      return hexDigits.codeUnitAt(r);
    });
    return String.fromCharCodes(charCodes);
  }

  // Parse date and time into UTC ISO string
  DateTime _getCatchDateTime(String dateStr, String timeStr) {
    try {
      final format = DateFormat('MM/dd/yyyy hh:mm a');
      return format.parse('$dateStr $timeStr');
    } catch (e) {
      return DateTime.now();
    }
  }

  // Mapping helpers
  String _mapMethod(String method) {
    final clean = method.trim().toUpperCase();
    if (clean == "ANCHOR/SPOT FISHING" || clean == "ANCHOR SPOT FISHING") return "ANCHOR_SPOT_FISHING";
    if (clean == "CASTING") return "CASTING";
    if (clean == "CHUNKING") return "CHUNKING";
    if (clean == "JIGGING") return "JIGGING";
    if (clean == "SPEARING") return "SPEARING";
    if (clean == "TROLLING") return "TROLLING";
    return clean.replaceAll(" ", "_");
  }

  String _mapBait(String bait, String method) {
    final cleanBait = bait.trim().toUpperCase();
    if (cleanBait == "DIVING LURE") return "DIVING_LURE";
    if (cleanBait == "CUT BAIT") return "CUT_BAIT";
    if (cleanBait == "LIVE BAIT") return "LIVE_BAIT";
    if (cleanBait == "POPPER") return "POPPER";
    if (cleanBait == "PLUG LURE") return "PLUG_LURE";
    if (cleanBait == "SKIRTED LURE") return "SKIRTED_LURE";
    if (cleanBait == "SLOW JIG") return "SLOW_JIG";
    if (cleanBait == "SOFT PLASTIC") return "SOFT_PLASTIC";
    if (cleanBait == "STICKBAIT") return "STICKBAIT";
    if (cleanBait == "VERTICAL JIG") return "VERTICAL_JIG";
    return "OTHER";
  }

  String _mapWaterColumn(String pos) {
    final clean = pos.trim().toUpperCase();
    if (clean == "TOPWATER") return "SURFACE";
    if (clean == "SUSPENDED") return "MID_COLUMN";
    if (clean == "BOTTOM") return "BOTTOM";
    return "MID_COLUMN";
  }

  Map<String, dynamic> buildReportPayload({required String visibility, String? groupId}) {
    final speciesList = <Map<String, dynamic>>[];
    if (!isNothingCaught.value) {
      for (var name in selectedSpeciesList) {
        speciesList.add({
          "speciesName": name,
          "quantity": quantities[name] ?? 1,
        });
      }
    } else {
      speciesList.add({
        "speciesName": "None",
        "quantity": 0,
      });
    }

    final catchDateTime = _getCatchDateTime(selectedDate.value, selectedTime.value);

    // Format ISO string to match curl example format (no milliseconds to avoid strict regex fails)
    final catchTimestampStr = "${catchDateTime.toUtc().toIso8601String().split('.').first}Z";

    final lat = selectedLat.value ?? 28.4521;
    final lng = selectedLng.value ?? -89.1234;
    final zoneInfo = ZoneCalculator.fromLatLng(lat, lng);

    final payload = {
      "frontendReportId": _generateUuid(),
      "zoneId": zoneInfo?.zoneId,
      "reportLat": lat,
      "reportLng": lng,
      "species": speciesList,
      "fishingMethod": _mapMethod(selectedMethod.value),
      "baitLureType": _mapBait(selectedBait.value, selectedMethod.value),
      "waterDepthFt": int.tryParse(depthController.text) ?? 120,
      "waterColumn": _mapWaterColumn(waterPosition.value),
      "notes": notesController.text,
      "visibility": visibility,
      "catchTimestamp": catchTimestampStr,
      "capturedOfflineAt": null, // Will be set to current time when saved offline
      "queueStatus": "PENDING",
      "deviceLat": 0.0,
      "deviceLng": 0.0,
      "deviceFingerprint": "string",
      "userAgent": "string",
      "appVersion": "1.0.0"
    };

    if (groupId != null && groupId.isNotEmpty) {
      payload["groupId"] = groupId;
    }

    return payload;
  }

  Future<void> submitReport() async {
    final syncService = Get.find<SyncService>();
    
    // Double check with hasActualInternet in case they are offline
    final online = syncService.isOnline.value;

    if (!online) {
      final payload = buildReportPayload(visibility: "PUBLIC");
      await syncService.saveReportLocally(payload);
      
      Get.snackbar(
        "Offline Mode",
        "No connection. Your report is saved locally and will sync when you are online.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orangeColor,
        colorText: Colors.white,
      );
      
      Get.to(() => const OfflineReportsScreen());
    } else {
      Get.dialog(const VisibilitySharingDialog(), barrierDismissible: true);
    }
  }
}
