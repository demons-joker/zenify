import 'package:flutter/material.dart';

/// Toast 类型枚举
enum ToastType {
  success,  // 成功 - 绿色
  error,    // 错误 - 红色
  warning,  // 警告 - 橙色
  info,     // 信息 - 蓝色
}

/// Toast 提示工具类
/// 提供统一的错误提示、成功提示、警告提示等
class ToastHelper {
  /// 显示 Toast
  ///
  /// [context] - 上下文
  /// [message] - 提示消息
  /// [type] - Toast 类型，默认为 info
  /// [duration] - 显示时长，默认 3 秒
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final icon = _getIcon(type);
    final backgroundColor = _getBackgroundColor(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
        elevation: 6,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// 成功提示（绿色）
  ///
  /// [context] - 上下文
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 3 秒
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
    );
  }

  /// 错误提示（红色）
  ///
  /// [context] - 上下文
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 5 秒
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
    );
  }

  /// 警告提示（橙色）
  ///
  /// [context] - 上下文
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 3 秒
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
    );
  }

  /// 信息提示（蓝色）
  ///
  /// [context] - 上下文
  /// [message] - 提示消息
  /// [duration] - 显示时长，默认 3 秒
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
    );
  }

  /// 隐藏当前显示的 Toast
  ///
  /// [context] - 上下文
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// 获取对应的图标
  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  /// 获取对应的背景色
  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Color(0xFF4CAF50); // 绿色
      case ToastType.error:
        return Color(0xFFF44336); // 红色
      case ToastType.warning:
        return Color(0xFFFF9800); // 橙色
      case ToastType.info:
        return Color(0xFF2196F3); // 蓝色
    }
  }
}
