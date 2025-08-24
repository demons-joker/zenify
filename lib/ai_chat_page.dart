import 'package:flutter/material.dart';
import 'package:zenify/models/message.dart';
import 'package:zenify/services/api.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage>
    with SingleTickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latestAiMessage = _messages.lastWhere((msg) => !msg.isUser,
        orElse: () => Message(text: '', isUser: false));
    final latestUserMessage = _messages.lastWhere((msg) => msg.isUser,
        orElse: () => Message(text: '', isUser: true));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // AI回复区域
            Expanded(
              flex: 3,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    ),
                  );
                },
                switchOutCurve: Curves.easeInOut,
                switchInCurve: Curves.easeInOut,
                child: latestAiMessage.text.isEmpty
                    ? Container(key: const ValueKey('empty-ai'))
                    : ChatBubble(
                        key: ValueKey(latestAiMessage.text),
                        message: latestAiMessage,
                        isUser: false,
                      ),
              ),
            ),
            // 动画表情
            Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  height: 400,
                  width: 400,
                  child: Center(
                    child: Image.asset(
                      'assets/images/zenify.gif',
                      fit: BoxFit.contain,
                      height: 400,
                    ),
                  ),
                ),
              ),
            ),
            // 用户问题区域
            Expanded(
              flex: 2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    ),
                  );
                },
                switchOutCurve: Curves.easeInOut,
                switchInCurve: Curves.easeInOut,
                child: latestUserMessage.text.isEmpty
                    ? Container(key: const ValueKey('empty-user'))
                    : ChatBubble(
                        key: ValueKey(latestUserMessage.text),
                        message: latestUserMessage,
                        isUser: true,
                      ),
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
      ));
      _textController.clear();
    });

    // TODO: 调用AI服务获取回复
    _getAIResponse(text);
  }

  void _getAIResponse(String query) async {
    try {
      // 准备消息列表
      final messages = _messages
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();

      // 调用AI接口
      final response = await Api.chartToAi(
        messages,
      );
      print('_getAIResponse: $response');

      if (mounted) {
        setState(() {
          _messages.add(Message(
            text: response['message'] ?? 'AI回复解析失败',
            isUser: false,
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(Message(
            text: '获取AI回复失败，请重试',
            isUser: false,
          ));
        });
      }
    }
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        child: Text(
          message.text,
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
