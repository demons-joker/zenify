import 'dart:io';
import 'package:zenify/services/upload_service.dart';

class CameraUploadCoordinator {
  Future<UploadResult> submitImage(File file) {
    return UploadService.uploadImage(file);
  }
}
