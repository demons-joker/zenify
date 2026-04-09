/// 错误信息处理工具类
/// 将技术错误信息转换为用户友好的中文提示
class ErrorMessageHelper {
  /// 格式化错误信息
  ///
  /// [error] - 错误对象或字符串
  /// 返回用户友好的中文错误提示
  static String format(dynamic error) {
    if (error == null) {
      return '未知错误';
    }

    String errorStr = error.toString();

    // 网络超时错误
    if (errorStr.contains('TimeoutException') ||
        errorStr.contains('请求超时')) {
      return '网络连接超时，请检查网络后重试';
    }

    // Socket 连接错误
    if (errorStr.contains('SocketException')) {
      return '网络连接失败，请检查网络设置';
    }

    // 无网络连接
    if (errorStr.contains('No Internet') ||
        errorStr.contains('no internet') ||
        errorStr.toLowerCase().contains('network unreachable')) {
      return '无网络连接，请检查网络设置';
    }

    // 认证错误（401）
    if (errorStr.contains('401') ||
        errorStr.contains('未授权') ||
        errorStr.contains('Unauthorized')) {
      return '登录已过期，请重新登录';
    }

    // 权限错误（403）
    if (errorStr.contains('403') || errorStr.contains('拒绝访问')) {
      return '没有权限执行此操作';
    }

    // 服务器错误（500）
    if (errorStr.contains('500') ||
        errorStr.contains('服务器错误') ||
        errorStr.contains('Internal Server Error')) {
      return '服务器繁忙，请稍后重试';
    }

    // 资源不存在（404）
    if (errorStr.contains('404') || errorStr.contains('资源不存在')) {
      return '请求的资源不存在';
    }

    // 请求参数错误（400）
    if (errorStr.contains('400') ||
        errorStr.contains('请求参数错误') ||
        errorStr.contains('Bad Request')) {
      return '请求参数有误，请检查输入';
    }

    // 文件上传错误
    if (errorStr.contains('upload') || errorStr.contains('上传')) {
      return '文件上传失败，请稍后重试';
    }

    // 相机错误
    if (errorStr.contains('camera') || errorStr.contains('Camera')) {
      return '相机访问失败，请检查相机权限';
    }

    // 识别错误
    if (errorStr.contains('recogni') || errorStr.contains('识别')) {
      return '识别失败，请重新上传图片';
    }

    // MQTT 连接错误
    if (errorStr.contains('MQTT') || errorStr.contains('mqtt')) {
      return '设备连接失败，请检查设备状态';
    }

    // 权限错误
    if (errorStr.contains('Permission') || errorStr.contains('permission')) {
      return '权限不足，请在设置中开启相应权限';
    }

    // 尝试提取干净的错误信息
    String cleanError = _extractCleanError(errorStr);

    // 如果仍然太长或包含技术细节，返回通用提示
    if (cleanError.length > 50 ||
        cleanError.contains('http://') ||
        cleanError.contains('https://') ||
        cleanError.contains('Exception') ||
        cleanError.contains('Error') ||
        cleanError.contains('Format')) {
      return '操作失败，请稍后重试';
    }

    return cleanError;
  }

  /// 提取干净的错误信息
  ///
  /// [errorStr] - 原始错误字符串
  /// 返回处理后的错误信息
  static String _extractCleanError(String errorStr) {
    // 去掉异常类型前缀
    if (errorStr.contains('Exception: ')) {
      errorStr = errorStr.split('Exception: ')[1];
    } else if (errorStr.contains('Error: ')) {
      errorStr = errorStr.split('Error: ')[1];
    }

    // 去掉换行符后面的内容
    if (errorStr.contains('\n')) {
      errorStr = errorStr.split('\n')[0];
    }

    // 去掉括号内的技术信息
    final bracketRegex = RegExp(r'\([^()]*\)');
    errorStr = errorStr.replaceAll(bracketRegex, '');

    // 去掉空格
    errorStr = errorStr.trim();

    // 去掉结尾的句号
    if (errorStr.endsWith('.')) {
      errorStr = errorStr.substring(0, errorStr.length - 1);
    }

    return errorStr;
  }
}
