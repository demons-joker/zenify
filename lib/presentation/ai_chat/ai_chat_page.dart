import 'package:flutter/material.dart';
import 'package:zenify/models/message.dart';
import 'package:zenify/services/ai_stream.dart';
import 'package:zenify/services/speech_to_text_service.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  late MatrixRainPainter _matrixRainPainter;

  // 语音识别相关
  final SpeechToTextService _speechService = SpeechToTextService();
  bool _isListening = false;
  bool _isVoiceMode = false; // 是否在语音输入模式
  String _voiceText = ''; // 语音识别的临时文本

  // 文件相关
  List<File> _selectedFiles = []; // 选中的文件列表
  bool _showBottomPanel = false; // 是否显示底部功能面板

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _matrixRainPainter = MatrixRainPainter(_animationController); // 创建一次数码雨画笔
    _animationController.repeat(); // 启动动画让数码雨持续重绘

    // 初始化语音识别
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 黑客帝国风格背景层
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.95),
                  Colors.green.withOpacity(0.02),
                  Colors.black,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          // 数码雨效果层
          Positioned.fill(
            child: CustomPaint(
              painter: _matrixRainPainter,
            ),
          ),
          // 网格覆盖层
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Color(0xFF00FF41).withOpacity(0.02),
                  Color(0xFF00CC33).withOpacity(0.02),
                  Colors.transparent,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          // 扫描线动画层
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, -0.5),
                  end: Alignment(0.0, 1.5),
                  colors: [
                    Colors.transparent,
                    Color(0xFF00FF41).withOpacity(0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 内容层
          Column(
            children: [
              // 自定义AppBar with 赛博朋克风格
              SafeArea(
                child: Container(
                  height: kToolbarHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF00FF41).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFF00FF41)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF00FF41).withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 问答滚动区域
              Expanded(
                child: Stack(
                  children: [
                    // 脉搏信号背景动画
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0.0, -0.3),
                            radius: 1.2,
                            colors: [
                              Colors.transparent,
                              Colors.cyan.withOpacity(0.02),
                              Colors.purple.withOpacity(0.02),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // 左侧数据流装饰
                    Positioned(
                      left: 0,
                      top: 100,
                      bottom: 100,
                      width: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xFF00FF41).withOpacity(0.6),
                              Color(0xFF00CC33).withOpacity(0.4),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // 右侧数据流装饰
                    Positioned(
                      right: 0,
                      top: 100,
                      bottom: 100,
                      width: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xFF00CC33).withOpacity(0.4),
                              Color(0xFF00FF41).withOpacity(0.6),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // 聊天内容滚动区域
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 220, bottom: 120),
                      child: Column(
                        children: _messages.asMap().entries.map((entry) {
                          final messageIndex = entry.key;
                          return ChatBubble(
                            key: ValueKey(entry.value.text +
                                entry.value.isUser.toString()),
                            message: entry.value,
                            isUser: entry.value.isUser,
                            messageIndex: messageIndex, // 传递索引
                          );
                        }).toList(),
                      ),
                    ),
                    // 悬浮的圆形AI logo with 赛博朋克效果
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Stack(
                          children: [
                            // 外圈光环
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF00FF41).withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00FF41).withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            // 中圈光环
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF00CC33).withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00CC33).withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            // 中心图片
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00FF41).withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/aichatlogo.png',
                                  fit: BoxFit.cover,
                                  width: 130,
                                  height: 130,
                                ),
                              ),
                            ),
                            // 数据流点缀
                            Positioned(
                              top: -5,
                              left: -5,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00FF41),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00FF41).withOpacity(0.8),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -5,
                              right: -5,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00CC33),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00CC33).withOpacity(0.8),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 输入框和底部面板定位到屏幕底部
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 文件预览区域
                if (_selectedFiles.isNotEmpty) _buildFilePreview(),
                if (_showBottomPanel) _buildBottomPanel(),
                _buildInputField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: Color(0xFF00FF41).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 主输入框 with 赛博朋克风格
            Expanded(
              child: Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(17, 11, 16, 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFF00FF41).withOpacity(0.5),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF00FF41).withOpacity(0.1),
                      Color(0xFF00CC33).withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00FF41).withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 左侧：语音输入图标（替代键盘图标位置）
                    GestureDetector(
                      onTap: () => _toggleVoiceInput(),
                      onLongPress: () => _startVoiceInput(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? Color(0xFF00FF41).withOpacity(0.3)
                              : (_isVoiceMode
                                  ? Color(0xFF00FF41).withOpacity(0.3)
                                  : Color(0xFF00CC33).withOpacity(0.2)),
                          border: Border.all(
                            color: _isListening
                                ? Color(0xFF00FF41).withOpacity(0.8)
                                : (_isVoiceMode
                                    ? Color(0xFF00FF41).withOpacity(0.8)
                                    : Color(0xFF00CC33).withOpacity(0.5)),
                            width: 1,
                          ),
                          // 语音录制时的脉冲效果
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: Color(0xFF00FF41).withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening
                              ? Icons.stop
                              : (_isVoiceMode ? Icons.mic_off : Icons.mic),
                          color: _isListening
                              ? Color(0xFF00FF41)
                              : (_isVoiceMode
                                  ? Color(0xFF00FF41)
                                  : Color(0xFF00CC33)),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 输入框
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter command...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          isDense: true,
                          hintStyle: TextStyle(
                            color: Color(0xFF00FF41),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.top,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 发送按钮（Android显示，iOS隐藏）
            if (Theme.of(context).platform == TargetPlatform.android)
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00FF41).withOpacity(0.3),
                        Color(0xFF00CC33).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Color(0xFF00FF41).withOpacity(0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00FF41).withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.send,
                    color: Color(0xFF00FF41),
                    size: 24,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // 清空文件按钮（有选择文件时显示）
            if (_selectedFiles.isNotEmpty)
              GestureDetector(
                onTap: _clearSelectedFiles,
                child: Container(
                  width: 40,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withOpacity(0.5),
                      width: 1,
                    ),
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.clear,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // +号按钮 with 赛博朋克边框
            GestureDetector(
              onTap: () {
                setState(() {
                  _showBottomPanel = !_showBottomPanel;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF00FF41).withOpacity(0.5),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF00FF41).withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00FF41).withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _showBottomPanel ? Icons.close : Icons.add,
                        color: Color(0xFF00FF41),
                        size: 24,
                      ),
                    ),
                    // 文件数量角标
                    if (_selectedFiles.isNotEmpty)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00FF41),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00FF41).withOpacity(0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _selectedFiles.length > 9 ? '9+' : '${_selectedFiles.length}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'PressStart2P',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建底部功能面板
  Widget _buildBottomPanel() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF00FF41).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 15,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Color(0xFF00FF41).withOpacity(0.2),
              blurRadius: 25,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 第一行：图片相关
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 拍照选项
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showBottomPanel = false;
                      });
                      _takePhoto();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF00FF41).withOpacity(0.5),
                              width: 1,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF00FF41).withOpacity(0.1),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Color(0xFF00FF41),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '拍照',
                          style: TextStyle(
                            color: Color(0xFF00FF41),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 相册选项
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showBottomPanel = false;
                      });
                      _selectFromGallery();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF00FF41).withOpacity(0.5),
                              width: 1,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF00FF41).withOpacity(0.1),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Color(0xFF00FF41),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '相册',
                          style: TextStyle(
                            color: Color(0xFF00FF41),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 文档选项
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showBottomPanel = false;
                      });
                      _selectDocuments();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF00FF41).withOpacity(0.5),
                              width: 1,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF00FF41).withOpacity(0.1),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.description,
                            color: Color(0xFF00FF41),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '文档',
                          style: TextStyle(
                            color: Color(0xFF00FF41),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 第二行：提示信息
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF00FF41).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF00FF41).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '支持图片、音频、视频、文档等多种文件类型（单个文件最大10MB）',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF00FF41).withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFiles.isEmpty) return;

    // 保存文件列表的副本，在清空之前使用
    final filesToSend = List<File>.from(_selectedFiles);
    
    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
        files: filesToSend, // 使用保存的文件列表副本
      ));
      _textController.clear();
      _selectedFiles.clear(); // 清空原始文件列表
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

    _getAIResponseWithFiles(text, filesToSend); // 使用保存的文件列表
  }

  String _currentAiResponse = '';
  String _displayText = '';
  int _charIndex = 0;
  Timer? _typingTimer;

  void _getAIResponseWithFiles(String query, List<File> files) async {
    try {
      // 准备消息列表（排除当前正在思考的消息）
      final messages = _messages
          .where((msg) => msg.text != '思考中...')
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

      // 调用新的带文件流式接口
      final client = StreamApiClient();

      // 如果有文件，构建文件数据
      List<Map<String, dynamic>> fileDataList = [];
      if (files.isNotEmpty) {
        fileDataList = files.map((file) {
          final fileName = file.path.split('/').last;
          final bytes = file.readAsBytesSync();
          final base64 = base64Encode(bytes);
          
          // 根据文件扩展名确定类型和MIME
          String fileType = 'file';
          String mimeType = 'application/octet-stream';
          final extension = fileName.toLowerCase().split('.').last;
          
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              fileType = 'image';
              mimeType = 'image/jpeg';
              break;
            case 'png':
              fileType = 'image';
              mimeType = 'image/png';
              break;
            case 'gif':
              fileType = 'image';
              mimeType = 'image/gif';
              break;
            case 'pdf':
              fileType = 'document';
              mimeType = 'application/pdf';
              break;
            case 'doc':
            case 'docx':
              fileType = 'document';
              mimeType = 'application/msword';
              break;
            case 'txt':
              fileType = 'document';
              mimeType = 'text/plain';
              break;
            case 'mp3':
            case 'wav':
            case 'ogg':
              fileType = 'audio';
              mimeType = 'audio/mpeg';
              break;
            case 'mp4':
            case 'avi':
            case 'mov':
              fileType = 'video';
              mimeType = 'video/mp4';
              break;
          }
          
          return {
            'name': fileName,
            'size': bytes.length,
            'type': fileType,
            'mime_type': mimeType,
            'data': 'data:$mimeType;base64,$base64',
          };
        }).toList();
      }

      print('Making request with ${fileDataList.length} files');
      
      final stream = client.streamPostWithFiles(
        messages: messages,
        fileDataList: fileDataList,
      );

      await for (final chunk in stream) {
        print('Received chunk: $chunk');
        if (mounted) {
          setState(() {
            // 累积响应内容，不自动添加换行符
            _currentAiResponse += chunk;
          });
          _startTypingEffect();
        }
      }
    } catch (e) {
      print('AI response error: $e');
      if (mounted && _messages.isNotEmpty) {
        setState(() {
          _messages.last = Message(
            text: '获取AI回复失败，请重试：$e',
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

  // 开始语音输入（长按触发）
  Future<void> _startVoiceInput() async {
    bool hasPermission = await _speechService.checkPermission();
    if (!hasPermission) {
      bool granted = await _speechService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('需要麦克风权限才能使用语音输入'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isVoiceMode = true;
      _voiceText = _textController.text; // 保存当前输入框内容
    });

    _speechService.startListening(
      localeId: 'zh_CN',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  // 初始化语音识别
  Future<void> _initializeSpeechRecognition() async {
    _speechService.onResult = (result) {
      setState(() {
        _voiceText = result;
      });
    };

    _speechService.onError = (error) {
      setState(() {
        _isListening = false;
        _isVoiceMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('语音识别错误: $error'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    };

    _speechService.onListeningStateChanged = (isListening) {
      setState(() {
        _isListening = isListening;
        if (!isListening) {
          _isVoiceMode = false;
          // 将语音结果设置到输入框
          if (_voiceText.isNotEmpty) {
            _textController.text = _voiceText;
          }
        }
      });
    };

    await _speechService.initialize();
  }

  // 切换语音输入状态（点击切换）
  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      // 停止录音
      await _speechService.stopListening();
      setState(() {
        _isListening = false;
        _isVoiceMode = false;
        // 将语音结果设置到输入框
        if (_voiceText.isNotEmpty) {
          _textController.text = _voiceText;
        }
      });
    } else {
      // 切换到语音模式但不开始录音
      setState(() {
        _isVoiceMode = !_isVoiceMode;
        if (!_isVoiceMode) {
          _voiceText = _textController.text; // 保存当前文本
        }
      });
    }
  }

  // 拍照
  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedFiles.add(File(photo.path));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已拍摄照片'),
              backgroundColor: Colors.green.withOpacity(0.8),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('拍照失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    }
  }

  // 从相册选择
  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage();

      if (images != null) {
        final List<File> files =
            images.map((xFile) => File(xFile.path)).toList();
        setState(() {
          _selectedFiles.addAll(files);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已选择 ${files.length} 张图片'),
              backgroundColor: Colors.green.withOpacity(0.8),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('选择图片失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    }
  }

  // 选择文档
  Future<void> _selectDocuments() async {
    try {
      // 由于Flutter没有内置的文档选择器，这里提供基础实现
      // 在实际项目中，你可能需要使用file_picker等包
      final ImagePicker picker = ImagePicker();
      final XFile? videoFile = await picker.pickVideo(source: ImageSource.gallery);

      if (videoFile != null) {
        final File file = File(videoFile.path);
        
        // 检查文件大小（10MB限制）
        final fileSize = await file.length();
        const maxSize = 10 * 1024 * 1024; // 10MB
        
        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('文件大小超过10MB限制，请选择较小的文件'),
                backgroundColor: Colors.red.withOpacity(0.8),
              ),
            );
          }
          return;
        }
        
        setState(() {
          _selectedFiles.add(file);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已选择视频文件：${file.path.split('/').last}'),
              backgroundColor: Colors.green.withOpacity(0.8),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('选择文档失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择文档失败: $e'),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    }
  }

  // 构建文件预览区域
  Widget _buildFilePreview() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFF00FF41).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已选择文件 (${_selectedFiles.length})',
                style: TextStyle(
                  color: Color(0xFF00FF41),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: _clearSelectedFiles,
                child: Icon(
                  Icons.close,
                  color: Colors.red.withOpacity(0.8),
                  size: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // 文件列表
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedFiles.map((file) {
              final fileName = file.path.split('/').last;
              final isImage = fileName.toLowerCase().endsWith('.jpg') || 
                           fileName.toLowerCase().endsWith('.jpeg') || 
                           fileName.toLowerCase().endsWith('.png');
              
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF00FF41).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color(0xFF00FF41).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImage ? Icons.image : Icons.description,
                      color: Color(0xFF00FF41),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      fileName.length > 15 ? '${fileName.substring(0, 12)}...' : fileName,
                      style: TextStyle(
                        color: Color(0xFF00FF41),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 清空选中的文件
  void _clearSelectedFiles() {
    setState(() {
      _selectedFiles.clear();
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
  final int messageIndex; // 添加索引参数

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.messageIndex, // 添加索引参数
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
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF00FF41).withOpacity(0.8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00FF41).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                    // 脉搏光环效果
                    BoxShadow(
                      color: Color(0xFF00FF41).withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage('assets/images/ai_logo.png'),
                    ),
                    // 状态指示灯
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00FF41),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00FF41).withOpacity(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 8),
              decoration: BoxDecoration(
                // 赛博朋克风格渐变背景
                gradient: isUser
                    ? LinearGradient(
                        colors: [
                          Color(0xFF00D4FF).withOpacity(0.12),
                          Color(0xFF0099CC).withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Color(0xFF00FF41).withOpacity(0.06),
                          Color(0xFF00CC33).withOpacity(0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                // 多层边框效果
                border: Border.all(
                  color: isUser
                      ? Color(0xFF00D4FF).withOpacity(0.3)
                      : Color(0xFF00FF41).withOpacity(0.3),
                  width: 1,
                ),
                // 内发光效果
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? Color(0xFF00D4FF).withOpacity(0.15)
                        : Color(0xFF00FF41).withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                  // 外层光晕
                  BoxShadow(
                    color: isUser
                        ? Color(0xFF00D4FF).withOpacity(0.08)
                        : Color(0xFF00FF41).withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: Offset(0, 0),
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Stack(
                children: [
                  // 扫描线动画效果
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isUser
                                  ? Color(0xFF00D4FF).withOpacity(0.05)
                                  : Color(0xFF00FF41).withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 顶部装饰线条
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUser
                              ? [
                                  Color(0xFF00D4FF).withOpacity(0.5),
                                  Colors.transparent
                                ]
                              : [
                                  Color(0xFF00FF41).withOpacity(0.5),
                                  Colors.transparent
                                ],
                        ),
                      ),
                    ),
                  ),
                  // 左侧脉搏指示器
                  Positioned(
                    top: 8,
                    left: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUser
                            ? Color(0xFF00D4FF).withOpacity(0.7)
                            : Color(0xFF00FF41).withOpacity(0.7),
                        boxShadow: [
                          BoxShadow(
                            color: isUser
                                ? Color(0xFF00D4FF).withOpacity(0.5)
                                : Color(0xFF00FF41).withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 右侧角标
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Transform.rotate(
                      angle: 0.785398, // 45度
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isUser
                                ? Color(0xFF00D4FF).withOpacity(0.3)
                                : Color(0xFF00FF41).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 底部数据流动效果
                  Positioned(
                    bottom: 0,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            isUser
                                ? Color(0xFF00D4FF).withOpacity(0.2)
                                : Color(0xFF00FF41).withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 文字内容
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8, left: 8, right: 8, bottom: 4),
                    child: Text.rich(
                      TextSpan(
                        children: _parseMessageText(message.text),
                        style: TextStyle(
                          color: isUser
                              ? Color(0xFFE0FFFF)
                              : Color(0xFF00FF41)
                                  .withOpacity(0.6 + (messageIndex % 10) / 40),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: isUser
                                  ? Color(0xFF00D4FF).withOpacity(0.3)
                                  : Color(0xFF00FF41).withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF00D4FF).withOpacity(0.8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00D4FF).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                    // 脉搏光环效果
                    BoxShadow(
                      color: Color(0xFF00D4FF).withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage('assets/images/head.png'),
                    ),
                    // 状态指示灯
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00D4FF),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00D4FF).withOpacity(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 黑客帝国数码雨效果
class MatrixRainPainter extends CustomPainter {
  static final List<String> matrixChars = [
    '0',
    '1',
    'ア',
    'イ',
    'ウ',
    'エ',
    'オ',
    'カ',
    'キ',
    'ク',
    'ケ',
    'コ',
    'サ',
    'シ',
    'ス',
    'セ',
    'ソ',
    'タ',
    'チ',
    'ツ',
    'テ',
    'ト',
    'ナ',
    'ニ',
    'ヌ',
    'ネ',
    'ノ',
    'ハ',
    'ヒ',
    'フ',
    'ヘ',
    'ホ',
    'マ',
    'ミ',
    'ム',
    'メ',
    'モ',
    'ヤ',
    'ユ',
    'ヨ',
    'ラ',
    'リ',
    'ル',
    'レ',
    'ロ',
    'ワ',
    'ヲ',
    'ン'
  ];

  final List<MatrixColumn> columns = [];
  final Random random = Random();
  final AnimationController animationController;

  MatrixRainPainter(this.animationController)
      : super(repaint: animationController) {
    // 初始化数码雨列
    for (int i = 0; i < 30; i++) {
      columns.add(MatrixColumn(random));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final column in columns) {
      column.update();
      column.draw(canvas, size, paint, matrixChars, random);
    }
  }

  @override
  bool shouldRepaint(covariant MatrixRainPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}

class MatrixColumn {
  late double x;
  late double y;
  late double speed;
  late List<String> chars;
  final Random random;
  Size? canvasSize;

  MatrixColumn(this.random) {
    reset();
  }

  void reset() {
    x = random.nextDouble() * 400;
    y = -random.nextDouble() * 500;
    speed = 2 + random.nextDouble() * 3;
    chars = List.generate(8 + random.nextInt(8), (index) {
      return MatrixRainPainter
          .matrixChars[random.nextInt(MatrixRainPainter.matrixChars.length)];
    });
  }

  void update() {
    y += speed;
    if (canvasSize != null && y > canvasSize!.height + 100) {
      reset();
    }

    // 随机改变字符
    if (random.nextDouble() < 0.05) {
      final index = random.nextInt(chars.length);
      chars[index] = MatrixRainPainter
          .matrixChars[random.nextInt(MatrixRainPainter.matrixChars.length)];
    }
  }

  void draw(Canvas canvas, Size size, Paint paint, List<String> matrixChars,
      Random random) {
    canvasSize = size;
    for (int i = 0; i < chars.length; i++) {
      final charY = y - i * 15;

      if (charY < -20 || charY > size.height) continue;

      // 渐变透明度效果
      double opacity = 1.0 - (i / chars.length);
      if (i == chars.length - 1) {
        // 最前面的字符最亮
        opacity = 1.0;
        paint.color = Color(0xFF00FF41);
      } else if (i == chars.length - 2) {
        opacity = 0.8;
        paint.color = Color(0xFF00FF41).withOpacity(opacity);
      } else {
        // 后面的字符逐渐变暗
        paint.color = Color(0xFF00CC33).withOpacity(opacity * 0.3);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: chars[i],
          style: TextStyle(
            color: paint.color,
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x, charY));
    }
  }
}
