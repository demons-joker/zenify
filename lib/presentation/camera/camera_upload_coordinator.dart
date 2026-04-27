import 'dart:io';
import 'package:zenify/services/upload_service.dart';
import 'package:zenify/services/user_session.dart';

class CameraUploadCoordinator {
  Future<UploadResult> submitImage(File file) async {
    final supportsUpload = await UserSession.activeDeviceSupportsImageUpload;
    if (!supportsUpload) {
      return UploadResult.failure(message: '当前设备不支持图片上传能力');
    }
    return UploadService.uploadImage(file);
  }
}
