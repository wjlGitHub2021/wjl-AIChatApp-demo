import 'package:flutter/material.dart';

/// 导航工具类
/// 提供丝滑的页面导航方法，实现类似 inflection.ai 的过渡效果
class NavigationUtils {
  /// 使用丝滑过渡效果导航到新页面
  static Future<T?> navigateWithSlideUp<T>(
    BuildContext context,
    Widget page, {
    bool replace = false,
    RouteSettings? settings,
  }) {
    final route = PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用更平滑的曲线
        const curve = Curves.easeOutCubic;

        // 淡入动画
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        // 缩放动画 - 从稍微小一点的尺寸开始，创造更丝滑的感觉
        var scaleAnimation = Tween<double>(
          begin: 0.97,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        // 位移动画 - 轻微的上移效果
        var slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.03),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        // 组合动画效果
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350), // 更短的动画时间，感觉更快
      reverseTransitionDuration: const Duration(milliseconds: 300),
      opaque: false, // 设置为透明背景，使过渡更加平滑
      barrierColor: Colors.black.withOpacity(0.0), // 无障碍颜色
    );

    if (replace) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }

  /// 使用丝滑过渡效果导航到新页面并移除之前的所有页面
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    final route = PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用更平滑的曲线
        const curve = Curves.easeOutCubic;

        // 淡入动画
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        // 缩放动画 - 从稍微小一点的尺寸开始，创造更丝滑的感觉
        var scaleAnimation = Tween<double>(
          begin: 0.97,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        // 位移动画 - 轻微的上移效果
        var slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.03),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        // 组合动画效果
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350), // 更短的动画时间，感觉更快
      reverseTransitionDuration: const Duration(milliseconds: 300),
      opaque: false, // 设置为透明背景，使过渡更加平滑
      barrierColor: Colors.black.withOpacity(0.0), // 无障碍颜色
    );

    return Navigator.pushAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }

  /// 使用淡入淡出效果导航到新页面
  static Future<T?> navigateWithFade<T>(
    BuildContext context,
    Widget page, {
    bool replace = false,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final route = PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 250),
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.0),
    );

    if (replace) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }
}
