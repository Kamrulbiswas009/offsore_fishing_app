import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';
import 'package:paytonpieper/features/submit_report/screen/submit_report_screen.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';

// ---------------------------------------------------------------------------
// Per-species fishing detail model (used when isSamePattern == false)
// ---------------------------------------------------------------------------
class SpeciesEntry {
  final String id;
  String speciesName;
  int quantity;

  // Per-species fishing pattern fields
  String waterPosition;
  String method;
  String bait;
  String date;
  String time;
  String notes;
  final TextEditingController depthCtrl;

  SpeciesEntry({
    required this.id,
    this.speciesName = '',
    this.quantity = 1,
    this.waterPosition = 'Suspended',
    this.method = '',
    this.bait = '',
    String? date,
    String? time,
    this.notes = '',
    String depthText = '120',
  })  : date = date ?? DateFormat('MM/dd/yyyy').format(DateTime.now()),
        time = time ?? DateFormat('hh:mm a').format(DateTime.now()),
        depthCtrl = TextEditingController(text: depthText);

  void dispose() {
    depthCtrl.dispose();
  }
}

class ReportCatch2Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateFormat('MM/dd/yyyy').format(DateTime.now());
    selectedTime.value = DateFormat('hh:mm a').format(DateTime.now());
    _addBlankSpeciesEntry();
  }

  @override
  void onClose() {
    for (final e in speciesEntries) {
      e.dispose();
    }
    depthController.dispose();
    strikeZoneController.dispose();
    notesController.dispose();
    super.onClose();
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

  // ── "Yes" mode – shared species list ──────────────────────────────────────
  var speciesOptions =
      speciesHierarchy.expand((node) => node.allSelectableLeafNames).toList().obs;
  var selectedSpeciesList = <String>[].obs;
  var quantities = <String, int>{}.obs;

  // ── Recent Selections (up to 5, most recent first) ───────────────────────
  var recentSpeciesSelections = <String>[].obs;

  void addRecentSpeciesSelection(String name) {
    recentSpeciesSelections.remove(name); // remove duplicate if exists
    recentSpeciesSelections.insert(0, name);
    if (recentSpeciesSelections.length > 5) {
      recentSpeciesSelections.removeRange(5, recentSpeciesSelections.length);
    }
  }

  // ── "No" mode – per-species entries ───────────────────────────────────────
  var speciesEntries = <SpeciesEntry>[].obs;

  void _addBlankSpeciesEntry() {
    speciesEntries.add(
      SpeciesEntry(
        id: _generateUuid(),
        date: DateFormat('MM/dd/yyyy').format(DateTime.now()),
        time: DateFormat('hh:mm a').format(DateTime.now()),
      ),
    );
  }

  void addSpeciesEntry() {
    _addBlankSpeciesEntry();
  }

  void removeSpeciesEntry(String id) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].dispose();
      speciesEntries.removeAt(idx);
    }
    if (speciesEntries.isEmpty) {
      _addBlankSpeciesEntry();
    }
  }

  void updateSpeciesEntryName(String id, String name) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].speciesName = name;
      speciesEntries.refresh();
      addRecentSpeciesSelection(name);
    }
  }

  void updateSpeciesEntryQty(String id, int qty) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].quantity = qty;
      speciesEntries.refresh();
    }
  }

  void updateSpeciesEntryWaterPosition(String id, String pos) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].waterPosition = pos;
      speciesEntries.refresh();
    }
  }

  void updateSpeciesEntryMethod(String id, String method) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].method = method;
      if (!getFilteredBaitOptions(method).contains(speciesEntries[idx].bait)) {
        speciesEntries[idx].bait = '';
      }
      speciesEntries.refresh();
    }
  }

  void updateSpeciesEntryBait(String id, String bait) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].bait = bait;
      speciesEntries.refresh();
    }
  }

  void updateSpeciesEntryDate(String id, String date) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].date = date;
      speciesEntries.refresh();
    }
  }

  void updateSpeciesEntryTime(String id, String time) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].time = time;
      speciesEntries.refresh();
    }
  }

  void updateSpeciesEntryNotes(String id, String notes) {
    final idx = speciesEntries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      speciesEntries[idx].notes = notes;
      speciesEntries.refresh();
    }
  }

  // Water Position (shared, "Yes" mode)
  var waterPosition = "Suspended".obs;

  // Dropdown Options – exact master data order
  var methodOptions = [
    "Anchor/Spot Fishing",
    "Casting",
    "Chunking",
    "Jigging",
    "Spearing",
    "Trolling",
  ].obs;

  // Selected values (shared, "Yes" mode)
  var selectedMethod = "".obs;
  var selectedBait = "".obs;

  List<String> get filteredBaitOptions => getFilteredBaitOptions(selectedMethod.value);

  List<String> getFilteredBaitOptions(String method) {
    if (method.isEmpty || method == "Select Method") return ["Other"];
    final list = <String>[];
    if (method == "Trolling") list.add("Diving Lure");
    if (method == "Anchor/Spot Fishing" ||
        method == "Casting" ||
        method == "Chunking" ||
        method == "Trolling") list.add("Cut Bait");
    if (method == "Anchor/Spot Fishing" ||
        method == "Casting" ||
        method == "Trolling") list.add("Live Bait");
    if (method == "Casting") list.add("Popper");
    if (method == "Trolling") list.add("Plug Lure");
    if (method == "Trolling") list.add("Skirted Lure");
    if (method == "Jigging") list.add("Slow Jig");
    if (method == "Casting") list.add("Soft Plastic");
    if (method == "Casting") list.add("Stickbait");
    if (method == "Jigging") list.add("Vertical Jig");
    list.add("Other");
    return list;
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
    if (!filteredBaitOptions.contains(selectedBait.value)) {
      selectedBait.value = "";
    }
  }

  // Form Controllers (shared "Yes" mode)
  final depthController = TextEditingController(text: "120");
  final strikeZoneController = TextEditingController(text: "80");
  final notesController = TextEditingController();

  var selectedDate = DateFormat('MM/dd/yyyy').format(DateTime.now()).obs;
  var selectedTime = DateFormat('hh:mm a').format(DateTime.now()).obs;

  void setSamePattern(bool value) {
    isSamePattern.value = value;
    if (!value && speciesEntries.isEmpty) {
      _addBlankSpeciesEntry();
    }
  }

  // ── "Yes" mode helpers ────────────────────────────────────────────────────
  void addSpecies(String name) {
    if (!isSamePattern.value) return;
    if (!selectedSpeciesList.contains(name)) {
      selectedSpeciesList.add(name);
    }
    if (!quantities.containsKey(name)) {
      quantities[name] = 1;
    }
    addRecentSpeciesSelection(name);
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
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final selectedDateObj = DateFormat('MM/dd/yyyy').parse(selectedDate.value);
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

  Future<void> pickDateForEntry(BuildContext context, String entryId) async {
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
      updateSpeciesEntryDate(entryId, DateFormat('MM/dd/yyyy').format(picked));
    }
  }

  Future<void> pickTimeForEntry(BuildContext context, String entryId) async {
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
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      if (dt.isAfter(now)) {
        Get.snackbar(
          "Invalid Time",
          "You cannot select a future time.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      updateSpeciesEntryTime(entryId, DateFormat('hh:mm a').format(dt));
    }
  }

  // Helper to generate local UUID v4
  String _generateUuid() {
    final random = Random.secure();
    final hexDigits = '0123456789abcdef';
    final charCodes = List<int>.generate(36, (index) {
      if (index == 8 || index == 13 || index == 18 || index == 23) return 45;
      final r = random.nextInt(16);
      if (index == 14) return 52;
      if (index == 19) return hexDigits.codeUnitAt((r & 0x3) | 0x8);
      return hexDigits.codeUnitAt(r);
    });
    return String.fromCharCodes(charCodes);
  }

  DateTime _getCatchDateTime(String dateStr, String timeStr) {
    try {
      final format = DateFormat('MM/dd/yyyy hh:mm a');
      return format.parse('$dateStr $timeStr');
    } catch (e) {
      return DateTime.now();
    }
  }

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

  String _toTimestamp(DateTime dt) =>
      "${dt.toUtc().toIso8601String().split('.').first}Z";

  Map<String, dynamic> buildReportPayload({required String visibility, String? groupId}) {
    final lat = selectedLat.value ?? 28.4521;
    final lng = selectedLng.value ?? -89.1234;
    final zoneInfo = ZoneCalculator.fromLatLng(lat, lng);

    final catchDateTime = _getCatchDateTime(selectedDate.value, selectedTime.value);

    // ── Build fishingPatterns array ──────────────────────────────────────────
    final fishingPatterns = <Map<String, dynamic>>[];

    if (isNothingCaught.value) {
      // Nothing caught — single pattern with "None" species, no method/bait
      fishingPatterns.add({
        "species": [{"speciesName": "None", "quantity": 0}],
        "fishingMethod": null,
        "baitLureType": null,
        "waterDepthFt": null,
        "waterColumn": null,
      });
    } else if (isSamePattern.value) {
      // YES mode — one shared pattern containing all selected species
      final speciesList = selectedSpeciesList
          .map((name) => {"speciesName": name, "quantity": quantities[name] ?? 1})
          .toList();
      fishingPatterns.add({
        "species": speciesList,
        "fishingMethod": _mapMethod(selectedMethod.value),
        "baitLureType": _mapBait(selectedBait.value, selectedMethod.value),
        "waterDepthFt": int.tryParse(depthController.text) ?? 120,
        "waterColumn": _mapWaterColumn(waterPosition.value),
      });
    } else {
      // NO mode — one pattern per species entry
      for (final entry in speciesEntries) {
        if (entry.speciesName.isEmpty) continue;
        fishingPatterns.add({
          "species": [{"speciesName": entry.speciesName, "quantity": entry.quantity}],
          "fishingMethod": _mapMethod(entry.method),
          "baitLureType": _mapBait(entry.bait, entry.method),
          "waterDepthFt": int.tryParse(entry.depthCtrl.text) ?? 120,
          "waterColumn": _mapWaterColumn(entry.waterPosition),
        });
      }
    }

    final payload = <String, dynamic>{
      "frontendReportId": _generateUuid(),
      "zoneId": zoneInfo?.zoneId,
      "reportLat": lat,
      "reportLng": lng,
      "visibility": visibility,
      "catchTimestamp": _toTimestamp(catchDateTime),
      "notes": notesController.text,
      "fishingPatterns": fishingPatterns,
      // Device / queue metadata
      "capturedOfflineAt": null,
      "queueStatus": "PENDING",
      "deviceLat": 0.0,
      "deviceLng": 0.0,
      "deviceFingerprint": "string",
      "userAgent": "string",
      "appVersion": "1.0.0",
    };

    if (groupId != null && groupId.isNotEmpty) {
      payload["groupId"] = groupId;
    }

    return payload;
  }

  Future<void> submitReport() async {
    final syncService = Get.find<SyncService>();
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
