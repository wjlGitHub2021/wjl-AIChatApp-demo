import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/chat_session_model.dart';
import '../providers/chat_sessions_provider.dart';
import '../providers/theme_provider.dart';
import '../animations/smooth_page_transition.dart';
import '../utils/navigation_utils.dart';
import 'chat_detail_screen.dart';
import 'notification_screen.dart';
import 'contacts_screen.dart';

/// 聊天列表页面
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 搜索相关
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  // 选项卡相关
  late TabController _tabController;
  final List<String> _tabs = ['角色聊天', '好友聊天'];

  // 页面控制器
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // 初始化选项卡控制器
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // 触发重建以更新UI
        setState(() {});
      }
    });

    // 初始化页面控制器
    _pageController = PageController(initialPage: 0);

    // 初始化聊天会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatSessionsProvider>(context, listen: false).init();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 移除未使用的方法

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索聊天...',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  autofocus: true,
                )
                : PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                    labelColor: const Color(0xFF06C755),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF06C755),
                    indicatorSize: TabBarIndicatorSize.label,
                    onTap: (index) {
                      setState(() {
                        // 直接更新索引，不使用 PageController
                        _tabController.index = index;
                      });
                    },
                  ),
                ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => NavigationUtils.navigateWithSlideUp(
                context,
                const NotificationScreen(),
              ),
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () => NavigationUtils.navigateWithSlideUp(
                context,
                const ContactsScreen(),
              ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                _tabController.index == 0
                    ? themeProvider.isDarkMode
                        ? [const Color(0xFF1A1A1A), const Color(0xFF0D2818)]
                        : [Colors.white, const Color(0xFFE8F5E9)]
                    : themeProvider.isDarkMode
                    ? [const Color(0xFF1A1A1A), const Color(0xFF0D1F2D)]
                    : [Colors.white, const Color(0xFFE3F2FD)],
          ),
        ),
        child: Consumer<ChatSessionsProvider>(
          builder: (context, sessionProvider, child) {
            if (sessionProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final sessions = sessionProvider.sessions;

            if (sessions.isEmpty) {
              return _buildEmptyState();
            }

            // 过滤会话
            final filteredSessions =
                _searchQuery.isEmpty
                    ? sessions
                    : sessions
                        .where(
                          (session) =>
                              session.title.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              session.lastMessage.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                        )
                        .toList();

            // 分组会话：置顶和非置顶
            final pinnedSessions =
                filteredSessions.where((s) => s.isPinned).toList();
            final unpinnedSessions =
                filteredSessions.where((s) => !s.isPinned).toList();

            // 模拟好友聊天数据
            final friendSessions = [
              ChatSessionModel(
                id: 'friend1',
                title: '张三',
                lastMessage: '好的，明天见！',
                lastMessageTime: DateTime.now().subtract(
                  const Duration(hours: 2),
                ),
                aiModel: '好友',
                isPinned: true,
              ),
              ChatSessionModel(
                id: 'friend2',
                title: '李四',
                lastMessage: '收到了，谢谢！',
                lastMessageTime: DateTime.now().subtract(
                  const Duration(days: 1),
                ),
                aiModel: '好友',
                isPinned: false,
              ),
              ChatSessionModel(
                id: 'friend3',
                title: '王五',
                lastMessage: '下周再联系吧',
                lastMessageTime: DateTime.now().subtract(
                  const Duration(days: 2),
                ),
                aiModel: '好友',
                isPinned: false,
              ),
            ];

            // 分组好友会话
            final pinnedFriendSessions =
                friendSessions.where((s) => s.isPinned).toList();
            final unpinnedFriendSessions =
                friendSessions.where((s) => !s.isPinned).toList();

            // 使用 IndexedStack 代替 PageView，避免滑动过渡
            return IndexedStack(
              index: _tabController.index,
              children: [
                // 角色聊天页面
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView(
                    children: [
                      if (pinnedSessions.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                          child: Text(
                            '置顶聊天',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // 使用顺序动画构建器，实现列表项依次显示的效果
                        SequentialAnimationBuilder(
                          children: pinnedSessions
                              .map((session) => _buildChatItem(context, session))
                              .toList(),
                          staggerDelay: const Duration(milliseconds: 40),
                          itemDuration: const Duration(milliseconds: 500),
                          useScale: true,
                          slideDistance: 15.0,
                        ),
                      ],
                      if (unpinnedSessions.isNotEmpty) ...[
                        if (pinnedSessions.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              top: 16,
                              bottom: 4,
                            ),
                            child: Text(
                              '聊天',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        // 使用顺序动画构建器，实现列表项依次显示的效果
                        SequentialAnimationBuilder(
                          children: unpinnedSessions
                              .map((session) => _buildChatItem(context, session))
                              .toList(),
                          staggerDelay: const Duration(milliseconds: 40),
                          itemDuration: const Duration(milliseconds: 500),
                          useScale: true,
                          slideDistance: 15.0,
                        ),
                      ],
                    ],
                  ),
                ),

                // 好友聊天页面
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView(
                    children: [
                      if (pinnedFriendSessions.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                          child: Text(
                            '置顶好友',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // 使用顺序动画构建器，实现列表项依次显示的效果
                        SequentialAnimationBuilder(
                          children: pinnedFriendSessions
                              .map((session) => _buildChatItem(context, session))
                              .toList(),
                          staggerDelay: const Duration(milliseconds: 40),
                          itemDuration: const Duration(milliseconds: 500),
                          useScale: true,
                          slideDistance: 15.0,
                        ),
                      ],
                      if (unpinnedFriendSessions.isNotEmpty) ...[
                        if (pinnedFriendSessions.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              top: 16,
                              bottom: 4,
                            ),
                            child: Text(
                              '好友',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        // 使用顺序动画构建器，实现列表项依次显示的效果
                        SequentialAnimationBuilder(
                          children: unpinnedFriendSessions
                              .map((session) => _buildChatItem(context, session))
                              .toList(),
                          staggerDelay: const Duration(milliseconds: 40),
                          itemDuration: const Duration(milliseconds: 500),
                          useScale: true,
                          slideDistance: 15.0,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // 移除浮动按钮
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color:
                    _tabController.index == 0
                        ? const Color(0xFF06C755).withAlpha(
                          isDarkMode ? 51 : 25,
                        ) // 0.2*255=51, 0.1*255=25
                        : Colors.blue.withAlpha(isDarkMode ? 51 : 25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color:
                    _tabController.index == 0
                        ? const Color(0xFF06C755)
                        : Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '您还没有进行中的聊天！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _tabController.index == 0
                  ? '请前往角色页面选择一个AI角色开始聊天'
                  : '您可以在通讯录中添加好友开始聊天',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatSessionModel session) {
    // 移除未使用的变量

    // 格式化时间
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      session.lastMessageTime.year,
      session.lastMessageTime.month,
      session.lastMessageTime.day,
    );

    String formattedTime;
    if (messageDate == today) {
      formattedTime = DateFormat('HH:mm').format(session.lastMessageTime);
    } else if (messageDate == yesterday) {
      formattedTime = '昨天';
    } else if (now.difference(messageDate).inDays < 7) {
      formattedTime = DateFormat(
        'EEEE',
        'zh_CN',
      ).format(session.lastMessageTime);
    } else {
      formattedTime = DateFormat('MM/dd').format(session.lastMessageTime);
    }

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.transparent),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // 显示操作菜单
          return await _showActionMenu(context, session);
        }
        return false;
      },
      child: InkWell(
        onTap: () {
          // 使用丝滑过渡效果导航到聊天详情页面
          NavigationUtils.navigateWithSlideUp(
            context,
            ChatDetailScreen(sessionId: session.id),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 头像
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(
                      0xFF06C755,
                    ).withAlpha(25), // 0.1*255=25
                    child: Icon(
                      Icons.smart_toy,
                      color: const Color(0xFF06C755),
                      size: 28,
                    ),
                  ),
                  if (session.isPinned)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF06C755),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.push_pin,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // 聊天信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // AI模型标签
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF06C755,
                            ).withAlpha(25), // 0.1*255=25
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            session.aiModel,
                            style: const TextStyle(
                              color: Color(0xFF06C755),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 最后一条消息
                        Expanded(
                          child: Text(
                            session.lastMessage.isEmpty
                                ? '开始新对话'
                                : session.lastMessage,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showActionMenu(
    BuildContext context,
    ChatSessionModel session,
  ) async {
    final sessionProvider = Provider.of<ChatSessionsProvider>(
      context,
      listen: false,
    );

    final result = await showModalBottomSheet<String>(
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
                leading: Icon(
                  session.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: Colors.blue,
                ),
                title: Text(session.isPinned ? '取消置顶' : '置顶'),
                onTap: () {
                  Navigator.pop(context, 'pin');
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off, color: Colors.orange),
                title: const Text('隐藏'),
                onTap: () {
                  Navigator.pop(context, 'hide');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除'),
                onTap: () {
                  Navigator.pop(context, 'delete');
                },
              ),
            ],
          ),
        );
      },
    );

    if (result == null) {
      return false;
    }

    switch (result) {
      case 'pin':
        await sessionProvider.pinSession(session.id);
        return false;
      case 'hide':
        await sessionProvider.hideSession(session.id);
        return false;
      case 'delete':
        await sessionProvider.deleteSession(session.id);
        return true;
      default:
        return false;
    }
  }

  // 移除未使用的方法
}
