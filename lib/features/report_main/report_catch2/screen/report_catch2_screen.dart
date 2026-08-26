import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/report_main/report_catch2/controller/report_catch2_controller.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import '../../../../core/utils/constants/colors.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/features/report_main/report_catch2/screen/species_drill_down_bottom_sheet.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';

class ReportCatch2Screen extends GetView<ReportCatch2Controller> {
  /// Optional coordinates passed from manual map location picker.
  final double? selectedLat;
  final double? selectedLng;

  const ReportCatch2Screen({super.key, this.selectedLat, this.selectedLng});

  @override
  Widget build(BuildContext context) {
    // Pass coordinates to controller when available
    if (selectedLat != null && selectedLng != null) {
      controller.setSelectedLocation(selectedLat!, selectedLng!);
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSyncStatus(),
              // Show selected location chip if coordinates were passed
              if (selectedLat != null && selectedLng != null) ...[
                SizedBox(height: 10.h),
                _buildLocationChip(selectedLat!, selectedLng!),
              ],
              SizedBox(height: 20.h),
              _buildStepper(),
              SizedBox(height: 25.h),
              _buildNothingCaughtToggle(),
              SizedBox(height: 20.h),
              Obx(
                () => IgnorePointer(
                  ignoring: controller.isNothingCaught.value,
                  child: Opacity(
                    opacity: controller.isNothingCaught.value ? 0.4 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatternToggle(),
                        SizedBox(height: 20.h),
                        // "No" mode: per-species list with individual pattern cards
                        if (!controller.isSamePattern.value) ...[
                          _buildNoPatternSpeciesList(),
                        ] else ...[
                          // "Yes" mode: original single species section
                          Text(
                            "Species Caught",
                            style: getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              lineHeight: 27,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          _buildSpeciesSection(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              _buildSubmitButton(),
              SizedBox(height: 100.h), // Padding for Bottom Nav
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: CircleAvatar(
          backgroundColor: AppColors.blue1B2134Color,
          child: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        "Report Catch",
        style: getTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSyncStatus() {
    final syncService = Get.find<SyncService>();
    return Obx(() {
      final online = syncService.isOnline.value;
      final pendingCount = syncService.pendingCount.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.blue1B2134Color,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              online ? Icons.wifi : Icons.wifi_off,
              color: online ? AppColors.green10B981Color : AppColors.yellowFCEA74Color,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              online
                  ? "Online - Report will sync instantly"
                  : "Offline - Queueing locally",
              style: getTextStyle(
                fontSize: 13,
                color: online ? AppColors.green10B981Color : AppColors.yellowFCEA74Color,
              ),
            ),
            if (pendingCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.orangeColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "$pendingCount",
                  style: getTextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Displays the manually selected lat/lng coordinates as a styled info chip.
  Widget _buildLocationChip(double lat, double lng) {
    final zoneInfo = ZoneCalculator.fromLatLng(lat, lng);
    final zoneSuffix = zoneInfo != null ? " (${zoneInfo.zoneId})" : "";
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.teal163A42Color,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.tealColor117A88, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.blue00F0FFColor,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Selected: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}$zoneSuffix",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 13,
                color: AppColors.blue00F0FFColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.green10B981Color,
          size: 26.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          "Select Grid",
          style: getTextStyle(fontSize: 14, color: Colors.white),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Divider(color: AppColors.grey3A4B62Color)),
        SizedBox(width: 10.w),
        _stepperCircle("2", true),
        SizedBox(width: 8.w),
        Text(
          "Report Details",
          style: getTextStyle(fontSize: 14, color: AppColors.blue00F0FFColor),
        ),
      ],
    );
  }

  Widget _stepperCircle(String num, bool isActive) {
    return Container(
      width: 26.r,
      height: 26.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.blue1B2134Color,
        border: Border.all(color: AppColors.blue00F0FFColor),
      ),
      alignment: Alignment.center,
      child: Text(
        num,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNothingCaughtToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nothing Caught at this spot",
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Toggle on if you didn't catch anything here",
                    style: getTextStyle(
                      fontSize: 12,
                      color: AppColors.greyC8D0DBColor,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: controller.isNothingCaught.value,
              onChanged: (val) {
                controller.isNothingCaught.value = val;
              },
              activeThumbColor: AppColors.blue00F0FFColor,
              activeTrackColor: AppColors.teal163A42Color,
              inactiveThumbColor: AppColors.grey8B95A5Color,
              inactiveTrackColor: AppColors.blue0D2B43Color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternToggle() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Fish share the same fishing pattern?",
                  style: getTextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              Icon(
                Icons.info_outline,
                color: AppColors.tealColor117A88,
                size: 18.sp,
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Obx(
            () => Column(
              children: [
                Row(
                  children: [
                    _toggleBtn(
                      "Yes",
                      controller.isSamePattern.value,
                      () => controller.setSamePattern(true),
                    ),
                    SizedBox(width: 10.w),
                    _toggleBtn(
                      "No",
                      !controller.isSamePattern.value,
                      () => controller.setSamePattern(false),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Text(
                  controller.isSamePattern.value
                      ? "Yes=One pattern for all species on this report"
                      : "No=Different pattern for some species on this report",
                  style: getTextStyle(
                    fontSize: 12,
                    color: AppColors.greyC8D0DBColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: active ? AppColors.teal163A42Color : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.blue153A56Color),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: getTextStyle(
              color: active ? AppColors.blue00F0FFColor : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ── "No" mode: list of per-species cards with individual pattern sections ──
  Widget _buildNoPatternSpeciesList() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controller.speciesEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final speciesEntry = entry.value;
            return _buildPerSpeciesCard(speciesEntry, index);
          }),
          SizedBox(height: 8.h),
          // Shared Date & Time (single for all species)
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _iconInput(
                    "Date",
                    controller.selectedDate.value,
                    Icons.calendar_today,
                    onTap: () => controller.pickDate(Get.context!),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _iconInput(
                    "Time",
                    controller.selectedTime.value,
                    Icons.access_time,
                    onTap: () => controller.pickTime(Get.context!),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Shared Notes (single for all species)
          Text(
            "Notes (Optional)",
            style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
          ),
          SizedBox(height: 8.h),
          TextField(
            maxLines: 3,
            controller: controller.notesController,
            style: getTextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Additional details about your catch...",
              hintStyle: getTextStyle(fontSize: 13, color: AppColors.grey516173Color),
              fillColor: AppColors.blue1B2134Color,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.blue153A56Color),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Add Species button
          GestureDetector(
            onTap: () => controller.addSpeciesEntry(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.teal163A42Color,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.tealColor117A88),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.blue00F0FFColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Add Species",
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blue00F0FFColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPerSpeciesCard(SpeciesEntry entry, int index) {
    return Container(
      key: ValueKey(entry.id),
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1C25),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blue00F0FFColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: "Species N" + remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Species ${index + 1}",
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  lineHeight: 27,
                ),
              ),
              if (controller.speciesEntries.length > 1)
                GestureDetector(
                  onTap: () => controller.removeSpeciesEntry(entry.id),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.close, color: Colors.red, size: 16.sp),
                  ),
                ),
            ],
          ),
          SizedBox(height: 15.h),
          // Species selector
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SpeciesDrillDownBottomSheet(
                  onSpeciesSelected: (speciesName) {
                    controller.updateSpeciesEntryName(entry.id, speciesName);
                    Navigator.pop(context);
                  },
                ),
              );
            },
            child: Obx(() {
              final currentEntry = controller.speciesEntries
                  .firstWhere((e) => e.id == entry.id, orElse: () => entry);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.blue1B2134Color,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.blue153A56Color),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currentEntry.speciesName.isEmpty
                            ? "Select Species"
                            : currentEntry.speciesName,
                        style: getTextStyle(
                          color: currentEntry.speciesName.isEmpty
                              ? AppColors.greyC8D0DBColor
                              : Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 12.h),
          // Quantity row
          Row(
            children: [
              Text(
                "Quantity",
                style: getTextStyle(
                  fontSize: 12,
                  color: AppColors.grey8B95A5Color,
                ),
              ),
              const Spacer(),
              _buildEntryQuantityCounter(entry),
            ],
          ),
          SizedBox(height: 20.h),
          // Fishing Details header
          Text(
            "Fishing Details",
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          _buildEntryFishingDetails(entry),
        ],
      ),
    );
  }

  Widget _buildEntryQuantityCounter(SpeciesEntry entry) {
    return Obx(() {
      final currentEntry = controller.speciesEntries
          .firstWhere((e) => e.id == entry.id, orElse: () => entry);
      final qty = currentEntry.quantity;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (qty > 1) controller.updateSpeciesEntryQty(entry.id, qty - 1);
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.remove,
                  color: qty > 1 ? Colors.white : Colors.white.withValues(alpha: 0.3),
                  size: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              qty.toString().padLeft(2, '0'),
              style: getTextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => controller.updateSpeciesEntryQty(entry.id, qty + 1),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(Icons.add, color: Colors.white, size: 16.sp),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEntryFishingDetails(SpeciesEntry entry) {
    return Obx(() {
      final e = controller.speciesEntries
          .firstWhere((x) => x.id == entry.id, orElse: () => entry);
      final baitOptions = controller.getFilteredBaitOptions(e.method);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Water Column Position",
            style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _entryPatternTab("Topwater", e.waterPosition == "Topwater",
                  () => controller.updateSpeciesEntryWaterPosition(entry.id, "Topwater")),
              _entryPatternTab("Suspended", e.waterPosition == "Suspended",
                  () => controller.updateSpeciesEntryWaterPosition(entry.id, "Suspended")),
              _entryPatternTab("Bottom", e.waterPosition == "Bottom",
                  () => controller.updateSpeciesEntryWaterPosition(entry.id, "Bottom")),
            ],
          ),
          SizedBox(height: 12.h),
          _miniInput(
            "Water Depth (ft)",
            "",
            controller: e.depthCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Method",
                  style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
                ),
                SizedBox(height: 8.h),
                _customDropdown(
                  key: ValueKey('${entry.id}_method'),
                  items: controller.methodOptions,
                  selectedValue: e.method,
                  hint: "Select Method",
                  onChanged: (val) {
                    if (val != null) controller.updateSpeciesEntryMethod(entry.id, val);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bait / Lure Type",
                  style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
                ),
                SizedBox(height: 8.h),
                _customDropdown(
                  key: ValueKey('${entry.id}_bait'),
                  items: baitOptions,
                  selectedValue: e.bait,
                  hint: "Select bait",
                  onChanged: (val) {
                    if (val != null) controller.updateSpeciesEntryBait(entry.id, val);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _entryPatternTab(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: active ? AppColors.teal0C98AFColor : AppColors.blue1B2134Color,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: getTextStyle(
              fontSize: 12,
              color: active ? Colors.white : AppColors.grey8B95A5Color,
            ),
          ),
        ),
      ),
    );
  }

  // ── "Yes" mode: original single shared-pattern section ───────────────────
  Widget _buildSpeciesSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFF0B1C25),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blue00F0FFColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Species 1",
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              lineHeight: 27,
            ),
          ),
          SizedBox(height: 15.h),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: Get.context!,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SpeciesDrillDownBottomSheet(
                  onSpeciesSelected: (speciesName) {
                    controller.addSpecies(speciesName);
                    Navigator.pop(context);
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.blue1B2134Color,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.blue153A56Color),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Species",
                    style: getTextStyle(color: AppColors.greyC8D0DBColor),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),
          ),
          Obx(
            () => controller.selectedSpeciesList.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      ...controller.selectedSpeciesList
                          .map((s) => _buildSelectedSpeciesRow(s)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(height: 20.h),
          _buildFishingPatternsSection(),
        ],
      ),
    );
  }

  Widget _buildSelectedSpeciesRow(String name) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue153A56Color),
      ),
      child: Row(
        children: [
          Image.asset(IconPath.fishRealIcon, height: 20.h, width: 20.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          _buildQuantityCounter(name),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => controller.removeSpecies(name),
            child: Icon(Icons.close, color: Colors.white, size: 18.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityCounter(String name) {
    return Obx(() {
      final qty = controller.quantities[name] ?? 1;
      return Container(
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (qty > 1) {
                  controller.updateQuantity(name, qty - 1);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.remove,
                  color: qty > 1 ? Colors.white : Colors.white.withValues(alpha: 0.3),
                  size: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              qty.toString().padLeft(2, '0'),
              style: getTextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                controller.updateQuantity(name, qty + 1);
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFishingPatternsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fishing Patterns",
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            lineHeight: 27,
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          "Water Column Position",
          style: getTextStyle(fontSize: 14, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 10.h),
        Obx(
          () => Row(
            children: [
              _patternTab(
                "Topwater",
                controller.waterPosition.value == "Topwater",
                () => controller.waterPosition.value = "Topwater",
              ),
              _patternTab(
                "Suspended",
                controller.waterPosition.value == "Suspended",
                () => controller.waterPosition.value = "Suspended",
              ),
              _patternTab(
                "Bottom",
                controller.waterPosition.value == "Bottom",
                () => controller.waterPosition.value = "Bottom",
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: _miniInput(
                "Water Depth (ft)",
                "",
                controller: controller.depthController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            // SizedBox(width: 15.w),
            // Expanded(
            //   child: _miniInput(
            //     "Strike Zone (ft)",
            //     "80",
            //     controller: controller.strikeZoneController,
            //   ),
            // ),
          ],
        ),
        SizedBox(height: 15.h),
        Obx(
          () => _labelDropdown(
            label: "Method",
            hint: "Select Method",
            items: controller.methodOptions,
            selectedValue: controller.selectedMethod.value,
            onChanged: (val) => controller.selectMethod(val ?? ""),
          ),
        ),
        Obx(
          () => _labelDropdown(
            label: "Bait / Lure Type",
            hint: "Select bait",
            items: controller.filteredBaitOptions,
            selectedValue: controller.selectedBait.value,
            onChanged: (val) => controller.selectedBait.value = val ?? "",
          ),
        ),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _iconInput(
                  "Date",
                  controller.selectedDate.value,
                  Icons.calendar_today,
                  onTap: () => controller.pickDate(Get.context!),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: _iconInput(
                  "Time",
                  controller.selectedTime.value,
                  Icons.access_time,
                  onTap: () => controller.pickTime(Get.context!),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          "Notes (Optional)",
          style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 8.h),
        TextField(
          maxLines: 3,
          controller: controller.notesController,
          style: getTextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Additional details about your catch...",
            hintStyle: getTextStyle(
              fontSize: 13,
              color: AppColors.grey516173Color,
            ),
            fillColor: AppColors.blue1B2134Color,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.blue153A56Color),
            ),
          ),
        ),
      ],
    );
  }

  // Small Helper Widgets
  Widget _patternTab(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: active
                ? AppColors.teal0C98AFColor
                : AppColors.blue1B2134Color,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: getTextStyle(
              fontSize: 12,
              color: active ? Colors.white : AppColors.grey8B95A5Color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniInput(
    String label,
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(fontSize: 12, color: AppColors.whiteColor),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: getTextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: getTextStyle(color: Colors.white),
            fillColor: AppColors.blue1B2134Color,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _labelDropdown({
    required String label,
    required String hint,
    required List<String> items,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
          ),
          SizedBox(height: 8.h),
          _customDropdown(
            items: items,
            selectedValue: selectedValue,
            onChanged: onChanged,
            hint: hint,
          ),
        ],
      ),
    );
  }

  Widget _customDropdown({
    Key? key,
    required List<String> items,
    required String selectedValue,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Container(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue153A56Color),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(selectedValue) ? selectedValue : null,
          hint: Text(
            hint ?? "",
            style: getTextStyle(color: AppColors.greyC8D0DBColor),
          ),
          dropdownColor: AppColors.blue1B2134Color,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          isExpanded: true,
          style: getTextStyle(color: AppColors.greyC8D0DBColor),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: getTextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _iconInput(
    String label,
    String text,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.blue1B2134Color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: getTextStyle(
                    fontSize: 12,
                    color: AppColors.greyC8D0DBColor,
                  ),
                ),
                Icon(icon, color: Colors.white, size: 18.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        ontap: controller.submitReport,
        title: "Submit Report",
        bgColor: AppColors.orangeColor,
        titleColor: Colors.white,
        fontSize: 18,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        borderRadius: 25.r,
        borderColor: Colors.transparent,
      ),
    );
  }
}
