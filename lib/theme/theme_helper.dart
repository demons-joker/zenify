import 'package:flutter/material.dart';

String _appTheme = "lightCode";
LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Changes the app theme to [_newTheme].
  void changeTheme(String _newTheme) {
    _appTheme = _newTheme;
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get gray_50 => Color(0xFFF8F8F8);
  Color get blue_gray_900 => Color(0xFF333333);
  Color get lime_300 => Color(0xFFD1F178);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get gray_100 => Color(0xFFF7F4F3);
  Color get gray_100_01 => Color(0xFFF2F4F5);
  Color get gray_500 => Color(0xFFABABAB);
  Color get gray_200 => Color(0xFFE8E8E8);
  Color get green_800 => Color(0xFF00842C);
  Color get light_green_A200 => Color(0xFFACFF59);
  Color get lime_A100 => Color(0xFFE8FD7F);
  Color get lime_500 => Color(0xFFCFE444);
  Color get blue_gray_100 => Color(0xFFCBCBCB);
  Color get gray_100_02 => Color(0xFFF8F3F3);
  Color get lime_500_01 => Color(0xFFCEE443);
  Color get gray_400 => Color(0xFFC9B0B4);
  Color get deep_orange_200 => Color(0xFFEAB39B);
  Color get black_900 => Color(0xFF000000);
  Color get gray_900 => Color(0xFF152616);
  Color get gray_50_01 => Color(0xFFFDF8F5);
  Color get gray_100_03 => Color(0xFFF2F5F6);
  Color get gray_500_01 => Color(0xFF919191);
  Color get blue_gray_900_01 => Color(0xFF30322D);
  Color get gray_400_01 => Color(0xFFB4B4B4);
  Color get gray_400_02 => Color(0xFFB3B3B3);
  Color get lime_A400 => Color(0xFFC8FD00);
  Color get blue_gray_400_19 => Color(0x198C8C8C);
  Color get gray_50_02 => Color(0xFFFCFCFC);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get redCustom => Colors.red;
  Color get whiteCustom => Colors.white;
  Color get greyCustom => Colors.grey;
  Color get colorFF52D1 => Color(0xFF52D1C6);
  Color get color4C198C => Color(0x4C198C8C);
  Color get color0000C8 => Color(0x0000C8FD);
  Color get color9EFFFF => Color(0x9EFFFFFF);
  Color get colorFF8888 => Color(0xFF888888);
  Color get orangeCustom => Colors.orange;

  // New Colors
  Color get lime_300_01 => Color(0xFFD0F077);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}
