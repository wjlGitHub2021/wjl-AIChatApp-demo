import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../models/ai_model_info.dart';
import '../providers/chat_sessions_provider.dart';
import '../providers/theme_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String sessionId;

  const ChatDetailScreen({super.key, required this.sessionId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showModelSelector = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatSessionsProvider>(
      builder: (context, sessionProvider, child) {
        final session = sessionProvider.sessions.firstWhere(
          (s) => s.id == widget.sessionId,
          orElse: () => ChatSessionModel(title: '未找到会话'),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(session.title),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsMenu(context, session),
              ),
            ],
          ),
          body: Column(
            children: [
              // AI模型选择器
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showModelSelector ? 160 : 0, // 增加高度到160
                child:
                    _showModelSelector
                        ? SingleChildScrollView(
                          child: _buildModelSelector(context, sessionProvider),
                        )
                        : const SizedBox.shrink(),
              ),
              // 聊天消息列表
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child:
                        session.messages.isEmpty
                            ? _buildEmptyChat(session)
                            : _buildChatMessages(session.messages),
                  ),
                ),
              ),
              // 底部输入框
              _buildInputArea(sessionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyChat(ChatSessionModel session) {
    final modelInfo = AIModelInfo.getModelById(session.aiModel);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF06C755).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 60,
              color: const Color(0xFF06C755),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '开始与${modelInfo.name}对话',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              modelInfo.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _messageController.text = '你好，请介绍一下你自己';
              FocusScope.of(context).requestFocus(_focusNode);
            },
            icon: const Icon(Icons.chat),
            label: const Text('开始对话'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(List<MessageModel> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      reverse: true, // 最新的消息在底部
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(MessageModel message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF06C755).withAlpha(26),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF06C755),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF06C755) : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF06C755),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatSessionsProvider sessionProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF06C755);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final inputBgColor = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // 对齐底部
        children: [
          // 模型选择按钮
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _showModelSelector
                  ? primaryColor.withAlpha(30)
                  : isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _showModelSelector = !_showModelSelector;
                  });
                },
                child: Center(
                  child: Icon(
                    _showModelSelector ? Icons.keyboard_arrow_down : Icons.smart_toy,
                    color: _showModelSelector
                        ? primaryColor
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 输入框
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                maxHeight: 120, // 限制最大高度
              ),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  height: 1.3,
                ),
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                maxLines: null, // 允许多行
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onChanged: (text) {
                  // 当输入内容变化时，触发重建以更新发送按钮状态
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 发送按钮
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _messageController.text.trim().isNotEmpty
                  ? primaryColor
                  : isDarkMode ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              boxShadow: _messageController.text.trim().isNotEmpty
                  ? [
                      BoxShadow(
                        color: primaryColor.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _messageController.text.trim().isNotEmpty
                    ? () => _sendMessage(sessionProvider)
                    : null,
                child: Center(
                  child: Icon(
                    Icons.send_rounded,
                    color: _messageController.text.trim().isNotEmpty
                        ? Colors.white
                        : isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector(
    BuildContext context,
    ChatSessionsProvider sessionProvider,
  ) {
    final currentModel = sessionProvider.currentAIModel;
    final models = AIModelInfo.predefinedModels;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2), // 进一步减少垂直内边距
      // 添加约束，确保容器有足够的高度
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 使用 withAlpha 代替 withOpacity
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true, // 确保列表只占用所需的最小空间
        physics: const NeverScrollableScrollPhysics(), // 禁用滚动
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '选择AI模型',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '免费模型',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 70, // 进一步减少高度
            constraints: const BoxConstraints(minHeight: 70),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                final isSelected = model.id == currentModel;

                // 根据模型ID选择不同的图标
                IconData modelIcon;
                switch (model.id) {
                  case 'gemini':
                    modelIcon = Icons.diamond;
                    break;
                  case 'deepseek':
                    modelIcon = Icons.psychology;
                    break;
                  case 'shisa':
                    modelIcon = Icons.smart_toy;
                    break;
                  default:
                    modelIcon = Icons.smart_toy;
                }

                return GestureDetector(
                  onTap: () {
                    // 直接设置模型，不处理返回值
                    sessionProvider.setCurrentAIModel(model.id);
                  },
                  child: Container(
                    width: 80,
                    height: 60, // 进一步减少高度
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1, // 进一步减小垂直边距
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF06C755).withAlpha(
                                26,
                              ) // 使用 withAlpha 代替 withOpacity
                              : isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF06C755)
                                : isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // 确保列只占用所需的最小空间
                      children: [
                        Icon(
                          modelIcon,
                          color:
                              isSelected
                                  ? const Color(0xFF06C755)
                                  : isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          model.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? const Color(0xFF06C755)
                                    : isDarkMode
                                    ? Colors.white
                                    : Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < model.averageRating.floor()
                                  ? Icons.star
                                  : i < model.averageRating
                                  ? Icons.star_half
                                  : Icons.star_border,
                              size: 6, // 进一步减小星星大小
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatSessionsProvider sessionProvider) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 先设置当前会话，再发送消息
    sessionProvider.setCurrentSession(widget.sessionId);
    sessionProvider.sendMessage(text);
    _messageController.clear();
  }

  void _showOptionsMenu(BuildContext context, ChatSessionModel session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('查看模型详情'),
                onTap: () {
                  Navigator.pop(context);
                  _showModelDetails(context, session.aiModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('清空聊天记录'),
                onTap: () {
                  Navigator.pop(context);
                  _showClearChatDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModelDetails(BuildContext context, String modelId) {
    final model = AIModelInfo.getModelById(modelId);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(model.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.description),
                const SizedBox(height: 16),
                const Text(
                  '能力评分:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...model.ratings.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text('${entry.key}: '),
                        const Spacer(),
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < entry.value.floor()
                                ? Icons.star
                                : i < entry.value
                                ? Icons.star_half
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('每次回复消耗: '),
                    const Spacer(),
                    Text(
                      '${model.costPerMessage} 点',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF06C755),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('清空聊天记录'),
            content: const Text('确定要清空此会话的所有聊天记录吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  // 清空聊天记录的逻辑
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }
}
