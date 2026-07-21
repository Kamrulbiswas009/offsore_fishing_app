import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/report_main/report_catch2/screen/species_drill_down_bottom_sheet.dart';
import '../controller/filter_controller.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FilterController());

    return Dialog(
      backgroundColor: AppColors.backgroundDarkColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.blue1B2134Color,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: AppColors.blue00F0FFColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    "Filters",
                    style: getTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25.h),

              _sectionHeader(IconPath.fishIcon, "Species"),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => SpeciesDrillDownBottomSheet(
                            onSpeciesSelected: (_) {},
                            isMultiSelect: true,
                            initialSelectedSpecies: controller.selectedSpecies.toList(),
                            onMultiSpeciesSelected: (selected) {
                              controller.selectedSpecies.assignAll(selected);
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.blue1B2134Color,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: AppColors.blue00F0FFColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                controller.selectedSpecies.isEmpty
                                    ? "Select Species"
                                    : controller.isAllSpeciesSelected
                                        ? "All Species Selected"
                                        : "${controller.selectedSpecies.length} Species Selected",
                                style: getTextStyle(
                                  fontSize: 14,
                                  color: controller.selectedSpecies.isEmpty
                                      ? AppColors.grey8B95A5Color
                                      : Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.blue00F0FFColor,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (controller.selectedSpecies.isNotEmpty) ...[
                      SizedBox(height: 15.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: controller.isAllSpeciesSelected
                            ? [
                                _choiceChip(
                                  "All Species",
                                  true,
                                  () => controller.clearAllSpecies(),
                                  showCloseIcon: true,
                                ),
                              ]
                            : controller.selectedSpecies
                                .map(
                                  (s) => _choiceChip(
                                    s,
                                    true,
                                    () => controller.toggleSpecies(s),
                                    showCloseIcon: true,
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 25.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader(IconPath.waveIcon, "Depth Range"),
                  Obx(
                    () => Text(
                      controller.depthValue.value.toInt() >= 625
                          ? "0ft - 625+ ft"
                          : "0ft - ${controller.depthValue.value.toInt()}ft",
                      style: getTextStyle(
                        fontSize: 14,
                        color: AppColors.grey8B95A5Color,
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6.h,
                    activeTrackColor: AppColors.blue00F0FFColor,
                    inactiveTrackColor: AppColors.blue1B2134Color,
                    thumbColor: AppColors.orangeColor,
                    overlayColor: AppColors.orangeColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: controller.depthValue.value,
                    max: 625,
                    onChanged: (v) => controller.depthValue.value = v,
                  ),
                ),
              ),
              _depthLabels(),
              SizedBox(height: 25.h),

              _sectionHeader(IconPath.hookIcon, "Method", Color(0xFF00D4FF)),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppColors.blue1B2134Color,
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: AppColors.blue00F0FFColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: null,
                          hint: Text(
                            "Select Method",
                            style: getTextStyle(
                              fontSize: 14,
                              color: AppColors.grey8B95A5Color,
                            ),
                          ),
                          dropdownColor: AppColors.backgroundDarkColor,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.blue00F0FFColor,
                            size: 20.sp,
                          ),
                          isExpanded: true,
                          style: getTextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: "all_methods",
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "All Methods (Select All)",
                                    style: getTextStyle(
                                      fontSize: 14,
                                      color: controller.isAllMethodsSelected
                                          ? AppColors.blue00F0FFColor
                                          : Colors.white,
                                      fontWeight: controller.isAllMethodsSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if (controller.isAllMethodsSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.blue00F0FFColor,
                                      size: 18.sp,
                                    ),
                                ],
                              ),
                            ),
                            ...controller.methods.map((String value) {
                              final isSelected = controller.selectedMethods.contains(value);
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      value,
                                      style: getTextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? AppColors.blue00F0FFColor
                                            : Colors.white,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.blue00F0FFColor,
                                        size: 18.sp,
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            if (value == "all_methods") {
                              controller.toggleSelectAllMethods();
                            } else if (value != null) {
                              controller.toggleMethod(value);
                            }
                          },
                        ),
                      ),
                    ),
                    if (controller.selectedMethods.isNotEmpty) ...[
                      SizedBox(height: 15.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: controller.isAllMethodsSelected
                            ? [
                                _choiceChip(
                                  "All Methods",
                                  true,
                                  () => controller.clearAllMethods(),
                                  showCloseIcon: true,
                                ),
                              ]
                            : controller.selectedMethods
                                .map(
                                  (m) => _choiceChip(
                                    m,
                                    true,
                                    () => controller.toggleMethod(m),
                                    showCloseIcon: true,
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 25.h),

              _sectionHeader(
                IconPath.world,
                "Report Visibility",
                Color(0xFF00D4FF),
              ),
              Obx(
                () => Row(
                  children: [
                    _visibilityOption(
                      "Public",
                      controller.selectedVisibilities.contains("Public"),
                      () => controller.toggleVisibility("Public"),
                    ),
                    SizedBox(width: 20.w),
                    _visibilityOption(
                      "Group",
                      controller.selectedVisibilities.contains("Group"),
                      () => controller.toggleVisibility("Group"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),

              _sectionHeader(IconPath.clock, "Timeframe"),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: controller.timeRanges
                      .map(
                        (t) => _timeButton(
                          t,
                          controller.selectedTime.value == t,
                          () => controller.selectedTime.value = t,
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 35.h),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      "Reset",
                      AppColors.blue1B2134Color,
                      () => controller.resetFilters(),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _actionButton(
                      "Apply Filters",
                      AppColors.orangeColor,
                      () => controller.applyFilters(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.blue00F0FFColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Filters update the map in real time",
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.grey8B95A5Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String icon, String title, [Color? color]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Image.asset(icon, height: 18.h, width: 18.w, color: color),
          SizedBox(width: 8.w),
          Text(
            title,
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceChip(String label, bool isSelected, VoidCallback onTap, {bool showCloseIcon = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blue134D67Color
              : AppColors.blue1B2134Color,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: AppColors.blue00F0FFColor)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: getTextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : AppColors.grey8B95A5Color,
              ),
            ),
            if (showCloseIcon) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.close,
                size: 14.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _visibilityOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected
                ? AppColors.blue00F0FFColor
                : AppColors.grey8B95A5Color,
          ),
          SizedBox(width: 8.w),
          Text(label, style: getTextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _timeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teal163A42Color
              : AppColors.blue1B2134Color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.blue00F0FFColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: getTextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 45.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
      child: Text(
        label,
        style: getTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _depthLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ["0ft", "125ft", "250ft", "375ft", "500ft", "625+ ft"]
          .map(
            (e) => Text(
              e,
              style: getTextStyle(
                fontSize: 9,
                color: AppColors.grey8B95A5Color,
              ),
            ),
          )
          .toList(),
    );
  }
}
