import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const String _thinkingPlaceholder = '思考中...';
  static const String _regeneratingPlaceholder = '重新生成中...';

  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 文件相关
  List<File> _selectedFiles = [];
  bool _showBottomPanel = false;

  // AI头像图片状态
  String _currentAiImage = 'assets/images/figma/avatar_center.png';

  // 语音识别相关
  final SpeechToTextService _speechService = SpeechToTextService();
  bool _isListening = false;
  bool _isVoiceMode = false;
  bool _isSpeechAvailable = true;
  bool _isStartingVoiceInput = false;
  bool _acceptingVoiceInput = false;
  bool _voiceTextCommitted = false;
  String _voiceText = '';

  // 语音播放相关
  bool _isPlayingAudio = false;
  String? _playingMessageId;
  bool _isRegenerating = false;

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
  OverlayEntry? _topMessageEntry;
  Timer? _topMessageTimer;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onInputChanged);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentAiImage = 'assets/images/figma/avatar_center.png';
        });
      }
    });

    _loadChatHistory();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    _textController.removeListener(_onInputChanged);
    _textController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _topMessageTimer?.cancel();
    _topMessageEntry?.remove();
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

  void _showTopMessage(
    String message, {
    Color backgroundColor = const Color(0xFF323232),
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!mounted) return;

    _topMessageTimer?.cancel();
    _topMessageEntry?.remove();

    final overlay = Overlay.of(context);
    _topMessageEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          top: MediaQuery.of(overlayContext).padding.top + 12,
          left: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (actionLabel != null && onAction != null) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size(44, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            _dismissTopMessage();
                            onAction();
                          },
                          child: Text(actionLabel),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_topMessageEntry!);
    _topMessageTimer = Timer(duration, _dismissTopMessage);
  }

  void _dismissTopMessage() {
    _topMessageTimer?.cancel();
    _topMessageTimer = null;
    _topMessageEntry?.remove();
    _topMessageEntry = null;
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
                  if (!isUser && _isPendingPlaceholder(message.text))
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            message.text,
                            style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4A90D9),
                          ),
                        ),
                      ],
                    )
                  else
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
                  if (!isUser && !_isPendingPlaceholder(message.text))
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildVoicePlayButton(message),
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            onPressed: () => _copyMessage(message.text),
                          ),
                          _buildActionButton(
                            icon: _isRegenerating
                                ? Icons.hourglass_top_rounded
                                : Icons.refresh_rounded,
                            enabled: !_isRegenerating,
                            onPressed: () => _regenerateMessage(message),
                          ),
                        ],
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
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.grey.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.grey[600] : Colors.grey[400],
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
    final canSend =
        _textController.text.trim().isNotEmpty || _selectedFiles.isNotEmpty;

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
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        child: _buildSendButton(canSend),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  // 构建圆形按钮
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    Color? iconColor,
    double size = 44,
  }) {
    final enabled = onPressed != null;
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
              color:
                  enabled ? color.withValues(alpha: 0.3) : Colors.transparent,
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

  Widget _buildSendButton(bool canSend) {
    return Tooltip(
      message: '发送',
      child: _buildCircleButton(
        icon: Icons.arrow_upward_rounded,
        onPressed: canSend ? _sendMessage : null,
        color: canSend ? const Color(0xFF4A90D9) : const Color(0xFFE5E7EB),
        iconColor: canSend ? Colors.white : const Color(0xFF9CA3AF),
        size: 38,
      ),
    );
  }

  // 构建语音输入按钮
  Widget _buildVoiceInputButton() {
    // 如果语音不可用，显示禁用状态
    if (!_isSpeechAvailable) {
      return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Tooltip(
          message: '语音不可用',
          child: _buildCircleButton(
            icon: Icons.mic_off_rounded,
            onPressed: null,
            color: const Color(0xFFE5E7EB),
            iconColor: const Color(0xFF9CA3AF),
            size: 38,
          ),
        ),
      );
    }

    final active = _isListening || _isVoiceMode || _isStartingVoiceInput;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Tooltip(
        message: active ? '停止录音' : '语音输入',
        child: GestureDetector(
          onTap: _toggleVoiceInput,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFFE5E5) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    active ? const Color(0xFFE5484D) : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Icon(
              active ? Icons.stop_rounded : Icons.mic_rounded,
              color: active ? const Color(0xFFE5484D) : const Color(0xFF4A5568),
              size: 21,
            ),
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
    _discardActiveVoiceInput(cancelRecognizer: true);

    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFiles.isEmpty) return;

    // 检查是否发送了 "cheers"
    if (text.toLowerCase() == 'cheers') {
      setState(() {
        _currentAiImage = 'assets/images/figma/avatar_center.png';
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _currentAiImage = 'assets/images/figma/avatar_center.png';
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

  Future<void> _getAIResponseWithFiles(String query, List<File> files) async {
    try {
      final messages = _messages
          .where((msg) => !_isPendingPlaceholder(msg.text))
          .map((msg) => {
                'role': msg.isUser ? 'user' : 'assistant',
                'content': msg.text,
              })
          .toList();

      setState(() {
        _currentAiResponse = '';
        _displayText =
            _isRegenerating ? _regeneratingPlaceholder : _thinkingPlaceholder;
        _charIndex = 0;
        _messages.add(Message(
          text: _displayText,
          isUser: false,
        ));
      });

      final client = StreamApiClient();

      List<Map<String, dynamic>> fileDataList = [];
      if (files.isNotEmpty) {
        final fileEntries = await Future.wait(files.map((file) async {
          final fileName = file.path.split('/').last;
          final bytes = await file.readAsBytes();
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
        }));
        fileDataList = fileEntries;
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

      if (mounted && _messages.isNotEmpty) {
        _typingTimer?.cancel();
        setState(() {
          _displayText = _currentAiResponse;
          _messages.last = Message(
            text: _displayText,
            isUser: false,
          );
        });
        await _saveCurrentChat();
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
        await _saveCurrentChat();
      }
    }
  }

  bool _isPendingPlaceholder(String text) {
    return text == _thinkingPlaceholder || text == _regeneratingPlaceholder;
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
      _showTopMessage(
        '会话已删除',
        backgroundColor: const Color(0xFF00FF41).withValues(alpha: 0.8),
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
    if (_isStartingVoiceInput || _isListening) return;

    setState(() {
      _isStartingVoiceInput = true;
    });

    if (!_isSpeechAvailable) {
      final canUseNow = await _speechService.initialize();
      if (!canUseNow) {
        if (mounted) {
          setState(() {
            _isStartingVoiceInput = false;
          });
        }
        if (mounted) {
          final message = await _buildSpeechErrorMessage(
            _speechService.lastError ?? '当前设备不支持语音识别功能',
          );
          _showTopMessage(
            message,
            backgroundColor: Colors.orange.withValues(alpha: 0.92),
            duration: const Duration(seconds: 9),
          );
        }
        return;
      }
      if (mounted) {
        setState(() {
          _isSpeechAvailable = true;
        });
      }
    }

    bool hasPermission = await _speechService.checkPermission();
    if (!hasPermission) {
      bool granted = await _speechService.requestPermission();
      if (!granted) {
        if (mounted) {
          setState(() {
            _isStartingVoiceInput = false;
          });
        }
        if (mounted) {
          _showTopMessage(
            '需要麦克风权限才能使用语音输入。请在系统设置中允许本应用使用麦克风。',
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            actionLabel: '设置',
            onAction: () => _speechService.openSettings(),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isVoiceMode = true;
      _acceptingVoiceInput = true;
      _voiceTextCommitted = false;
      _voiceText = _textController.text;
    });

    final started = await _speechService.startListening(
      localeId: 'zh_CN',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
    if (!started && mounted) {
      setState(() {
        _isListening = false;
        _isVoiceMode = false;
        _isStartingVoiceInput = false;
        _acceptingVoiceInput = false;
        _voiceTextCommitted = true;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isStartingVoiceInput = false;
      });
    }
  }

  // 初始化语音识别
  Future<void> _initializeSpeechRecognition() async {
    _speechService.onResult = (result) {
      if (!mounted || !_acceptingVoiceInput || _voiceTextCommitted) return;
      final cleaned = _cleanInvalidUtf16(result);
      if (cleaned.trim().isEmpty) return;
      setState(() {
        _voiceText = cleaned;
      });
    };

    _speechService.onError = (error) async {
      debugPrint('语音识别错误: $error');
      if (!mounted) return;

      // 关闭语音模式；仅在识别器确实不可用时才标记为不可用
      final lower = error.toLowerCase();
      final permissionError = lower.contains('permission') ||
          lower.contains('error_permission') ||
          lower.contains('权限');
      final recognizerUnavailable = lower.contains('recognizernotavailable') ||
          lower.contains('recognizer_not_available') ||
          lower.contains('语音识别不可用') ||
          lower.contains('not available');

      setState(() {
        _isListening = false;
        _isVoiceMode = false;
        _isStartingVoiceInput = false;
        _acceptingVoiceInput = false;
        _voiceTextCommitted = true;
        _voiceText = '';
        if (recognizerUnavailable) {
          _isSpeechAvailable = false;
        }
      });

      String userMessage = await _buildSpeechErrorMessage(error);
      if (permissionError) {
        userMessage = await _buildSpeechErrorMessage(
          Platform.isAndroid ? 'error_permission' : error,
        );
      } else if (recognizerUnavailable || lower.contains('不可用')) {
        userMessage = await _buildSpeechErrorMessage(error);
      }

      if (!mounted) return;
      _showTopMessage(
        userMessage,
        backgroundColor: Colors.orange.withValues(alpha: 0.92),
        duration: const Duration(seconds: 10),
      );
    };

    _speechService.onListeningStateChanged = (isListening) {
      if (!mounted) return;
      final shouldCommit =
          !isListening && _acceptingVoiceInput && !_voiceTextCommitted;
      setState(() {
        _isListening = isListening;
        _isStartingVoiceInput = false;
        if (!isListening) {
          _isVoiceMode = false;
        }
      });
      if (shouldCommit) {
        _commitVoiceTextToInput();
      }
    };

    // Android 上不要在进入页面时预初始化，否则会过早触发麦克风权限弹窗，
    // 用户拒绝或系统识别服务尚未就绪时会把语音按钮永久置为不可用。
  }

  // 切换语音输入状态
  Future<void> _toggleVoiceInput() async {
    if (_isListening || _isVoiceMode || _isStartingVoiceInput) {
      await _speechService.stopListening();
      setState(() {
        _isListening = false;
        _isVoiceMode = false;
        _isStartingVoiceInput = false;
      });
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _commitVoiceTextToInput();
        }
      });
    } else {
      await _startVoiceInput();
    }
  }

  void _commitVoiceTextToInput() {
    if (!_acceptingVoiceInput || _voiceTextCommitted) return;

    final text = _voiceText.trim();
    _acceptingVoiceInput = false;
    _voiceTextCommitted = true;
    _voiceText = '';

    if (text.isEmpty) return;
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _discardActiveVoiceInput({bool cancelRecognizer = false}) {
    if (!_acceptingVoiceInput &&
        !_isListening &&
        !_isVoiceMode &&
        !_isStartingVoiceInput &&
        _voiceText.isEmpty) {
      return;
    }

    _acceptingVoiceInput = false;
    _voiceTextCommitted = true;
    _voiceText = '';
    _isListening = false;
    _isVoiceMode = false;
    _isStartingVoiceInput = false;

    if (cancelRecognizer) {
      unawaited(_speechService.cancelListening());
    }
  }

  Future<String> _buildSpeechErrorMessage(String error) async {
    final diagnostics = await _speechService.getPermissionDiagnostics();
    final mic = diagnostics['microphone'] ?? 'unknown';
    final speech = diagnostics['speech'] ?? 'unknown';
    final initialized = diagnostics['initialized'] ?? 'false';
    final lastError = diagnostics['lastError'] ?? error;
    final recognizerPermissionError =
        diagnostics['recognizerPermissionError'] == 'true';
    final recognizerServiceError =
        diagnostics['recognizerServiceError'] == 'true';
    final appPermissionsGranted =
        diagnostics['appPermissionsGranted'] == 'true';

    final lower = error.toLowerCase();
    String cause;
    if (Platform.isAndroid && recognizerPermissionError) {
      cause = '系统语音识别服务返回权限不足，不是本应用麦克风权限未开。';
    } else if (Platform.isAndroid && recognizerServiceError) {
      cause = '系统语音识别服务连接异常或不可用。';
    } else if (lower.contains('error_permission') ||
        lower.contains('permission') ||
        lower.contains('权限')) {
      cause = appPermissionsGranted ? '底层识别器权限不足。' : '本应用麦克风权限未开启。';
    } else {
      cause = '语音识别启动失败。';
    }

    final nextStep = Platform.isAndroid
        ? '排查：设置中确认本应用麦克风已允许；再检查 Google App/系统语音识别/语音助手的麦克风权限；确认已安装并启用可用的语音识别服务。'
        : '排查：检查麦克风权限和系统语音识别权限。';

    return '$cause\n'
        '错误码: $error\n'
        'App麦克风: $mic；语音权限: ${speech == 'notRequired' ? '当前平台不需要' : speech}；识别器初始化: $initialized；最近错误: $lastError\n'
        '$nextStep';
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
    Clipboard.setData(ClipboardData(text: text));
    _showTopMessage(
      '已复制到剪贴板',
      backgroundColor: const Color(0xFF00FF41),
    );
  }

  // 重新生成消息
  Future<void> _regenerateMessage(Message message) async {
    if (_isRegenerating) {
      return;
    }

    final targetIndex = _messages.lastIndexOf(message);
    if (targetIndex <= 0) {
      return;
    }

    String? lastUserPrompt;
    for (int i = targetIndex - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        lastUserPrompt = _messages[i].text;
        break;
      }
    }

    if (lastUserPrompt == null || lastUserPrompt.trim().isEmpty) {
      return;
    }

    setState(() {
      _messages.removeAt(targetIndex);
      _isRegenerating = true;
    });

    try {
      await _getAIResponseWithFiles(lastUserPrompt, []);
    } finally {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
        });
      }
    }
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
                leading: const Icon(Icons.privacy_tip_outlined,
                    color: Colors.orange),
                title:
                    const Text('语音权限诊断', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSpeechPermissionDiagnostics();
                },
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

  Future<void> _showSpeechPermissionDiagnostics() async {
    final diagnostics = await _speechService.getPermissionDiagnostics();
    if (!mounted) return;

    final mic = diagnostics['microphone'] ?? 'unknown';
    final speech = diagnostics['speech'] ?? 'unknown';
    final allGranted = diagnostics['allGranted'] == 'true';
    final appPermissionsGranted =
        diagnostics['appPermissionsGranted'] == 'true';
    final recognizerPermissionError =
        diagnostics['recognizerPermissionError'] == 'true';
    final recognizerServiceError =
        diagnostics['recognizerServiceError'] == 'true';
    final platform = diagnostics['platform'] ?? 'unknown';
    final initialized = diagnostics['initialized'] ?? 'false';
    final lastError = diagnostics['lastError'] ?? '';
    final statusText = recognizerPermissionError
        ? '本应用麦克风权限已开启，但系统语音识别服务返回权限不足。请给 Google/系统语音识别服务开启麦克风权限，或更换/启用系统语音识别服务。'
        : recognizerServiceError
            ? '系统语音识别服务连接异常。请确认已安装并启用可用的语音识别服务。'
            : appPermissionsGranted
                ? '状态正常，可直接语音输入'
                : '本应用权限未完整开启，请授权后重试';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('语音权限诊断'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('麦克风权限: $mic'),
              const SizedBox(height: 8),
              Text('语音识别权限: ${speech == 'notRequired' ? '当前平台不需要' : speech}'),
              if (platform == 'android') ...[
                const SizedBox(height: 8),
                const Text('Android 语音服务权限: 由系统语音识别服务单独管理'),
              ],
              const SizedBox(height: 8),
              Text('平台: $platform'),
              const SizedBox(height: 8),
              Text('识别器已初始化: $initialized'),
              if (lastError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('最近错误: $lastError'),
              ],
              const SizedBox(height: 12),
              Text(
                statusText,
                style: TextStyle(
                  color: allGranted ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('关闭'),
            ),
            TextButton(
              onPressed: () async {
                await _speechService.openSettings();
              },
              child: const Text('去设置'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _showSpeechPermissionDiagnostics();
              },
              child: const Text('重新检查'),
            ),
          ],
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
        _showTopMessage(
          '拍照失败: $e',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
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
        _showTopMessage(
          '选择图片失败: $e',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
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
        _showTopMessage(
          '选择文件失败: $e',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
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
