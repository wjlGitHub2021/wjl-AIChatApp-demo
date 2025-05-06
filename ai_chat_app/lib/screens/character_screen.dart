import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../animations/smooth_page_transition.dart';
import '../utils/navigation_utils.dart';
import '../utils/page_transitions.dart';
import 'character_detail_screen.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 选项卡相关
  late TabController _tabController;
  final List<String> _tabs = ['AI角色', '官方角色'];

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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();

    // 初始化选项卡控制器
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    // 初始化页面控制器
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 背景颜色渐变控制
  Color _getBackgroundColor() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // 根据当前选项卡和主题模式返回不同的背景色
    if (_tabController.index == 0) {
      return isDarkMode
          ? const Color(0xFF0A1F0A) // 深色模式下的深绿色
          : const Color(0xFFF0FFF0); // 淡绿色
    } else {
      return isDarkMode
          ? const Color(0xFF0A192F) // 深色模式下的深蓝色
          : const Color(0xFFF0F8FF); // 天蓝色
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        title: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            labelColor: const Color(0xFF06C755),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF06C755),
            indicatorSize: TabBarIndicatorSize.label,
            onTap: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: _getBackgroundColor(),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            _tabController.animateTo(index);
            // 触发背景色更新
            setState(() {});
          },
          children: [
            // AI角色页面
            FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                itemBuilder: (context, index) {
                  // 直接返回列表项，不使用逐个动画效果
                  return _buildCharacterListItem(index, false);
                },
              ),
            ),

            // 官方角色页面
            FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  // 直接返回列表项，不使用逐个动画效果
                  return _buildCharacterListItem(index, true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 角色数据
  final List<String> _aiCharacterNames = [
    '智能助手',
    '创意伙伴',
    '学习导师',
    '健康顾问',
    '娱乐大师',
    '旅行规划师',
  ];

  final List<String> _officialCharacterNames = [
    '官方客服',
    '新闻助手',
    '翻译专家',
  ];

  final List<String> _aiDescriptions = [
    '解答问题，提供信息，帮助你完成各种任务',
    '激发灵感，帮助创作，提供创意建议',
    '辅导学习，解答难题，提供学习资源',
    '健康饮食建议，运动计划，生活习惯改善',
    '推荐电影、音乐、游戏，陪你聊天解闷',
    '规划旅行路线，推荐景点，提供旅行建议',
  ];

  final List<String> _officialDescriptions = [
    '解答使用问题，处理反馈，提供帮助',
    '提供最新新闻，分析热点事件，总结新闻要点',
    '提供多语言翻译，语法校对，文化解释',
  ];

  final List<IconData> _aiIcons = [
    Icons.smart_toy,
    Icons.lightbulb,
    Icons.school,
    Icons.favorite,
    Icons.sports_esports,
    Icons.flight,
  ];

  final List<IconData> _officialIcons = [
    Icons.support_agent,
    Icons.newspaper,
    Icons.translate,
  ];

  final List<Color> _aiColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  final List<Color> _officialColors = [
    const Color(0xFF06C755),
    Colors.indigo,
    Colors.amber,
  ];

  Widget _buildCharacterListItem(int index, bool isOfficial) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final name = isOfficial
        ? _officialCharacterNames[index]
        : _aiCharacterNames[index];
    final description = isOfficial
        ? _officialDescriptions[index]
        : _aiDescriptions[index];
    final icon = isOfficial
        ? _officialIcons[index]
        : _aiIcons[index];
    final color = isOfficial
        ? _officialColors[index]
        : _aiColors[index];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // 使用丝滑过渡效果导航到角色详情页面
          NavigationUtils.navigateWithSlideUp(
            context,
            CharacterDetailScreen(
              index: isOfficial ? 100 + index : index,
              name: name,
              description: description,
              icon: icon,
              color: color,
              isOfficial: isOfficial,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 角色图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withAlpha(25), // 0.1*255=25
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Hero(
                    tag: 'character_${isOfficial ? 100 + index : index}',
                    child: Icon(
                      icon,
                      size: 32,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 角色信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOfficial
                                ? const Color(0xFF06C755).withAlpha(25) // 0.1*255=25
                                : color.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isOfficial ? '官方' : 'AI',
                            style: TextStyle(
                              fontSize: 10,
                              color: isOfficial ? const Color(0xFF06C755) : color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.person,
                          size: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600]
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(index + 1) * 1000 + 500}人使用',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 箭头
              Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
