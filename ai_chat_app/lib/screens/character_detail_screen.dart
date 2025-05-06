import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_sessions_provider.dart';
import '../utils/navigation_utils.dart';
import 'chat_detail_screen.dart';

class CharacterDetailScreen extends StatefulWidget {
  final int index;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isOfficial;

  const CharacterDetailScreen({
    Key? key,
    required this.index,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isOfficial = false,
  }) : super(key: key);

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  // 角色详细信息
  late final Map<String, String> _characterDetails;

  @override
  void initState() {
    super.initState();
    // 初始化角色详细信息
    _characterDetails = {
      '角色类型': widget.isOfficial ? '官方角色' : 'AI角色',
      '擅长领域': _getExpertise(),
      '响应速度': '极快',
      '创建时间': '2023年10月',
      '更新时间': '2024年5月',
      '用户评分': '4.8/5.0',
    };
  }

  String _getExpertise() {
    switch (widget.name) {
      case '智能助手':
        return '日常问答、信息查询、任务协助';
      case '创意伙伴':
        return '创意写作、艺术创作、灵感激发';
      case '学习导师':
        return '学术辅导、知识解析、学习规划';
      case '健康顾问':
        return '健康饮食、运动计划、生活习惯';
      case '娱乐大师':
        return '娱乐推荐、休闲聊天、游戏陪伴';
      case '旅行规划师':
        return '旅行规划、景点推荐、行程安排';
      case '官方客服':
        return '问题解答、使用指导、反馈处理';
      default:
        return '综合能力、多领域知识';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部应用栏
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.name),
              background: Container(
                color: isDarkMode
                    ? widget.color.withOpacity(0.15) // 深色模式下降低透明度
                    : widget.color.withOpacity(0.2),
                child: Center(
                  child: Hero(
                    tag: 'character_${widget.index}',
                    child: Icon(
                      widget.icon,
                      size: 80,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 角色描述
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 角色标签
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.isOfficial
                              ? const Color(0xFF06C755).withOpacity(0.1)
                              : widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.isOfficial ? '官方' : 'AI',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isOfficial ? const Color(0xFF06C755) : widget.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '已认证',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 角色描述
                  Text(
                    '角色描述',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 角色详情
                  Text(
                    '角色详情',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._characterDetails.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}：',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 24),

                  // 角色能力
                  Text(
                    '角色能力',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCapabilityItem('回答准确度', 0.9, isDarkMode),
                  _buildCapabilityItem('响应速度', 0.95, isDarkMode),
                  _buildCapabilityItem('创造力', widget.name == '创意伙伴' ? 0.95 : 0.8, isDarkMode),
                  _buildCapabilityItem('专业知识', widget.name == '学习导师' ? 0.92 : 0.85, isDarkMode),
                  _buildCapabilityItem('情感理解', 0.75, isDarkMode),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              offset: const Offset(0, -1),
              blurRadius: 3,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _startChat(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '开始聊天',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityItem(String name, double value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? widget.color.withOpacity(0.9) : widget.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context) {
    final sessionProvider = Provider.of<ChatSessionsProvider>(context, listen: false);

    // 创建新的聊天会话
    final newSession = sessionProvider.createNewSession(
      widget.name,
      aiModel: widget.isOfficial ? 'official' : 'ai-${widget.index}',
    );

    // 添加AI的第一条消息
    String welcomeMessage = '';
    switch (widget.name) {
      case '智能助手':
        welcomeMessage = '你好！我是你的智能助手，有什么我可以帮助你的吗？';
        break;
      case '创意伙伴':
        welcomeMessage = '嗨！我是你的创意伙伴，让我们一起激发灵感，创造精彩内容吧！';
        break;
      case '学习导师':
        welcomeMessage = '你好！我是你的学习导师，有任何学习上的问题都可以问我哦！';
        break;
      case '健康顾问':
        welcomeMessage = '你好！我是你的健康顾问，我可以帮你制定健康计划，解答健康问题。';
        break;
      case '娱乐大师':
        welcomeMessage = '嘿！我是娱乐大师，想找点乐子吗？我可以推荐电影、音乐、游戏，或者陪你聊天解闷！';
        break;
      case '旅行规划师':
        welcomeMessage = '你好！我是旅行规划师，需要规划下一次旅行吗？我可以帮你推荐目的地、景点和行程！';
        break;
      case '官方客服':
        welcomeMessage = '您好！我是AI聊天助手的官方客服，有任何使用问题或建议都可以告诉我。';
        break;
      default:
        welcomeMessage = '你好！很高兴认识你，有什么我可以帮助你的吗？';
    }

    // 添加AI的欢迎消息
    sessionProvider.addAIMessage(newSession.id, welcomeMessage);

    // 导航到聊天详情页面，使用丝滑过渡效果
    NavigationUtils.navigateWithSlideUp(
      context,
      ChatDetailScreen(sessionId: newSession.id),
    );
  }
}
