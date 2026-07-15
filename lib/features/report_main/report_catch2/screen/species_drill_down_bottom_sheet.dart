import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import 'package:paytonpieper/features/report_main/report_catch2/controller/report_catch2_controller.dart';

/// A hierarchical drill-down bottom sheet for selecting a species.
///
/// Top level shows:
///   • Recent Selections  (up to 5, pulled from controller)
///   • Pelagic
///   • Reef / Bottom
///
/// Tapping a non-selectable node drills down into its children.
/// Tapping a selectable node (leaf *) calls [onSpeciesSelected] and closes.
class SpeciesDrillDownBottomSheet extends StatefulWidget {
  final Function(String) onSpeciesSelected;

  const SpeciesDrillDownBottomSheet({
    super.key,
    required this.onSpeciesSelected,
  });

  @override
  State<SpeciesDrillDownBottomSheet> createState() =>
      _SpeciesDrillDownBottomSheetState();
}

class _SpeciesDrillDownBottomSheetState
    extends State<SpeciesDrillDownBottomSheet> {
  /// Navigation stack – empty = root level
  final List<SpeciesNode> _nodeHistory = [];

  /// Attempt to get recent selections from the controller (safe, may not exist)
  List<String> get _recentSelections {
    try {
      final ctrl = Get.find<ReportCatch2Controller>();
      return ctrl.recentSpeciesSelections.toList();
    } catch (_) {
      return [];
    }
  }

  // ── Root-level nodes: [Recent Selections (virtual)] + speciesHierarchy ──
  List<_DisplayItem> get _currentItems {
    if (_nodeHistory.isEmpty) {
      // ── Root level ────────────────────────────────────────────────────────
      final items = <_DisplayItem>[];

      final recents = _recentSelections;
      if (recents.isNotEmpty) {
        // Virtual "Recent Selections" category header
        items.add(
          _DisplayItem(
            label: 'Recent Selections',
            isCategory: true,
            isRecent: false,
            onTap: null,
          ),
        );
        for (final name in recents) {
          items.add(
            _DisplayItem(
              label: name,
              isCategory: false,
              isRecent: true,
              onTap: () => _selectSpecies(name),
            ),
          );
        }
        items.add(_DisplayItem(label: '', isDivider: true));
      }

      for (final node in speciesHierarchy) {
        items.add(
          _DisplayItem(
            label: node.name,
            isCategory: false,
            isRecent: false,
            isLeaf: node.isSelectable,
            onTap: () => _onNodeTapped(node),
          ),
        );
      }

      return items;
    } else {
      // ── Drilled-down level ────────────────────────────────────────────────
      return _nodeHistory.last.children.map((node) {
        return _DisplayItem(
          label: node.name,
          isCategory: false,
          isRecent: false,
          isLeaf: node.isSelectable,
          onTap: () => _onNodeTapped(node),
        );
      }).toList();
    }
  }

  String get _currentTitle {
    if (_nodeHistory.isEmpty) return 'Species';
    return _nodeHistory.map((n) => n.name).join(' › ');
  }

  void _onNodeTapped(SpeciesNode node) {
    if (node.isSelectable) {
      _selectSpecies(node.name);
    } else {
      setState(() {
        _nodeHistory.add(node);
      });
    }
  }

  void _selectSpecies(String name) {
    widget.onSpeciesSelected(name);
  }

  void _goBack() {
    if (_nodeHistory.isNotEmpty) {
      setState(() {
        _nodeHistory.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(
            color: AppColors.blue00F0FFColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // ── Drag Handle ─────────────────────────────────────────────────
          SizedBox(height: 10.h),
          Container(
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.grey3A4B62Color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 15.h),

          // ── Header Row ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                if (_nodeHistory.isNotEmpty)
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.blue1B2134Color,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    _currentTitle,
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 15.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Divider(color: AppColors.blue153A56Color, thickness: 1),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              itemCount: _currentItems.length,
              itemBuilder: (context, index) {
                final item = _currentItems[index];

                // Section divider
                if (item.isDivider) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(
                      color: AppColors.blue153A56Color.withValues(alpha: 0.6),
                      thickness: 1,
                    ),
                  );
                }

                // Section category header (e.g. "Recent Selections")
                if (item.isCategory) {
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h, bottom: 6.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: AppColors.blue00F0FFColor,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          item.label,
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blue00F0FFColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Regular row
                final isLeaf = item.isLeaf;
                final isRecent = item.isRecent;

                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isRecent ? 10.w : 0,
                      vertical: 13.h,
                    ),
                    decoration: isRecent
                        ? BoxDecoration(
                            color: AppColors.blue1B2134Color.withValues(
                                alpha: 0.6),
                            borderRadius: BorderRadius.circular(10.r),
                          )
                        : null,
                    margin: isRecent
                        ? EdgeInsets.only(bottom: 6.h)
                        : EdgeInsets.zero,
                    child: Row(
                      children: [
                        if (isRecent) ...[
                          Icon(
                            Icons.access_time,
                            color: AppColors.grey8B95A5Color,
                            size: 15.sp,
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Expanded(
                          child: Text(
                            item.label,
                            style: getTextStyle(
                              fontSize: 15,
                              color: isRecent
                                  ? AppColors.greyC8D0DBColor
                                  : isLeaf
                                      ? Colors.white
                                      : AppColors.blue00F0FFColor,
                              fontWeight: isLeaf || isRecent
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRecent && !isLeaf)
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.blue00F0FFColor,
                            size: 22.sp,
                          )
                        else
                          Icon(
                            Icons.add_circle_outline,
                            color: AppColors.orangeColor,
                            size: 20.sp,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal helper model for display items ──────────────────────────────────
class _DisplayItem {
  final String label;
  final bool isCategory;
  final bool isRecent;
  final bool isLeaf;
  final bool isDivider;
  final VoidCallback? onTap;

  const _DisplayItem({
    required this.label,
    this.isCategory = false,
    this.isRecent = false,
    this.isLeaf = false,
    this.isDivider = false,
    this.onTap,
  });
}
