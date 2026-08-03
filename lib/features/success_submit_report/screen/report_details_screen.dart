import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/helpers/app_helper.dart';
import 'package:paytonpieper/features/success_submit_report/controller/report_details_controller.dart';

class ReportDetailsScreen extends GetView<ReportDetailsController> {
  const ReportDetailsScreen({super.key});

  String _capitalizeAndFormat(String val) {
    if (val.isEmpty) return "";
    return val.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar Header
            _buildHeader(),
            
            // Scrollable Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blue00F0FFColor,
                    ),
                  );
                }

                final report = controller.reportData.value;

                final String username = controller.username;
                String timestamp = controller.fallbackTime;
                String zone = controller.fallbackZone;
                List<Map<String, String>> speciesList = controller.fallbackSpeciesList;
                String depth = controller.fallbackDepth;
                String position = controller.fallbackPosition;
                String method = controller.fallbackMethod;
                String bait = controller.fallbackBait;

                if (report != null) {
                  // Format timestamp
                  final catchTimestampStr = report['catchTimestamp']?.toString();
                  if (catchTimestampStr != null) {
                    final parsed = DateTime.tryParse(catchTimestampStr)?.toLocal();
                    if (parsed != null) {
                      timestamp = "${AppHelperFunctions.getFormattedDate(parsed, format: 'hh:mm a')} (${AppHelperFunctions.getFormattedDate(parsed, format: 'MM/dd/yyyy')})";
                    }
                  }

                  // Zone details
                  final zoneId = report['zoneId']?.toString() ?? "";
                  final zoneData = report['zone'] as Map?;
                  final displayName = zoneData?['displayName']?.toString();
                  zone = (displayName != null && displayName.isNotEmpty) ? displayName : zoneId;

                  // Species — from allSpecies array
                  final allSpeciesArg = report['allSpecies'] as List?;
                  if (allSpeciesArg != null && allSpeciesArg.isNotEmpty) {
                    speciesList = allSpeciesArg.map((e) {
                      final m = e as Map;
                      return {
                        "name": (m['speciesName'] ?? "").toString(),
                        "qty": (m['quantity'] ?? "1").toString(),
                      };
                    }).toList();
                  }

                  // Fishing patterns — aggregate from fishingPatterns array
                  final patterns = report['fishingPatterns'] as List?;
                  if (patterns != null && patterns.isNotEmpty) {
                    // Use first pattern as primary, collect unique values
                    final depthValues = <String>{};
                    final positionValues = <String>{};
                    final methodValues = <String>{};
                    final baitValues = <String>{};

                    for (final p in patterns) {
                      final pm = p as Map;
                      final d = pm['waterDepthFt'];
                      if (d != null) depthValues.add("$d ft");
                      final wc = pm['waterColumn']?.toString();
                      if (wc != null) positionValues.add(_capitalizeAndFormat(wc));
                      final fm = pm['fishingMethod']?.toString();
                      if (fm != null) methodValues.add(_capitalizeAndFormat(fm));
                      final bl = pm['baitLureType']?.toString();
                      if (bl != null) baitValues.add(_capitalizeAndFormat(bl));
                    }

                    if (depthValues.isNotEmpty) depth = depthValues.join(', ');
                    if (positionValues.isNotEmpty) position = positionValues.join(', ');
                    if (methodValues.isNotEmpty) method = methodValues.join(', ');
                    if (baitValues.isNotEmpty) bait = baitValues.join(', ');
                  }
                }

                final String? notes = report != null
                    ? (report['notes']?.toString() ?? report['note']?.toString())
                    : controller.fallbackNote;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    children: [
                      if (controller.errorMessage.value.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: getTextStyle(
                                    fontSize: 13,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                onPressed: () {
                                  if (controller.reportId != null) {
                                    controller.fetchReportDetails(controller.reportId!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                      ],

                      SizedBox(height: 10.h),
                      
                      // Card 1: Reported By
                      _buildReportedByCard(username, timestamp, controller.profileImageUrl),
                      
                      SizedBox(height: 20.h),
                      
                      // Card 2: Catch Information
                      _buildCatchInfoCard(zone, speciesList),
                      
                      SizedBox(height: 20.h),
                      
                      // Card 3: Fishing Details
                      _buildFishingDetailsCard(depth, position, method, bait),
                      
                      if (notes != null && notes.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        _buildNotesCard(notes),
                      ],

                      SizedBox(height: 30.h),
                    ],
                  ),
                );
              }),
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

  Widget _buildReportedByCard(String username, String timestamp, String? profileImageUrl) {
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
                backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: (profileImageUrl == null || profileImageUrl.isEmpty)
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : "U",
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
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

  Widget _buildNotesCard(String notes) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Captain Notes"),
          Text(
            notes,
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              lineHeight: 18,
            ),
          ),
        ],
      ),
    );
  }
}
