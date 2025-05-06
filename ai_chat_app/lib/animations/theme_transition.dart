import 'package:flutter/material.dart';

/// 主题过渡动画控制器
/// 用于实现丝滑的主题切换效果
class ThemeTransition {
  static final ThemeTransition _instance = ThemeTransition._internal();

  factory ThemeTransition() {
    return _instance;
  }

  ThemeTransition._internal();

  // 动画控制器
  AnimationController? _controller;

  // 动画值
  Animation<double>? _animation;

  // 当前主题是否为深色
  bool _isDark = false;

  // 初始化动画控制器
  void initialize(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  // 释放资源
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _animation = null;
  }

  // 切换主题
  void toggleTheme(bool isDark) {
    if (_controller == null || _animation == null) return;

    if (isDark != _isDark) {
      _isDark = isDark;

      if (isDark) {
        _controller!.forward();
      } else {
        _controller!.reverse();
      }
    }
  }

  // 获取动画值
  Animation<double>? get animation => _animation;

  // 获取动画控制器
  AnimationController? get controller => _controller;

  // 是否正在动画中
  bool get isAnimating => _controller?.isAnimating ?? false;
}

/// 主题过渡包装器
/// 用于包装需要平滑过渡的组件
class ThemeTransitionBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, double value) builder;

  const ThemeTransitionBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final transition = ThemeTransition();

    if (transition.animation == null) {
      return builder(context, 1.0);
    }

    return AnimatedBuilder(
      animation: transition.animation!,
      builder: (context, child) {
        return builder(context, transition.animation!.value);
      },
    );
  }
}

/// 主题过渡颜色
/// 用于在两种颜色之间平滑过渡
class ThemeTransitionColor extends StatelessWidget {
  final Color lightColor;
  final Color darkColor;
  final Widget Function(BuildContext context, Color color) builder;

  const ThemeTransitionColor({
    super.key,
    required this.lightColor,
    required this.darkColor,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeTransitionBuilder(
      builder: (context, value) {
        final color = Color.lerp(lightColor, darkColor, value)!;
        return builder(context, color);
      },
    );
  }
}

/// 主题过渡背景
/// 用于创建平滑过渡的背景色
class ThemeTransitionBackground extends StatelessWidget {
  final Widget child;
  final Color lightColor;
  final Color darkColor;

  const ThemeTransitionBackground({
    super.key,
    required this.child,
    required this.lightColor,
    required this.darkColor,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeTransitionColor(
      lightColor: lightColor,
      darkColor: darkColor,
      builder: (context, color) {
        return Container(
          color: color,
          child: child,
        );
      },
    );
  }
}
