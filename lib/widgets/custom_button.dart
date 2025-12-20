import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomButton - A flexible button component with gradient border support
 * 
 * Features:
 * - Gradient border styling with customizable colors
 * - Optional trailing icon support
 * - Box shadow effects
 * - Responsive design with SizeUtils
 * - Configurable colors and styling
 * 
 * @param text - Button label text
 * @param onPressed - Callback function when button is tapped
 * @param width - Required width of the button
 * @param rightIcon - Optional path to trailing icon
 * @param backgroundColor - Background color of the button
 * @param textColor - Color of the button text
 * @param borderGradientColors - List of colors for gradient border
 * @param height - Height of the button
 * @param borderRadius - Border radius of the button
 * @param fontSize - Font size of the button text
 * @param fontWeight - Font weight of the button text
 * @param shadowColor - Color of the box shadow
 * @param shadowOffset - Offset of the box shadow
 * @param shadowBlurRadius - Blur radius of the box shadow
 * @param padding - Internal padding of the button
 * @param margin - External margin of the button
 */
class CustomButton extends StatelessWidget {
  CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.width,
    this.rightIcon,
    this.backgroundColor,
    this.textColor,
    this.borderGradientColors,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.shadowColor,
    this.shadowOffset,
    this.shadowBlurRadius,
    this.padding,
    this.margin,
  }) : super(key: key);

  /// Button label text
  final String text;

  /// Callback function when button is tapped
  final VoidCallback? onPressed;

  /// Required width of the button
  final double width;

  /// Optional path to trailing icon
  final String? rightIcon;

  /// Background color of the button
  final Color? backgroundColor;

  /// Color of the button text
  final Color? textColor;

  /// List of colors for gradient border
  final List<Color>? borderGradientColors;

  /// Height of the button
  final double? height;

  /// Border radius of the button
  final double? borderRadius;

  /// Font size of the button text
  final double? fontSize;

  /// Font weight of the button text
  final FontWeight? fontWeight;

  /// Color of the box shadow
  final Color? shadowColor;

  /// Offset of the box shadow
  final Offset? shadowOffset;

  /// Blur radius of the box shadow
  final double? shadowBlurRadius;

  /// Internal padding of the button
  final EdgeInsets? padding;

  /// External margin of the button
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 52.h,
      margin: margin ?? EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Color(0x4C198C8C),
            offset: shadowOffset ?? Offset(6.h, 6.h),
            blurRadius: shadowBlurRadius ?? 15.h,
          ),
        ],
        borderRadius: BorderRadius.circular(borderRadius ?? 26.h),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFFC8FD00),
          foregroundColor: textColor ?? appTheme.whiteCustom,
          elevation: 0,
          shadowColor: appTheme.transparentCustom,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 26.h),
          ),
          padding: padding ??
              EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 30.h,
              ),
        ).copyWith(
          side: WidgetStateProperty.all(
            BorderSide.none,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: GradientBoxBorder(
              gradient: LinearGradient(
                begin: Alignment(0.85, -0.53),
                end: Alignment(-0.85, 0.53),
                colors: borderGradientColors ??
                    [
                      Color(0x0000C8FD),
                      appTheme.lime_A400,
                    ],
              ),
              width: 2.h,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 26.h),
          ),
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyleHelper.instance.textStyle5.copyWith(
                        color: textColor ?? appTheme.whiteCustom, height: 1.17),
                  ),
                ),
                if (rightIcon != null) ...[
                  SizedBox(width: 8.h),
                  CustomImageView(
                    imagePath: rightIcon!,
                    height: 20.h,
                    width: 24.h,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
