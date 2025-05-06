import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/colors.dart';
import '../animations/theme_transition.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // 主题颜色选项
  final List<Map<String, dynamic>> _themeColors = [
    {
      'name': '清新绿',
      'color': const LinearGradient(
        colors: [Color(0xFF87CF3E), Color(0xFF06C755)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': '天空蓝',
      'color': const LinearGradient(
        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'selected': true,
    },
    {
      'name': '梦幻紫',
      'color': const LinearGradient(
        colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': '珊瑚粉',
      'color': const LinearGradient(
        colors: [Color(0xFFFF8A80), Color(0xFFE57373)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': '活力橙',
      'color': const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  // 当前选中的主题颜色
  String _selectedThemeColor = '天空蓝';
  // 是否跟随系统
  bool _followSystem = false;
  // 当前主题模式
  String _themeMode = '光明模式';

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
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    // 初始化主题设置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      // 初始化主题过渡动画控制器
      themeProvider.initializeAnimation(this);
      setState(() {
        _themeMode = themeProvider.isDarkMode ? '黑夜模式' : '光明模式';
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // 释放主题过渡动画控制器
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.disposeAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return SlideTransition(
      position: _slideAnimation,
      child: ThemeTransitionBackground(
        lightColor: Colors.grey[50]!,
        darkColor: const Color(0xFF121212),
        child: Scaffold(
          backgroundColor: Colors.transparent, // 使用透明背景，让过渡背景显示
          appBar: AppBar(
            backgroundColor: Colors.transparent, // 使用透明背景
            title: Text(
              '主题色切换',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0,
          ),
          body: ListView(
            children: [
              // 基础色
              _buildSectionHeader('基础色'),

              // 跟随系统
              _buildSwitchItem(
                title: '跟随系统',
                value: _followSystem,
                onChanged: (value) {
                  setState(() {
                    _followSystem = value;
                  });
                },
              ),

              // 黑夜模式
              _buildThemeModeItem(
                title: '黑夜模式',
                selected: _themeMode == '黑夜模式',
                onTap: () {
                  setState(() {
                    _themeMode = '黑夜模式';
                  });
                  themeProvider.setDarkMode(true);
                },
              ),

              // 光明模式
              _buildThemeModeItem(
                title: '光明模式',
                selected: _themeMode == '光明模式',
                onTap: () {
                  setState(() {
                    _themeMode = '光明模式';
                  });
                  themeProvider.setDarkMode(false);
                },
              ),

              // 自定义模式
              _buildThemeModeItem(
                title: '自定义模式',
                selected: _themeMode == '自定义模式',
                onTap: () {
                  setState(() {
                    _themeMode = '自定义模式';
                  });
                },
              ),

              // 主题色选择
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _themeColors.map((theme) => _buildThemeColorItem(theme)).toList(),
                ),
              ),

              // 显示当前选中的主题色名称
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _selectedThemeColor,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.blue[200] : Colors.blue[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ThemeTransitionColor(
      lightColor: Colors.white,
      darkColor: const Color(0xFF1A1A1A),
      builder: (context, color) {
        return Container(
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ThemeTransitionColor(
                lightColor: Colors.black,
                darkColor: Colors.white,
                builder: (context, textColor) {
                  return Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  );
                },
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ThemeTransitionColor(
      lightColor: Colors.white,
      darkColor: const Color(0xFF1A1A1A),
      builder: (context, color) {
        return Material(
          color: color,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ThemeTransitionColor(
                    lightColor: Colors.black,
                    darkColor: Colors.white,
                    builder: (context, textColor) {
                      return Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      );
                    },
                  ),
                  if (selected)
                    const Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeColorItem(Map<String, dynamic> theme) {
    final isSelected = theme['name'] == _selectedThemeColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedThemeColor = theme['name'] as String;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: theme['color'] as Gradient,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
      ),
    );
  }
}
