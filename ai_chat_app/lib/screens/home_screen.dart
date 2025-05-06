import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/colors.dart';
import '../animations/smooth_page_transition.dart';
import '../utils/navigation_utils.dart';
import 'chat_list_screen.dart';
import 'community_screen.dart';
import 'character_screen.dart';
import 'store_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late PageController _pageController;
  bool _isAnimating = false;

  final List<Widget> _screens = const [
    ChatListScreen(),
    CommunityScreen(),
    CharacterScreen(),
    StoreScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // 禁用滑动，只通过底部导航切换
        itemCount: _screens.length,
        itemBuilder: (context, index) {
          // 使用PageContentFadeIn包装每个页面，实现丝滑的过渡效果
          return PageContentFadeIn(
            key: ValueKey('screen_$index'),
            duration: const Duration(milliseconds: 500),
            child: _screens[index],
          );
        },
      ),
      bottomNavigationBar: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDarkMode = themeProvider.isDarkMode;
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black.withAlpha(30) : Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: NavigationBar(
                height: 64,
                elevation: 0,
                backgroundColor: isDarkMode ? AppColors.darkBottomNavBackground : Colors.white,
                selectedIndex: _selectedIndex,
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                animationDuration: const Duration(milliseconds: 500),
                onDestinationSelected: (index) {
                  if (_isAnimating || _selectedIndex == index) return;

                  setState(() {
                    _isAnimating = true;
                    _selectedIndex = index;
                  });

                  // 使用PageController平滑切换页面
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                  ).then((_) {
                    setState(() {
                      _isAnimating = false;
                    });
                  });

                  _animationController.reset();
                  _animationController.forward();
                },
                destinations: [
                  _buildNavDestination(
                    icon: Icons.chat_bubble_outline,
                    selectedIcon: Icons.chat_bubble,
                    label: '聊天',
                    index: 0,
                  ),
                  _buildNavDestination(
                    icon: Icons.people_outline,
                    selectedIcon: Icons.people,
                    label: '社区',
                    index: 1,
                  ),
                  _buildNavDestination(
                    icon: Icons.face_outlined,
                    selectedIcon: Icons.face,
                    label: '角色',
                    index: 2,
                  ),
                  _buildNavDestination(
                    icon: Icons.shopping_bag_outlined,
                    selectedIcon: Icons.shopping_bag,
                    label: '商城',
                    index: 3,
                  ),
                  _buildNavDestination(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: '我的',
                    index: 4,
                  ),
                ],
              ),
            ),
          );
        }),
    );
  }

  Widget _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected
            ? AppColors.primary
            : isDarkMode
                ? AppColors.darkBottomNavInactiveIcon
                : Colors.grey[600],
      ),
      selectedIcon: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return Transform.scale(
            scale: isSelected ? value : 1.0,
            child: Icon(
              selectedIcon,
              color: AppColors.primary,
            ),
          );
        },
      ),
      label: label,
    );
  }
}
