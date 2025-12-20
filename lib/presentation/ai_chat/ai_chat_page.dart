import 'package:flutter/material.dart';
import 'package:zenify/models/message.dart';
import 'package:zenify/services/ai_stream.dart';
import 'dart:async';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFBFBFB),
        elevation: 0, // 禁用阴影和滚动效果
        toolbarHeight: kToolbarHeight, // 固定高度
        scrolledUnderElevation: 0, // 禁用滚动时的高亮效果
        surfaceTintColor: Colors.transparent, // 禁用表面色调效果
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Color(0xFFFBFBFB),
        child: Column(
          children: [
            // 顶部GIF动画区域
            SizedBox(
              height: 200,
              child: Center(
                child: Image.asset(
                  'assets/images/zenify_new.gif',
                  fit: BoxFit.contain,
                  height: 300,
                  color: Colors.white,
                  colorBlendMode: BlendMode.dstATop,
                ),
              ),
            ),
            // 问答滚动区域
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: _messages
                      .map((msg) => ChatBubble(
                            key: ValueKey(msg.text + msg.isUser.toString()),
                            message: msg,
                            isUser: msg.isUser,
                          ))
                      .toList(),
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8.0, 8.0, 4.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    _getAIResponse(text);
  }

  String _currentAiResponse = '';
  String _displayText = '';
  int _charIndex = 0;
  Timer? _typingTimer;

  void _getAIResponse(String query) async {
    try {
      // 准备消息列表
      final messages = _messages
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();

      // 初始化流式回复
      setState(() {
        _currentAiResponse = '';
        _displayText = '思考中...';
        _charIndex = 0;
        _messages.add(Message(
          text: '思考中...',
          isUser: false,
        ));
      });

      // 调用流式接口
      final client = StreamApiClient();
      final stream = client.streamPost(
        body: messages,
      );

      await for (final chunk in stream) {
        print('Received chunk: $chunk');
        if (mounted) {
          setState(() {
            // 自动添加换行符（如果chunk以标点结尾）
            _currentAiResponse += '$chunk\n';
          });
          _startTypingEffect();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.last = Message(
            text: '获取AI回复失败，请重试',
            isUser: false,
          );
        });
      }
    }
  }

  void _startTypingEffect() {
    _typingTimer?.cancel();
    _charIndex = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_charIndex < _currentAiResponse.length) {
        setState(() {
          _displayText = _currentAiResponse.substring(0, _charIndex + 1);
          _messages.last = Message(
            text: _displayText,
            isUser: false,
          );
          _charIndex++;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        timer.cancel();
      }
    });
  }
}

class ChatBubble extends StatelessWidget {
  List<InlineSpan> _parseMessageText(String text) {
    // 调试日志（保留原始换行）
    final spans = <InlineSpan>[];
    // 按行处理并保留空行
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.isEmpty) {
        spans.add(TextSpan(text: '\n'));
        continue;
      }

      if (line.startsWith('# ')) {
        spans.add(TextSpan(
          text: '${line.substring(2)}\n',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('## ')) {
        spans.add(TextSpan(
          text: '${line.substring(3)}\n',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('### ')) {
        spans.add(TextSpan(
          text: '${line.substring(4)}\n',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ));
      } else {
        // 处理加粗标记
        final parts = line.split('**');
        for (int i = 0; i < parts.length; i++) {
          if (parts[i].isEmpty) continue;
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              fontSize: 16,
              fontWeight: i.isOdd ? FontWeight.bold : FontWeight.normal,
            ),
          ));
        }
        spans.add(TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  final Message message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/ai_logo.png'),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
              decoration: BoxDecoration(
                gradient: isUser
                    ? null
                    : LinearGradient(
                        colors: [
                          Color(0xFFFFD7FB),
                          Color(0xFFFCF1FF),
                          Color(0xFFC2F6FF)
                        ],
                        stops: [0.0158, 0.4957, 1.0521],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: isUser ? Color(0xFFF2F2F2) : null,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text.rich(
                TextSpan(
                  children: _parseMessageText(message.text),
                  style: TextStyle(
                      color: isUser
                          ? Color(0xFF535353)
                          : Color(0xFF222222)), // 调整行高
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/images/head.png'),
              ),
            ),
        ],
      ),
    );
  }
}
