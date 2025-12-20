import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomProgressAppBar - A custom AppBar component with integrated progress tracking
 * 
 * Features:
 * - Left-aligned icon button with customizable icon and action
 * - Center progress bar with linear gradient background
 * - Right-aligned step indicator text (e.g., "1/10")
 * - Responsive design with proper scaling
 * - Customizable colors and styling
 * - Shadow effect support
 * 
 * @param leadingIcon - Path to the leading icon (SVG/PNG)
 * @param onLeadingPressed - Callback function for leading icon tap
 * @param currentStep - Current step number (default: 1)
 * @param totalSteps - Total number of steps (default: 10)
 * @param progressValue - Progress value between 0.0 and 1.0 (default: 0.1)
 * @param backgroundColor - AppBar background color
 * @param progressBackgroundColor - Progress bar background color
 * @param progressColor - Progress bar fill color
 * @param stepTextColor - Step indicator text color
 * @param iconBackgroundColor - Icon button background color
 * @param showShadow - Whether to show shadow effect (default: true)
 * @param height - Custom height for the AppBar (default: 80.h)
 */
class CustomProgressAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomProgressAppBar({
    Key? key,
    this.leadingIcon,
    this.onLeadingPressed,
    this.currentStep,
    this.totalSteps,
    this.progressValue,
    this.backgroundColor,
    this.progressBackgroundColor,
    this.progressColor,
    this.stepTextColor,
    this.iconBackgroundColor,
    this.showShadow,
    this.height,
  }) : super(key: key);

  /// Path to the leading icon image
  final String? leadingIcon;

  /// Callback function when leading icon is pressed
  final VoidCallback? onLeadingPressed;

  /// Current step number
  final int? currentStep;

  /// Total number of steps
  final int? totalSteps;

  /// Progress value (0.0 to 1.0)
  final double? progressValue;

  /// Background color of the AppBar
  final Color? backgroundColor;

  /// Background color of the progress bar
  final Color? progressBackgroundColor;

  /// Fill color of the progress bar
  final Color? progressColor;

  /// Text color for step indicator
  final Color? stepTextColor;

  /// Background color for icon button
  final Color? iconBackgroundColor;

  /// Whether to show shadow effect
  final bool? showShadow;

  /// Custom height for AppBar
  final double? height;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 80.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Color(0x9EFFFFFF),
      elevation: showShadow ?? true ? 4.0 : 0.0,
      shadowColor: showShadow ?? true ? Color(0xFF888888).withAlpha(128) : null,
      automaticallyImplyLeading: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.h),
      ),
      title: _buildAppBarContent(context),
      titleSpacing: 0,
    );
  }

  Widget _buildAppBarContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      child: Row(
        children: [
          _buildLeadingIcon(),
          SizedBox(width: 54.h),
          _buildProgressSection(),
          SizedBox(width: 10.h),
          _buildStepText(),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 28.h,
      height: 28.h,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14.h),
      ),
      child: IconButton(
        padding: EdgeInsets.all(6.h),
        onPressed: onLeadingPressed,
        icon: CustomImageView(
          imagePath: leadingIcon ?? ImageConstant.imgVector,
          height: 16.h,
          width: 16.h,
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Expanded(
      child: Container(
        height: 20.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            colors: [
              progressBackgroundColor ?? Color(0xFFF7F4F3),
              appTheme.gray_100_01,
            ],
          ),
          border: Border.all(
            color: appTheme.white_A700,
            width: 2.h,
          ),
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.h),
          child: LinearProgressIndicator(
            value: progressValue ?? 0.1,
            backgroundColor: appTheme.transparentCustom,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? Color(0xFF52D1C6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepText() {
    final current = currentStep ?? 1;
    final total = totalSteps ?? 10;

    return Text(
      "$current/$total",
      style: TextStyleHelper.instance.body12SemiBoldPingFangSC
          .copyWith(color: stepTextColor ?? Color(0xFFABABAB), height: 1.4),
    );
  }
}
