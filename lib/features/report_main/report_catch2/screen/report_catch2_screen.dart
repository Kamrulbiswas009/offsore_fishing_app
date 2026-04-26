import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/features/report_main/report_catch2/controller/report_catch2_controller.dart';
import '../../../../core/utils/constants/colors.dart';

class ReportCatch2Screen extends GetView<ReportCatch2Controller> {
  const ReportCatch2Screen({super.key});

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 20.h),
              _buildStepper(),
              SizedBox(height: 25.h),
              _buildPatternToggle(),
              SizedBox(height: 25.h),
              Text(
                "Species Caught",
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 15.h),
              _buildSpeciesSection(),
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
          Icon(Icons.wifi, color: AppColors.green10B981Color, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            "Online - Report will sync instantly",
            style: getTextStyle(
              fontSize: 13,
              color: AppColors.green10B981Color,
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
            () => Row(
              children: [
                _toggleBtn(
                  "Yes",
                  controller.isSamePattern.value,
                  () => controller.isSamePattern.value = true,
                ),
                SizedBox(width: 10.w),
                _toggleBtn(
                  "No",
                  !controller.isSamePattern.value,
                  () => controller.isSamePattern.value = false,
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            controller.isSamePattern.value
                ? "Yes=One Pattern for all species above"
                : "No=Different Pattern for different species above",
            style: getTextStyle(fontSize: 12, color: AppColors.greyC8D0DBColor),
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

  Widget _buildSpeciesSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue00F0FFColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Species 1",
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15.h),
          _customDropdown("Select Species"),
          SizedBox(height: 12.h),
          Obx(
            () => Wrap(
              spacing: 8.w,
              children: controller.selectedSpeciesList
                  .map((s) => _speciesChip(s))
                  .toList(),
            ),
          ),
          SizedBox(height: 20.h),
          _buildFishingDetailsCard(),
          SizedBox(height: 20.h),
          _buildFishingPatternsSection(),
        ],
      ),
    );
  }

  Widget _speciesChip(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue00F0FFColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.set_meal, color: AppColors.blue00F0FFColor, size: 14.sp),
          SizedBox(width: 5.w),
          Text(name, style: getTextStyle(fontSize: 12, color: Colors.white)),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: () => controller.removeSpecies(name),
            child: Icon(Icons.close, color: Colors.white, size: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildFishingDetailsCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fishing Details",
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          _quantityRow("Snapper", "01"),
          _quantityRow("Tuna", "10"),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.add_circle,
              color: AppColors.orangeColor,
              size: 28.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityRow(String species, String qty) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quantity",
            style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
          ),
          SizedBox(height: 5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.blue0D2B43Color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(species, style: getTextStyle(color: Colors.white)),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ],
                ),
                Text(qty, style: getTextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishingPatternsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fishing Patterns",
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          "Water Column Position",
          style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _patternTab("Topwater", false),
            _patternTab("Suspended", true),
            _patternTab("Bottom", false),
          ],
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(child: _miniInput("Water Depth (ft)", "120")),
            SizedBox(width: 15.w),
            Expanded(child: _miniInput("Strike Zone (ft)", "80")),
          ],
        ),
        SizedBox(height: 15.h),
        _labelDropdown("Method", "Select Method"),
        _labelDropdown("Bait / Lure Type", "Select bait"),
        Row(
          children: [
            Expanded(
              child: _iconInput("Date", "Select Date", Icons.calendar_today),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _iconInput("Time", "Select Time", Icons.access_time),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          "Notes (Optional)",
          style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 8.h),
        TextField(
          maxLines: 3,
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
  Widget _patternTab(String title, bool active) {
    return Expanded(
      child: Container(
        height: 40.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: active ? AppColors.tealColor117A88 : AppColors.blue1B2134Color,
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
    );
  }

  Widget _miniInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 8.h),
        TextField(
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

  Widget _labelDropdown(String label, String hint) {
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
          _customDropdown(hint),
        ],
      ),
    );
  }

  Widget _customDropdown(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.blue153A56Color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: getTextStyle(color: AppColors.greyC8D0DBColor)),
          Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _iconInput(String label, String text, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 8.h),
        Container(
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
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: controller.submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Text(
          "Submit Report",
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
