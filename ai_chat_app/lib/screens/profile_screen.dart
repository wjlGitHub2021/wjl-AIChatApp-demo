import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/colors.dart';
import '../animations/smooth_page_transition.dart';
import '../utils/navigation_utils.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuint,
      ),
    );
    // 延迟一帧后启动动画，让页面有时间构建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 头部背景区域
              Container(
                color: isDarkMode ? const Color(0xFF121212) : Colors.white,
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // 头像
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                'https://placekitten.com/200/200', // 示例头像
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 用户名
          Text(
            '钰珑',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // 用户ID
          Text(
            'ID:315505',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton('个人主页', Icons.person),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton('编辑设定', Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        // 我的资产
        _buildMenuItem(
          title: '我的资产',
          subtitle: 'Lv.1',
          icon: Icons.account_balance_wallet,
          rightWidget: Row(
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[300],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),

        // 创作站
        _buildMenuItem(
          title: '创作站',
          icon: Icons.create,
          rightWidget: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),

        // 草稿箱
        _buildMenuItem(
          title: '草稿箱',
          icon: Icons.drafts,
          rightWidget: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),

        // 创建角色
        _buildMenuItem(
          title: '创建角色',
          icon: Icons.person_add,
          rightWidget: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),

        // 我的角色
        _buildMenuItem(
          title: '我的角色',
          icon: Icons.person,
          rightWidget: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),

        // 我的情景
        _buildMenuItem(
          title: '我的情景',
          icon: Icons.landscape,
          rightWidget: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),

        // 系统设置
        _buildMenuItem(
          title: '系统设置',
          icon: Icons.settings,
          rightWidget: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            NavigationUtils.navigateWithSlideUp(
              context,
              const SettingsScreen(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? iconWidget,
    Widget? rightWidget,
    VoidCallback? onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 1),
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        child: Row(
          children: [
            // 左侧图标
            if (iconWidget != null)
              iconWidget
            else if (icon != null)
              Icon(icon, color: Colors.grey, size: 24),
            const SizedBox(width: 16),

            // 标题和副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 右侧内容
            if (rightWidget != null) rightWidget,
          ],
        ),
      ),
    );
  }
}
