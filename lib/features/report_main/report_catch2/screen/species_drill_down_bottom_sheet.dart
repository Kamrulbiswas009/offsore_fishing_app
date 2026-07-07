import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/models/species_node.dart';

class SpeciesDrillDownBottomSheet extends StatefulWidget {
  final Function(String) onSpeciesSelected;

  const SpeciesDrillDownBottomSheet({
    super.key,
    required this.onSpeciesSelected,
  });

  @override
  State<SpeciesDrillDownBottomSheet> createState() => _SpeciesDrillDownBottomSheetState();
}

class _SpeciesDrillDownBottomSheetState extends State<SpeciesDrillDownBottomSheet> {
  // Navigation stack to keep track of user's current directory path
  final List<SpeciesNode> _nodeHistory = [];

  List<SpeciesNode> get _currentOptions {
    if (_nodeHistory.isEmpty) {
      return speciesHierarchy;
    } else {
      return _nodeHistory.last.children;
    }
  }

  String get _currentPath {
    if (_nodeHistory.isEmpty) {
      return "Select Category";
    }
    return _nodeHistory.map((n) => n.name).join(" > ");
  }

  void _onNodeTapped(SpeciesNode node) {
    if (node.isSelectable) {
      widget.onSpeciesSelected(node.name);
    } else {
      setState(() {
        _nodeHistory.add(node);
      });
    }
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
      height: MediaQuery.of(context).size.height * 0.6,
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
          // Drag Handle
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

          // Header Row
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
                    _currentPath,
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

          // List of current level options
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: _currentOptions.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.blue153A56Color.withValues(alpha: 0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final option = _currentOptions[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  onTap: () => _onNodeTapped(option),
                  title: Text(
                    option.name,
                    style: getTextStyle(
                      fontSize: 16,
                      color: option.isSelectable ? Colors.white : AppColors.blue00F0FFColor,
                      fontWeight: option.isSelectable ? FontWeight.w500 : FontWeight.bold,
                    ),
                  ),
                  trailing: option.isSelectable
                      ? Icon(
                          Icons.add_circle_outline,
                          color: AppColors.orangeColor,
                          size: 22.sp,
                        )
                      : Icon(
                          Icons.chevron_right,
                          color: AppColors.blue00F0FFColor,
                          size: 22.sp,
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
