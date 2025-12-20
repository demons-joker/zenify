import 'package:flutter/material.dart';

import '../core/app_export.dart';

/**
 * CustomGradientTextField - A text input field with gradient background and custom styling
 * 
 * Features:
 * - Gradient background with customizable colors
 * - Asymmetric border radius support
 * - Custom padding and styling
 * - Form validation support
 * - Responsive design with SizeUtils
 * 
 * @param controller - TextEditingController for managing text input
 * @param placeholder - Placeholder text to display when field is empty
 * @param width - Width of the text field (optional, defaults to full width)
 * @param validator - Validation function for form validation
 * @param keyboardType - Type of keyboard to display
 * @param onTap - Callback function when field is tapped
 */
class CustomGradientTextField extends StatelessWidget {
  CustomGradientTextField({
    Key? key,
    this.controller,
    this.placeholder,
    this.width,
    this.validator,
    this.keyboardType,
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  /// Controller for managing text input
  final TextEditingController? controller;

  /// Placeholder text displayed when field is empty
  final String? placeholder;

  /// Width of the text field
  final double? width;

  /// Validation function for form validation
  final String? Function(String?)? validator;

  /// Type of keyboard to display
  final TextInputType? keyboardType;

  /// Callback function when field is tapped
  final VoidCallback? onTap;

  /// Callback function when text changes
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
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
          topRight: Radius.circular(0.h),
          bottomLeft: Radius.circular(20.h),
          bottomRight: Radius.circular(20.h),
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType ?? TextInputType.text,
        onTap: onTap,
        onChanged: onChanged,
        style: TextStyleHelper.instance.title20SemiBoldPingFangSC
            .copyWith(height: 1.4),
        decoration: InputDecoration(
          hintText: placeholder ?? "",
          hintStyle: TextStyleHelper.instance.title20SemiBoldPingFangSC
              .copyWith(height: 1.4),
          contentPadding: EdgeInsets.only(
            top: 12.h,
            right: 80.h,
            bottom: 12.h,
            left: 30.h,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
