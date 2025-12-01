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

  // Display Styles
  // Large text styles typically used for headers and hero elements

  TextStyle get display43SemiBold => TextStyle(
        fontSize: 43.fSize,
        fontWeight: FontWeight.w600,
      );

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline28SemiBoldPingFangSC => TextStyle(
        fontSize: 28.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
        color: appTheme.white_A700_01,
      );

  TextStyle get headline27SemiBoldPingFangSC => TextStyle(
        fontSize: 27.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
        color: appTheme.white_A700,
      );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title22SemiBoldPingFangSC => TextStyle(
        fontSize: 22.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
        color: appTheme.gray_900,
      );

  TextStyle get title20RegularRoboto => TextStyle(
        fontSize: 20.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      );

  TextStyle get title18MediumPingFangSC => TextStyle(
        fontSize: 18.fSize,
        fontWeight: FontWeight.w500,
        fontFamily: 'PingFang SC',
        color: appTheme.gray_500,
      );

  TextStyle get title16RegularSegoeUISymbol => TextStyle(
        fontSize: 16.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'Segoe UI Symbol',
        color: appTheme.gray_400_01,
      );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14RegularPingFangSC => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'PingFang SC',
        color: appTheme.gray_500_01,
      );

  TextStyle get body14Medium => TextStyle(
        fontSize: 14.fSize,
        fontWeight: FontWeight.w500,
      );

  TextStyle get body13SemiBoldPingFangSC => TextStyle(
        fontSize: 13.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
        color: appTheme.gray_900_01,
      );

  TextStyle get body12RegularPingFangSC => TextStyle(
        fontSize: 12.fSize,
        fontWeight: FontWeight.w400,
        fontFamily: 'PingFang SC',
        color: appTheme.gray_500_01,
      );

  // Label Styles
  // Small text styles for labels, captions, and hints

  TextStyle get label8Regular => TextStyle(
        fontSize: 8.fSize,
        fontWeight: FontWeight.w400,
      );
}
