import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * A customizable icon button widget with configurable appearance and behavior.
 * 
 * This widget provides a flexible icon button implementation that supports:
 * - Custom SVG/PNG icons via CustomImageView
 * - Configurable background colors and border radius
 * - Responsive sizing with SizeUtils
 * - Material Design interaction effects
 * 
 * @param iconPath - Path to the icon asset (SVG, PNG, or network image)
 * @param onPressed - Callback function triggered when button is pressed
 * @param backgroundColor - Background color of the button
 * @param borderRadius - Border radius for rounded corners
 * @param padding - Internal padding around the icon
 * @param size - Overall size of the button (width and height)
 */
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.iconPath,
    this.onPressed,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.size,
  }) : super(key: key);

  /// Path to the icon asset (SVG, PNG, or network image)
  final String iconPath;

  /// Callback function triggered when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// Internal padding around the icon
  final EdgeInsetsGeometry? padding;

  /// Overall size of the button (width and height)
  final double? size;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 28.h;
    final effectiveBorderRadius = borderRadius ?? 14.h;
    final effectiveBackgroundColor = backgroundColor ?? Color(0xFFF8F8F8);
    final effectivePadding = padding ?? EdgeInsets.all(6.h);

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: IconButton(
        onPressed: onPressed,
        padding: effectivePadding,
        style: IconButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
        ),
        icon: CustomImageView(
          imagePath: iconPath,
          height: (effectiveSize - (effectivePadding.horizontal)).h,
          width: (effectiveSize - (effectivePadding.horizontal)).h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
