import 'package:flutter/material.dart';
import 'package:zenify/models/message.dart';
import 'package:zenify/services/ai_stream.dart';
import 'package:zenify/services/speech_to_text_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 文件相关
  List<File> _selectedFiles = [];
  bool _showBottomPanel = false;

  // AI头像图片状态
  String _currentAiImage = 'assets/images/aichatwink.gif';

  // 语音识别相关
  final SpeechToTextService _speechService = SpeechToTextService();
  bool _isListening = false;
  bool _isVoiceMode = false;
  bool _isSpeechAvailable = false;
  String _voiceText = '';

  // 语音播放相关
  bool _isPlayingAudio = false;
  String? _playingMessageId;

  // 历史会话相关
  List<Map<String, dynamic>> _chatHistory = [];
  String? _currentChatId;
  String? _currentChatTitle;
  bool _showHistoryPanel = false;
  bool _isLoadingHistory = false;

  // 消息动画
  final Map<String, AnimationController> _messageAnimations = {};
  final Map<String, Animation<Offset>> _messageSlideAnimations = {};
  final Map<String, Animation<double>> _messageFadeAnimations = {};

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentAiImage = 'assets/images/aichatnormal.gif';
        });
      }
    });

    _loadChatHistory();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _typingTimer?.cancel();
    _speechService.dispose();

    // 清理动画控制器
    for (var controller in _messageAnimations.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 主内容区
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildMessageList(),
              ),
              if (!_showHistoryPanel) _buildInputArea(),
            ],
          ),

          // 历史会话面板
          if (_showHistoryPanel) _buildHistoryPanel(),
        ],
      ),
    );
  }

  // 构建顶部导航栏
  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 返回按钮
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),

          const SizedBox(width: 8),

          // 菜单按钮
          _buildIconButton(
            icon: Icons.menu_rounded,
            onPressed: () {
              setState(() {
                _showHistoryPanel = !_showHistoryPanel;
              });
            },
          ),

          // 标题
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '小智',
                  style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_currentChatTitle != null)
                  Text(
                    _currentChatTitle!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // 更多按钮
          _buildIconButton(
            icon: Icons.more_vert_rounded,
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
    );
  }

  // 构建图标按钮
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1A1A2E), size: 22),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  // 构建消息列表
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 20,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message.isUser;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + index * 50),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildMessageBubble(message, isUser),
        );
      },
    );
  }

  // 构建消息气泡
  Widget _buildMessageBubble(Message message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 消息内容
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF4A90D9) // 浅蓝色背景
                    : const Color(0xFFF5F5F5), // 浅灰色背景
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF4A90D9).withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 消息文本
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  // 文件附件
                  if (message.files != null && message.files!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildFileAttachments(message.files!),
                    ),

                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建语音播放按钮
  Widget _buildVoicePlayButton(Message message) {
    final messageId = message.text.hashCode.toString();
    final isPlaying = _playingMessageId == messageId && _isPlayingAudio;

    return GestureDetector(
      onTap: () => _toggleVoicePlayback(message, messageId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90D9).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4A90D9).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: const Color(0xFF4A90D9),
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              isPlaying ? '停止' : '朗读',
              style: const TextStyle(
                color: Color(0xFF4A90D9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.grey[600],
          size: 16,
        ),
      ),
    );
  }

  // 构建文件附件
  Widget _buildFileAttachments(List<File> files) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: files.map((file) {
        final fileName = file.path.split('/').last;
        final extension = fileName.toLowerCase().split('.').last;

        IconData icon;
        Color color;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
          case 'png':
          case 'gif':
            icon = Icons.image_rounded;
            color = const Color(0xFF667EEA);
            break;
          case 'mp3':
          case 'wav':
          case 'ogg':
            icon = Icons.audio_file_rounded;
            color = const Color(0xFFFF6B6B);
            break;
          case 'mp4':
          case 'avi':
          case 'mov':
            icon = Icons.video_file_rounded;
            color = const Color(0xFFFFA726);
            break;
          default:
            icon = Icons.insert_drive_file_rounded;
            color = const Color(0xFF78909C);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                fileName.length > 20
                    ? '${fileName.substring(0, 17)}...'
                    : fileName,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 构建底部输入区域
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 文件预览
          if (_selectedFiles.isNotEmpty) _buildFilePreview(),

          // 底部功能面板
          if (_showBottomPanel) _buildBottomPanel(),

          // 输入框行
          Row(
            children: [
              // 文件上传按钮
              _buildCircleButton(
                icon: Icons.add_rounded,
                onPressed: () {
                  setState(() {
                    _showBottomPanel = !_showBottomPanel;
                  });
                },
                color: const Color(0xFFF5F5F5),
                iconColor: Colors.grey[600],
              ),

              const SizedBox(width: 12),

              // 输入框容器
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 语音按钮
                      _buildVoiceInputButton(),

                      // 输入框
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: _isListening ? '正在聆听...' : '输入消息...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),

                      // 发送按钮
                      if (_textController.text.isNotEmpty ||
                          _selectedFiles.isNotEmpty)
                        _buildCircleButton(
                          icon: Icons.send_rounded,
                          onPressed: _sendMessage,
                          color: const Color(0xFF4A90D9),
                          iconColor: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 语音输入按钮（备用）
              if (!_isListening)
                _buildCircleButton(
                  icon: Icons.mic_rounded,
                  onPressed: _startVoiceInput,
                  color: const Color(0xFF4A90D9),
                  iconColor: Colors.white,
                  size: 48,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建圆形按钮
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    Color? iconColor,
    double size = 44,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  // 构建语音输入按钮
  Widget _buildVoiceInputButton() {
    // 如果语音不可用，显示禁用状态
    if (!_isSpeechAvailable) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.mic_off_rounded,
          color: Colors.grey[300],
          size: 24,
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleVoiceInput,
      onLongPress: _startVoiceInput,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isListening || _isVoiceMode
                ? const Color(0xFF4A90D9).withOpacity(0.2)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isListening
                ? Icons.stop_rounded
                : (_isVoiceMode ? Icons.mic_off_rounded : Icons.mic_rounded),
            color: _isListening || _isVoiceMode
                ? const Color(0xFF4A90D9)
                : Colors.grey[500],
            size: 24,
          ),
        ),
      ),
    );
  }

  // 构建文件预览
  Widget _buildFilePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          final fileName = file.path.split('/').last;

          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Icon(
                    Icons.insert_drive_file_rounded,
                    color: const Color(0xFF4A90D9),
                    size: 32,
                  ),
                ),
                Text(
                  fileName.length > 15
                      ? '${fileName.substring(0, 12)}...'
                      : fileName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建底部功能面板
  Widget _buildBottomPanel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolButton(
                icon: Icons.camera_alt_rounded,
                label: '拍照',
                onTap: () {
                  setState(() => _showBottomPanel = false);
                  _takePhoto();
                },
              ),
              _buildToolButton(
                icon: Icons.photo_library_rounded,
                label: '相册',
                onTap: () {
                  setState(() => _showBottomPanel = false);
                  _selectFromGallery();
                },
              ),
              _buildToolButton(
                icon: Icons.description_rounded,
                label: '文档',
                onTap: () {
                  setState(() => _showBottomPanel = false);
                  _selectDocuments();
                },
              ),
              _buildToolButton(
                icon: Icons.folder_rounded,
                label: '文件',
                onTap: () {
                  setState(() => _showBottomPanel = false);
                  _selectDocuments();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建工具按钮
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A90D9).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4A90D9),
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 构建历史会话面板
  Widget _buildHistoryPanel() {
    return GestureDetector(
      onTap: () {
        setState(() => _showHistoryPanel = false);
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _showHistoryPanel ? 300 : 0,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(5, 0),
                  ),
                ],
              ),
              child: _showHistoryPanel
                  ? Column(
                      children: [
                        // 面板头部
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '历史会话',
                                style: TextStyle(
                                  color: const Color(0xFF1A1A2E),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon:
                                    Icon(Icons.close, color: Colors.grey[600]),
                                onPressed: () {
                                  setState(() => _showHistoryPanel = false);
                                },
                              ),
                            ],
                          ),
                        ),

                        // 新建会话按钮
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: _createNewChat,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4A90D9),
                                    Color(0xFF357ABD),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4A90D9)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    '新建会话',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 会话列表
                        Expanded(
                          child: _isLoadingHistory
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4A90D9),
                                  ),
                                )
                              : _chatHistory.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            color: Colors.grey[300],
                                            size: 48,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '暂无历史会话',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      itemCount: _chatHistory.length,
                                      itemBuilder: (context, index) {
                                        final chat = _chatHistory[index];
                                        final isSelected =
                                            chat['id'] == _currentChatId;

                                        return _buildChatHistoryItem(
                                          chat,
                                          isSelected,
                                        );
                                      },
                                    ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // 构建历史会话项
  Widget _buildChatHistoryItem(Map<String, dynamic> chat, bool isSelected) {
    return GestureDetector(
      onTap: () => _loadChat(chat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90D9).withOpacity(0.1)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90D9).withOpacity(0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.chat_rounded,
              color: isSelected ? const Color(0xFF4A90D9) : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['title'] ?? '新会话',
                    style: TextStyle(
                      color: const Color(0xFF1A1A2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(chat['timestamp']),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[300],
                size: 20,
              ),
              onPressed: () => _deleteChat(chat['id']),
            ),
          ],
        ),
      ),
    );
  }

  // 发送消息
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFiles.isEmpty) return;

    // 检查是否发送了 "cheers"
    if (text.toLowerCase() == 'cheers') {
      setState(() {
        _currentAiImage = 'assets/images/aichatcheers.gif';
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _currentAiImage = 'assets/images/aichatnormal.gif';
          });
        }
      });
    }

    final filesToSend = List<File>.from(_selectedFiles);

    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
        files: filesToSend,
      ));
      _textController.clear();
      _selectedFiles.clear();
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

    _getAIResponseWithFiles(text, filesToSend);
    _saveCurrentChat();
  }

  String _currentAiResponse = '';
  String _displayText = '';
  int _charIndex = 0;
  Timer? _typingTimer;

  void _getAIResponseWithFiles(String query, List<File> files) async {
    try {
      final messages = _messages
          .where((msg) => msg.text != '思考中...')
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();

      setState(() {
        _currentAiResponse = '';
        _displayText = '思考中...';
        _charIndex = 0;
        _messages.add(Message(
          text: '思考中...',
          isUser: false,
        ));
      });

      final client = StreamApiClient();

      List<Map<String, dynamic>> fileDataList = [];
      if (files.isNotEmpty) {
        fileDataList = files.map((file) {
          final fileName = file.path.split('/').last;
          final bytes = file.readAsBytesSync();
          final base64 = base64Encode(bytes);

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
            final cleanedChunk = _cleanInvalidUtf16(chunk);
            _currentAiResponse += cleanedChunk;
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

  // 清理无效的 UTF-16 字符
  String _cleanInvalidUtf16(String input) {
    try {
      input.codeUnits;
      return input;
    } catch (e) {
      final validChars = <int>[];
      final codeUnits = input.codeUnits;

      for (int i = 0; i < codeUnits.length; i++) {
        final code = codeUnits[i];

        if (code >= 0xD800 && code <= 0xDBFF) {
          if (i + 1 < codeUnits.length) {
            final lowSurrogate = codeUnits[i + 1];
            if (lowSurrogate >= 0xDC00 && lowSurrogate <= 0xDFFF) {
              validChars.add(code);
              validChars.add(lowSurrogate);
              i++;
              continue;
            }
          }
          validChars.add(0xFFFD);
        } else if (code >= 0xDC00 && code <= 0xDFFF) {
          validChars.add(0xFFFD);
        } else if (code < 0xD800 || code > 0xDFFF) {
          validChars.add(code);
        }
      }

      return String.fromCharCodes(validChars);
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

  // 格式化时间
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final time = timestamp is int
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final diff = now.difference(time);

      if (diff.inDays > 7) {
        return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}天前';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}小时前';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return '';
    }
  }

  // 加载历史会话列表
  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('chat_history');

      if (historyJson != null) {
        final List<dynamic> historyList = convert.jsonDecode(historyJson);
        setState(() {
          _chatHistory = historyList.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      debugPrint('加载历史会话失败: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  // 保存历史会话列表
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = convert.jsonEncode(_chatHistory);
      await prefs.setString('chat_history', historyJson);
    } catch (e) {
      debugPrint('保存历史会话失败: $e');
    }
  }

  // 创建新会话
  void _createNewChat() {
    if (_messages.isNotEmpty && _currentChatId != null) {
      _saveCurrentChat();
    }

    setState(() {
      _messages.clear();
      _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
      _currentChatTitle = null;
      _showHistoryPanel = false;
    });
  }

  // 加载指定会话
  void _loadChat(Map<String, dynamic> chat) {
    if (_messages.isNotEmpty && _currentChatId != null) {
      _saveCurrentChat();
    }

    setState(() {
      _messages.clear();
      _currentChatId = chat['id'] as String?;
      _currentChatTitle = _cleanInvalidUtf16(chat['title'] as String? ?? '新会话');

      if (chat['messages'] != null) {
        final messagesList = chat['messages'] as List<dynamic>;
        for (var msg in messagesList) {
          _messages.add(Message(
            text: _cleanInvalidUtf16(msg['text'] as String? ?? ''),
            isUser: msg['isUser'] as bool? ?? true,
          ));
        }
      }
    });

    setState(() {
      _showHistoryPanel = false;
    });
  }

  // 删除指定会话
  Future<void> _deleteChat(String chatId) async {
    if (_currentChatId == chatId) {
      setState(() {
        _messages.clear();
        _currentChatId = null;
        _currentChatTitle = null;
      });
    }

    setState(() {
      _chatHistory.removeWhere((chat) => chat['id'] == chatId);
    });

    await _saveChatHistory();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('会话已删除'),
          backgroundColor: const Color(0xFF00FF41).withOpacity(0.8),
        ),
      );
    }
  }

  // 保存当前会话
  Future<void> _saveCurrentChat() async {
    if (_messages.isEmpty) return;

    String title = '新会话';
    if (_messages.isNotEmpty && _messages.first.isUser) {
      final firstMessage = _messages.first.text;
      title = firstMessage.length > 20
          ? '${firstMessage.substring(0, 20)}...'
          : firstMessage;
    }

    final chatData = {
      'id': _currentChatId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _cleanInvalidUtf16(title),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'messages': _messages
          .map((msg) => {
                'text': _cleanInvalidUtf16(msg.text),
                'isUser': msg.isUser,
              })
          .toList(),
    };

    final existingIndex =
        _chatHistory.indexWhere((chat) => chat['id'] == chatData['id']);

    if (existingIndex >= 0) {
      _chatHistory[existingIndex] = chatData;
    } else {
      _chatHistory.insert(0, chatData);
      _currentChatId = chatData['id'] as String?;
      _currentChatTitle = chatData['title'] as String?;
    }

    if (_chatHistory.length > 50) {
      _chatHistory = _chatHistory.sublist(0, 50);
    }

    await _saveChatHistory();
  }

  // 开始语音输入
  Future<void> _startVoiceInput() async {
    bool hasPermission = await _speechService.checkPermission();
    if (!hasPermission) {
      bool granted = await _speechService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('需要麦克风权限才能使用语音输入'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: '设置',
                textColor: Colors.white,
                onPressed: () => _speechService.openSettings(),
              ),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isVoiceMode = true;
      _voiceText = _textController.text;
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
        _voiceText = _cleanInvalidUtf16(result);
      });
    };

    _speechService.onError = (error) {
      debugPrint('语音识别错误: $error');

      // 关闭语音模式并标记不可用
      setState(() {
        _isListening = false;
        _isVoiceMode = false;
        _isSpeechAvailable = false;
      });

      // 根据错误内容给出更友好的提示，常见情况：模拟器/设备不支持或系统识别服务不可用
      final lower = error.toLowerCase();
      String userMessage = '语音识别错误: $error';
      if (lower.contains('recogniz') ||
          lower.contains('不可用') ||
          lower.contains('recognizernotavailable')) {
        userMessage = '设备不支持语音识别或在模拟器上不可用。请在真机上测试并检查系统语音识别服务与权限。';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.orange.withOpacity(0.9),
          ),
        );
      }
    };

    _speechService.onListeningStateChanged = (isListening) {
      setState(() {
        _isListening = isListening;
        if (!isListening) {
          _isVoiceMode = false;
          if (_voiceText.isNotEmpty) {
            _textController.text = _voiceText;
          }
        }
      });
    };

    _isSpeechAvailable = await _speechService.initialize();
    if (!_isSpeechAvailable) {
      debugPrint('当前设备不支持语音识别功能');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('当前设备不支持语音识别功能，可能是在模拟器或未启用系统识别服务。请在真机上测试并检查麦克风/语音识别权限。'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // 切换语音输入状态
  Future<void> _toggleVoiceInput() async {
    // 检查语音识别是否可用
    if (!_isSpeechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('当前设备不支持语音识别功能'),
            backgroundColor: Colors.orange.withOpacity(0.8),
          ),
        );
      }
      return;
    }

    if (_isListening) {
      await _speechService.stopListening();
      setState(() {
        _isListening = false;
        _isVoiceMode = false;
        if (_voiceText.isNotEmpty) {
          _textController.text = _voiceText;
        }
      });
    } else {
      setState(() {
        _isVoiceMode = !_isVoiceMode;
        if (!_isVoiceMode) {
          _voiceText = _textController.text;
        }
      });
    }
  }

  // 切换语音播放
  void _toggleVoicePlayback(Message message, String messageId) {
    setState(() {
      if (_playingMessageId == messageId && _isPlayingAudio) {
        _isPlayingAudio = false;
        _playingMessageId = null;
      } else {
        _isPlayingAudio = true;
        _playingMessageId = messageId;
        // TODO: 实现实际的语音播放功能
        // 这里可以使用 flutter_tts 或其他 TTS 插件
      }
    });
  }

  // 复制消息
  void _copyMessage(String text) {
    // TODO: 实现复制功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        backgroundColor: Color(0xFF00FF41),
      ),
    );
  }

  // 重新生成消息
  void _regenerateMessage(Message message) {
    // TODO: 实现重新生成功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在重新生成...'),
        backgroundColor: Color(0xFF00FF41),
      ),
    );
  }

  // 显示选项菜单
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title:
                    const Text('清空当前会话', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _createNewChat();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 从相册选择
  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            if (_selectedFiles.length < 10) {
              _selectedFiles.add(File(image.path));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 选择文档
  Future<void> _selectDocuments() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? document = await picker.pickMedia();

      if (document != null) {
        setState(() {
          if (_selectedFiles.length < 10) {
            _selectedFiles.add(File(document.path));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择文件失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 清空选中的文件
  void _clearSelectedFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }
}
