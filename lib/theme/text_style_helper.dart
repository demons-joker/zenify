import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  TextStyle get title20SemiBoldPingFangSC => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
        color: appTheme.blue_gray_900_01,
      );

  TextStyle get title20PingFangSC => TextStyle(
        fontSize: 20.fSize,
        fontFamily: 'PingFang SC',
      );

  TextStyle get title18MediumPingFangSC => TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'PingFang SC',
        color: appTheme.gray_500_01,
      );

  TextStyle get title18SemiBoldPingFangSC => TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body12SemiBoldPingFangSC => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
      );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get textStyle5 => TextStyle();
}
