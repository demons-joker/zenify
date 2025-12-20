import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomDropdown - A stylized dropdown component with gradient background and custom styling
 * 
 * Features:
 * - Linear gradient background
 * - Custom border radius and styling
 * - Built-in validation support
 * - Configurable width constraints
 * - Consistent visual design
 * 
 * @param items - List of dropdown options to display
 * @param value - Currently selected value
 * @param hintText - Placeholder text when no value is selected
 * @param width - Optional width constraint for the dropdown
 * @param onChanged - Callback function when selection changes
 * @param validator - Optional validation function for form validation
 */
class CustomDropdown extends StatelessWidget {
  CustomDropdown({
    Key? key,
    required this.items,
    this.value,
    this.hintText,
    this.width,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  /// List of dropdown options to display
  final List<String> items;

  /// Currently selected value
  final String? value;

  /// Placeholder text when no value is selected
  final String? hintText;

  /// Optional width constraint for the dropdown
  final double? width;

  /// Callback function when selection changes
  final Function(String?)? onChanged;

  /// Optional validation function for form validation
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.96, -0.28),
          end: Alignment(0.96, 0.28),
          colors: [
            Color(0xFFFDF8F5),
            appTheme.gray_100_03,
          ],
        ),
        border: Border.all(
          color: appTheme.white_A700,
          width: 2.h,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          bottomLeft: Radius.circular(20.h),
          bottomRight: Radius.circular(20.h),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                  .copyWith(height: 1.4),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyleHelper.instance.title20SemiBoldPingFangSC
              .copyWith(height: 1.4),
          suffixIcon: Container(
            padding: EdgeInsets.all(12.h),
            child: CustomImageView(
              imagePath: ImageConstant.imgGray40002,
              height: 20.h,
              width: 20.h,
            ),
          ),
          contentPadding: EdgeInsets.only(
            top: 12.h,
            right: 50.h,
            bottom: 12.h,
            left: 30.h,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        dropdownColor: appTheme.gray_50_01,
        icon: SizedBox.shrink(),
        style: TextStyleHelper.instance.title20SemiBoldPingFangSC
            .copyWith(height: 1.4),
      ),
    );
  }
}
