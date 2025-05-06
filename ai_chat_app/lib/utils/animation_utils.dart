import 'package:flutter/material.dart';

/// 动画工具类
class AnimationUtils {
  // 淡入动画
  static Widget fadeAnimation({
    required AnimationController controller,
    required Widget child,
    Curve curve = Curves.easeOut,
    double begin = 0.0,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final Animation<double> animation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return FadeTransition(opacity: animation, child: child);
  }

  // 滑动动画
  static Widget slideAnimation({
    required AnimationController controller,
    required Widget child,
    Curve curve = Curves.easeOut,
    Offset begin = const Offset(0.0, 0.1),
    Offset end = Offset.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final Animation<Offset> animation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return SlideTransition(position: animation, child: child);
  }

  // 缩放动画
  static Widget scaleAnimation({
    required AnimationController controller,
    required Widget child,
    Curve curve = Curves.easeOut,
    double begin = 0.8,
    double end = 1.0,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final Animation<double> animation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return ScaleTransition(scale: animation, child: child);
  }

  // 组合动画：淡入+滑动
  static Widget fadeSlideAnimation({
    required AnimationController controller,
    required Widget child,
    Curve curve = Curves.easeOut,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
    Offset slideBegin = const Offset(0.0, 0.1),
    Offset slideEnd = Offset.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final Animation<double> fadeAnimation = Tween<double>(
      begin: fadeBegin,
      end: fadeEnd,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: slideEnd,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }

  // 错开列表动画
  static List<Widget> staggeredList({
    required AnimationController controller,
    required List<Widget> children,
    Curve curve = Curves.easeOut,
    double fadeBegin = 0.0,
    double fadeEnd = 1.0,
    Offset slideBegin = const Offset(0.0, 0.05),
    Offset slideEnd = Offset.zero,
    int staggerMilliseconds = 50,
  }) {
    final List<Widget> result = [];

    for (int i = 0; i < children.length; i++) {
      final Animation<double> fadeAnimation = Tween<double>(
        begin: fadeBegin,
        end: fadeEnd,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            (i * staggerMilliseconds) / 1000,
            ((i + 1) * staggerMilliseconds) / 1000,
            curve: curve,
          ),
        ),
      );

      final Animation<Offset> slideAnimation = Tween<Offset>(
        begin: slideBegin,
        end: slideEnd,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            (i * staggerMilliseconds) / 1000,
            ((i + 1) * staggerMilliseconds) / 1000,
            curve: curve,
          ),
        ),
      );

      result.add(
        FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: children[i]),
        ),
      );
    }

    return result;
  }

  // 脉冲动画
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: minScale, end: maxScale),
      duration: duration,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
      onEnd: () {},
    );
  }

  // 闪烁动画
  static Widget blinkAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minOpacity = 0.5,
    double maxOpacity = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: minOpacity, end: maxOpacity),
      duration: duration,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
      onEnd: () {},
    );
  }

  // 波纹动画
  static Widget rippleAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Color color = Colors.blue,
    double minRadius = 0.0,
    double maxRadius = 50.0,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: minRadius, end: maxRadius),
          duration: duration,
          builder: (context, value, _) {
            return Container(
              width: value * 2,
              height: value * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(
                  ((1 - (value / maxRadius)) * 255).toInt(),
                ),
              ),
            );
          },
          onEnd: () {},
        ),
        child,
      ],
    );
  }
}
