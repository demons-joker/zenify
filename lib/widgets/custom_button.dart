import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

import '../core/app_export.dart';

/**
 * CustomButton - A flexible button component that supports various styling options
 * including gradient borders, custom backgrounds, shadows, and responsive sizing.
 * 
 * @param text - The text content displayed on the button
 * @param onPressed - Callback function when button is pressed
 * @param width - Width of the button (optional, defaults to fit content)
 * @param height - Height of the button (optional, defaults to auto)
 * @param backgroundColor - Background color of the button
 * @param textColor - Color of the button text
 * @param textStyle - Custom text style for the button text
 * @param borderRadius - Border radius for rounded corners
 * @param gradientBorder - Gradient configuration for border
 * @param boxShadow - Shadow configuration for the button
 * @param padding - Internal padding of the button
 * @param margin - External margin around the button
 */
class CustomButton extends StatelessWidget {
  CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.borderRadius,
    this.gradientBorder,
    this.boxShadow,
    this.padding,
    this.margin,
  }) : super(key: key);

  /// The text content displayed on the button
  final String text;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Width of the button
  final double? width;

  /// Height of the button
  final double? height;

  /// Background color of the button
  final Color? backgroundColor;

  /// Color of the button text
  final Color? textColor;

  /// Custom text style for the button text
  final TextStyle? textStyle;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// Gradient configuration for border
  final Gradient? gradientBorder;

  /// Shadow configuration for the button
  final List<BoxShadow>? boxShadow;

  /// Internal padding of the button
  final EdgeInsetsGeometry? padding;

  /// External margin around the button
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            color: backgroundColor ?? appTheme.transparentCustom,
            borderRadius: BorderRadius.circular(borderRadius ?? 8.h),
            border: gradientBorder != null
                ? GradientBoxBorder(
                    gradient: gradientBorder!,
                    width: 2.h,
                  )
                : null,
            boxShadow: boxShadow,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.transparentCustom,
              shadowColor: appTheme.transparentCustom,
              padding: padding ??
                  EdgeInsets.symmetric(
                    horizontal: 16.h,
                    vertical: 8.h,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 8.h),
              ),
            ),
            child: Text(
              text,
              style: textStyle ??
                  TextStyleHelper.instance.body14Medium
                      .copyWith(color: textColor ?? appTheme.whiteCustom),
            ),
          ),
        );
      },
    );
  }
}
