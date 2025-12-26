import 'dart:async';
import 'dart:io';

class Message {
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final List<File> files; // 新增文件支持

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    List<File>? files,
  }) : timestamp = timestamp ?? DateTime.now(), files = files ?? [];
}