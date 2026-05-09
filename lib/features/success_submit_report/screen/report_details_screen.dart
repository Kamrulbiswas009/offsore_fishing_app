import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments passed, or fallback to beautiful default values from the UI mockup
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>? ?? {};

    final String username = args['username'] ?? "CaptJohn_87";
    final String timestamp = args['time'] ?? "10:30 AM";
    final String zone = args['zone'] ?? "Z1";
    final List<dynamic>? speciesListArg = args['speciesList'] as List<dynamic>?;
    final List<Map<String, String>> speciesList = speciesListArg != null
        ? speciesListArg.map((e) => Map<String, String>.from(e as Map)).toList()
        : [
            {"name": "Tuna", "qty": "3"},
            {"name": "Mahi", "qty": "2"},
          ];
    final String depth = args['depth'] ?? "120 ft";
    final String position = args['position'] ?? "Suspended";
    final String method = args['method'] ?? "Trolling";
    final String bait = args['bait'] ?? "Ballyhoo";

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar Header
            _buildHeader(),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    
                    // Card 1: Reported By
                    _buildReportedByCard(username, timestamp),
                    
                    SizedBox(height: 20.h),
                    
                    // Card 2: Catch Information
                    _buildCatchInfoCard(zone, speciesList),
                    
                    SizedBox(height: 20.h),
                    
                    // Card 3: Fishing Details
                    _buildFishingDetailsCard(depth, position, method, bait),
                    
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Report Details",
            style: getTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.blue1B2134Color,
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blue00D4FFColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: getTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey8B95A5Color,
        ),
      ),
    );
  }

  Widget _buildReportedByCard(String username, String timestamp) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Reported By"),
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.tealColor117A88,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : "U",
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    timestamp,
                    style: getTextStyle(
                      fontSize: 12,
                      color: AppColors.grey8B95A5Color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatchInfoCard(String zone, List<Map<String, String>> speciesList) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Catch Information"),
          
          // Zone Display
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Zone: ",
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                  ),
                ),
                TextSpan(
                  text: zone,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Species label
          Text(
            "Species",
            style: getTextStyle(
              fontSize: 12,
              color: AppColors.grey8B95A5Color,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Wrap of species chips
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            children: speciesList.map((species) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.blue1B2134Color,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.blue00F0FFColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      IconPath.fishRealIcon,
                      height: 16.h,
                      width: 16.w,
                      color: AppColors.blue00F0FFColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      species['name'] ?? "",
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "x${species['qty'] ?? '1'}",
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.grey8B95A5Color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: 16.h),
          
          // Pattern Match container (Orange outline)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.orange3F2B27Color.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.orangeColor.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Icon(
                    Icons.insights,
                    color: AppColors.orangeFF6B35Color,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pattern Match",
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orangeFF6B35Color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "This catch matches successful patterns in this area",
                        style: getTextStyle(
                          fontSize: 11,
                          color: AppColors.grey8B95A5Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishingDetailsCard(
    String depth,
    String position,
    String method,
    String bait,
  ) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Fishing Details"),
          
          _buildDetailRow(
            label: "Depth",
            value: depth,
            iconPath: IconPath.waveIcon,
          ),
          SizedBox(height: 10.h),
          _buildDetailRow(
            label: "Position",
            value: position,
            iconData: Icons.location_on_outlined,
          ),
          SizedBox(height: 10.h),
          _buildDetailRow(
            label: "Method",
            value: method,
            iconPath: IconPath.hookIcon,
          ),
          SizedBox(height: 10.h),
          _buildDetailRow(
            label: "Bait",
            value: bait,
            iconPath: IconPath.fishRealIcon,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    String? iconPath,
    IconData? iconData,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              iconPath != null
                  ? Image.asset(
                      iconPath,
                      height: 18.h,
                      width: 18.w,
                      color: AppColors.blue00F0FFColor,
                    )
                  : Icon(
                      iconData ?? Icons.help_outline,
                      color: AppColors.blue00F0FFColor,
                      size: 18.sp,
                    ),
              SizedBox(width: 10.w),
              Text(
                label,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.greyC8D0DBColor,
            ),
          ),
        ],
      ),
    );
  }
}
