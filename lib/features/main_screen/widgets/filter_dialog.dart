import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
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
                    decoration: BoxDecoration(color: AppColors.blue1B2134Color, borderRadius: BorderRadius.circular(10.r)),
                    child: Icon(Icons.tune, color: AppColors.blue00F0FFColor, size: 24.sp),
                  ),
                  SizedBox(width: 15.w),
                  Text("Filters", style: getTextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1)),
                  )
                ],
              ),
              SizedBox(height: 25.h),

              // --- Species Section ---
              _sectionHeader(Icons.sailing, "Species"),
              Obx(() => Wrap(
                spacing: 10.w, runSpacing: 10.h,
                children: controller.speciesList.map((s) => _choiceChip(s, controller.selectedSpecies.contains(s), () => controller.toggleSpecies(s))).toList(),
              )),
              SizedBox(height: 25.h),

              // --- Depth Range Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader(Icons.waves, "Depth Range"),
                  Text("0ft - 500ft", style: getTextStyle(fontSize: 14, color: AppColors.grey8B95A5Color)),
                ],
              ),
              Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6.h,
                  activeTrackColor: AppColors.blue00F0FFColor,
                  inactiveTrackColor: AppColors.blue1B2134Color,
                  thumbColor: AppColors.orangeColor,
                  overlayColor: AppColors.orangeColor.withValues(alpha:  0.2),
                ),
                child: Slider(
                  value: controller.depthValue.value,
                  max: 625,
                  onChanged: (v) => controller.depthValue.value = v,
                ),
              )),
              _depthLabels(),
              SizedBox(height: 25.h),

              // --- Method Section ---
              _sectionHeader(Icons.lock, "Method"),
              Obx(() => Wrap(
                spacing: 10.w, runSpacing: 10.h,
                children: controller.methods.map((m) => _choiceChip(m, controller.selectedMethods.contains(m), () => controller.toggleMethod(m))).toList(),
              )),
              SizedBox(height: 25.h),

              // --- Report Visibility ---
              _sectionHeader(Icons.assignment, "Report Visibility"),
              Obx(() => Row(
                children: [
                  _radioOption("Public", controller.visibility.value == "Public", () => controller.visibility.value = "Public"),
                  SizedBox(width: 20.w),
                  _radioOption("Group", controller.visibility.value == "Group", () => controller.visibility.value = "Group"),
                ],
              )),
              SizedBox(height: 25.h),

              // --- Time Range Section ---
              _sectionHeader(Icons.alarm, "Time Range"),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: controller.timeRanges.map((t) => _timeButton(t, controller.selectedTime.value == t, () => controller.selectedTime.value = t)).toList(),
              )),
              SizedBox(height: 35.h),

              // --- Action Buttons ---
              Row(
                children: [
                  Expanded(child: _actionButton("Reset", AppColors.blue1B2134Color, () => controller.resetFilters())),
                  SizedBox(width: 15.w),
                  Expanded(child: _actionButton("Apply Filters", AppColors.orangeColor, () => Get.back())),
                ],
              ),
              SizedBox(height: 20.h),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.blue00F0FFColor, size: 16.sp),
                    SizedBox(width: 5.w),
                    Text("Filters update the map in real time", style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue00F0FFColor, size: 18.sp),
          SizedBox(width: 8.w),
          Text(title, style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _choiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue134D67Color : AppColors.blue1B2134Color,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected ? Border.all(color: AppColors.blue00F0FFColor) : null,
        ),
        child: Text(label, style: getTextStyle(fontSize: 14, color: isSelected ? Colors.white : AppColors.grey8B95A5Color)),
      ),
    );
  }

  Widget _radioOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.blue00F0FFColor : AppColors.grey8B95A5Color),
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
        width: 70.w, height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal163A42Color : AppColors.blue1B2134Color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.blue00F0FFColor.withValues(alpha: 0.3), blurRadius: 10)] : [],
        ),
        child: Text(label, style: getTextStyle(fontSize: 14, color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 55.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      ),
      child: Text(label, style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _depthLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ["0ft", "125ft", "250ft", "375ft", "500ft", "625ft"].map((e) => Text(e, style: getTextStyle(fontSize: 9, color: AppColors.grey8B95A5Color))).toList(),
    );
  }
}