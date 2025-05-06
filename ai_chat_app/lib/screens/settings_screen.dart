import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/colors.dart';
import '../utils/page_transitions.dart';
import 'theme_selector_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
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

    return SlideTransition(
      position: _slideAnimation,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          title: const Text('系统设置'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              _animationController.reverse().then((_) {
                Navigator.pop(context);
              });
            },
          ),
        ),
        body: ListView(
          children: [
            // 隐私设置
            _buildSectionHeader('隐私设置'),
            _buildSettingItem(
              title: '加我好友的方式',
              trailing: '加我好友需验证',
              onTap: () {},
              showArrow: true,
            ),

            // 系统设置
            _buildSectionHeader('系统设置'),
            _buildSettingItem(
              title: '主题色切换',
              trailing: '天空蓝',
              onTap: () {
                Navigator.push(
                  context,
                  PageTransitions.slideIn(const ThemeSelectorScreen()),
                );
              },
              showArrow: true,
            ),
            _buildSettingItem(
              title: '切换全局回复',
              onTap: () {},
              showArrow: true,
            ),
            _buildSettingItem(
              title: '关于FurryBar',
              onTap: () {},
              showArrow: true,
            ),
            _buildSettingItem(
              title: '字体大小',
              onTap: () {},
              showArrow: true,
            ),
            _buildSettingItem(
              title: '帮助文档',
              onTap: () {},
              showArrow: true,
            ),
            _buildSettingItem(
              title: '彩蛋开关',
              isSwitch: true,
              switchValue: false,
              onSwitchChanged: (value) {},
            ),
            _buildSettingItem(
              title: '气泡模糊',
              isSwitch: true,
              switchValue: true,
              onSwitchChanged: (value) {},
            ),
            _buildSettingItem(
              title: '聊天记录导出列表',
              onTap: () {},
              showArrow: true,
            ),
            _buildSettingItem(
              title: '清理缓存',
              trailing: '23 M',
              onTap: () {},
              showArrow: true,
            ),

            // 账户
            _buildSectionHeader('账户'),
            _buildSettingItem(
              title: '修改密码',
              onTap: () {},
              showArrow: true,
            ),
            _buildSettingItem(
              title: '退出登录',
              onTap: () {},
              showArrow: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      color: isDarkMode ? const Color(0xFF121212) : Colors.transparent,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
    bool isSwitch = false,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: isSwitch ? null : onTap,
      child: Container(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            if (isSwitch)
              Switch(
                value: switchValue ?? false,
                onChanged: onSwitchChanged,
                activeColor: AppColors.primary,
              )
            else if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
}
