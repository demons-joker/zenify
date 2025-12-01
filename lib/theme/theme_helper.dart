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
  Color get lime_A400 => Color(0xFFC8FD00);
  Color get gray_200 => Color(0xFFE8E8E8);
  Color get green_800 => Color(0xFF00842C);
  Color get light_green_A200 => Color(0xFFACFF59);
  Color get lime_A100 => Color(0xFFE8FD7F);
  Color get lime_500 => Color(0xFFCFE444);
  Color get blue_gray_100 => Color(0xFFCBCBCB);
  Color get gray_100 => Color(0xFFF8F3F3);
  Color get lime_500_01 => Color(0xFFCEE443);
  Color get gray_400 => Color(0xFFC9B0B4);
  Color get deep_orange_200 => Color(0xFFEAB39B);
  Color get black_900 => Color(0xFF000000);
  Color get gray_900 => Color(0xFF152616);
  Color get gray_50 => Color(0xFFFDF8F5);
  Color get gray_100_01 => Color(0xFFF2F5F6);
  Color get black_900_01 => Color(0xFF0E0E0E);
  Color get gray_500 => Color(0xFF919191);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get gray_900_01 => Color(0xFF232323);
  Color get gray_200_01 => Color(0xFFEEEEEE);
  Color get gray_500_01 => Color(0xFFA3A3A3);
  Color get white_A700_01 => Color(0xFFFEFEFE);
  Color get lime_200 => Color(0xFFD6EC9B);
  Color get gray_800 => Color(0xFF454A30);
  Color get gray_600 => Color(0xFF787B6E);
  Color get gray_50_01 => Color(0xFFFCFCFC);
  Color get blue_gray_400_19 => Color(0x198C8C8C);
  Color get gray_400_01 => Color(0xFFBCBCBC);
  Color get light_green_A700 => Color(0xFF7ED321);
  Color get gray_50_02 => Color(0xFFF5FDFF);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get greyCustom => Colors.grey;
  Color get color3F0000 => Color(0x3F000000);
  Color get color88FF88 => Color(0x88FF8888);
  Color get color2D0000 => Color(0x2D000000);
  Color get color0000C8 => Color(0x0000C8FD);
  Color get color1CC8FD => Color(0x1CC8FD00);
  Color get color190000 => Color(0x19000000);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}
