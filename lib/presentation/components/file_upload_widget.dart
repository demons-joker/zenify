import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenify/utils/file_handling_utils.dart';

/// File upload widget with camera and gallery support
class FileUploadWidget extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  final int maxFiles;
  final String label;
  final List<String> initialFiles;

  const FileUploadWidget({
    super.key,
    required this.onFilesSelected,
    this.maxFiles = 5,
    this.label = '上传文件',
    this.initialFiles = const [],
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  late List<String> _selectedFiles;
  final _imagePicker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedFiles = List.from(widget.initialFiles);
  }

  Future<void> _pickFromCamera() async {
    try {
      setState(() => _isUploading = true);

      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final filePath = await _handleSelectedFile(photo.path);
        if (filePath != null) {
          setState(() {
            _selectedFiles.add(filePath);
            widget.onFilesSelected(_selectedFiles);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isUploading = true);

      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (var image in images) {
          if (_selectedFiles.length >= widget.maxFiles) break;

          final filePath = await _handleSelectedFile(image.path);
          if (filePath != null) {
            setState(() {
              _selectedFiles.add(filePath);
              _uploadProgress = _selectedFiles.length / widget.maxFiles;
            });
          }
        }
        widget.onFilesSelected(_selectedFiles);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<String?> _handleSelectedFile(String sourcePath) async {
    try {
      // Compress image
      final compressedPath = await FileHandlingUtils.compressImage(
        imagePath: sourcePath,
      );

      // Save to app directory
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedPath = await FileHandlingUtils.saveFileToAppDirectory(
        sourceFile: File(compressedPath),
        fileName: '$fileName.jpg',
        subdirectory: 'health_reports',
      );

      return savedPath;
    } catch (e) {
      print('Error handling file: $e');
      return null;
    }
  }

  void _removeFile(String filePath) {
    setState(() {
      _selectedFiles.remove(filePath);
    });
    widget.onFilesSelected(_selectedFiles);
    FileHandlingUtils.deleteFile(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        // Upload buttons
        if (_selectedFiles.length < widget.maxFiles)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('选择'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        // Upload progress
        if (_isUploading) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            minHeight: 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(Colors.blue[700]),
          ),
          const SizedBox(height: 8),
          Text(
            '上传中... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.blue[700],
                ),
          ),
          const SizedBox(height: 12),
        ],
        // Files list
        if (_selectedFiles.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已上传文件 (${_selectedFiles.length}/${widget.maxFiles})',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ..._selectedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filePath = entry.value;
                  final fileName = FileHandlingUtils.getFileName(filePath);
                  final fileSize =
                      FileHandlingUtils.getFileSizeString(filePath);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '文件 ${index + 1}: $fileName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '大小: $fileSize',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeFile(filePath),
                          icon: Icon(Icons.delete, color: Colors.red[700]),
                          iconSize: 20,
                          constraints: const BoxConstraints(
                            minHeight: 32,
                            minWidth: 32,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ] else if (!_isUploading) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue[200]!,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Text(
                '暂无文件',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
