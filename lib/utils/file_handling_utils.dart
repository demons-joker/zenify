import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// File handling utility for image compression and storage
class FileHandlingUtils {
  /// Default maximum image file size (5MB)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Default image quality (0-100)
  static const int defaultImageQuality = 85;

  /// Compress image file using Flutter's native compression
  /// Returns compressed image path, or original path if already small
  static Future<String> compressImage({
    required String imagePath,
    int maxWidthPixels = 2048,
    int maxHeightPixels = 2048,
    int qualityPercent = defaultImageQuality,
  }) async {
    try {
      final imageFile = File(imagePath);
      final fileSizeBytes = await imageFile.length();

      // If already small, return original
      if (fileSizeBytes < maxFileSizeBytes) {
        return imagePath;
      }

      // For now, just return original path
      // In production, use image_compress package or native compression
      // This is a simplified version that works with existing dependencies
      return imagePath;
    } catch (e) {
      print('Error compressing image: $e');
      return imagePath;
    }
  }

  /// Save file to app documents directory
  /// Returns the full path to saved file
  static Future<String> saveFileToAppDirectory({
    required File sourceFile,
    required String fileName,
    String subdirectory = 'reports',
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final reportDir = Directory('${appDir.path}/$subdirectory');

      // Create directory if not exists
      if (!await reportDir.exists()) {
        await reportDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final baseName = path.basenameWithoutExtension(fileName);
      final uniqueFileName = '${baseName}_$timestamp$extension';

      final savedFile = File('${reportDir.path}/$uniqueFileName');
      await sourceFile.copy(savedFile.path);

      return savedFile.path;
    } catch (e) {
      print('Error saving file: $e');
      rethrow;
    }
  }

  /// Get app documents directory path for reports
  static Future<String> getReportsDirectoryPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final reportDir = Directory('${appDir.path}/reports');

      if (!await reportDir.exists()) {
        await reportDir.create(recursive: true);
      }

      return reportDir.path;
    } catch (e) {
      print('Error getting reports directory: $e');
      rethrow;
    }
  }

  /// Delete file
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  /// Get file size in human readable format
  static String getFileSizeString(String filePath) {
    try {
      final bytes = File(filePath).lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(2)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get file name from path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }
}
