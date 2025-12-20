import 'package:flutter/material.dart';

import '../core/app_export.dart';
import 'custom_gradient_text_field.dart';
import 'custom_image_view.dart';

class BottomInputSection extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final VoidCallback? onPressed;
  final String? buttonImagePath;
  final Function(String)? onChanged;
  final String? buttonText;
  final TextStyle? buttonTextStyle;

  const BottomInputSection({
    super.key,
    this.controller,
    this.placeholder = 'Add more',
    this.onPressed,
    this.buttonImagePath,
    this.onChanged,
    this.buttonText,
    this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, -2.h),
            blurRadius: 10.h,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          spacing: 16.h,
          children: [
            Expanded(
              flex: 3,
              child: CustomGradientTextField(
                controller: controller,
                placeholder: placeholder,
                width: double.infinity,
                onChanged: onChanged,
              ),
            ),
            IntrinsicWidth(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Color(0xFFC8FD00),
                  borderRadius: BorderRadius.circular(22.h),
                  border: Border.all(
                    width: 2.h,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4C198C8C),
                      offset: Offset(6.h, 6.h),
                      blurRadius: 15.h,
                    ),
                  ],
                ),
                child: CustomImageView(
                  imagePath: buttonImagePath ?? ImageConstant.imgButton,
                  text: buttonText,
                  textStyle: buttonTextStyle,
                  height: 22.h,
                  onTap: onPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
