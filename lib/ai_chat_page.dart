import 'package:flutter/material.dart';
import 'package:zenify/models/message.dart';
import 'package:zenify/services/ai_stream.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              height: 300,
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
                      .map((msg) => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: ChatBubble(
                              key: ValueKey(msg.text + msg.isUser.toString()),
                              message: msg,
                              isUser: msg.isUser,
                            ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: 调用AI服务获取回复
    _getAIResponse(text);
  }

  String _currentAiResponse = '';

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
        _messages.add(Message(
          text: '',
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
            _currentAiResponse += chunk;
            _messages.last = Message(
              text: _currentAiResponse,
              isUser: false,
            );
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
    return Row(
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
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
            child: Text(
              message.text,
              style: TextStyle(
                  fontSize: 16,
                  color: isUser ? Color(0xFF222222) : Color(0xFF535353)),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        if (isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/ai_logo.png'),
            ),
          ),
      ],
    );
  }
}
