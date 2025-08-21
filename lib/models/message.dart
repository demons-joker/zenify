class Message {
  final String text;
  final DateTime timestamp;
  final bool isUser;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}