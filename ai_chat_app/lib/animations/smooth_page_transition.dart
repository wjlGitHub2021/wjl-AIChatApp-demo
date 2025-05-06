import 'package:flutter/material.dart';

/// 丝滑页面过渡效果
/// 实现类似 inflection.ai 的页面切换效果
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;
  @override
  final RouteSettings settings;

  SmoothPageTransition({
    required this.page,
    RouteSettings? settings,
  }) : settings = settings ?? const RouteSettings(),
    super(
    settings: settings,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) => page,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
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
}

/// 顺序动画构建器
/// 用于创建元素依次显示的动画效果
class SequentialAnimationBuilder extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Curve curve;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool useScale; // 是否使用缩放效果
  final double slideDistance; // 滑动距离

  const SequentialAnimationBuilder({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 40), // 更短的延迟
    this.itemDuration = const Duration(milliseconds: 500), // 更短的动画时间
    this.curve = Curves.easeOutCubic, // 更平滑的曲线
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.useScale = true, // 默认使用缩放效果
    this.slideDistance = 15.0, // 更小的滑动距离，感觉更精致
  });

  @override
  State<SequentialAnimationBuilder> createState() => _SequentialAnimationBuilderState();
}

class _SequentialAnimationBuilderState extends State<SequentialAnimationBuilder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // 计算总动画时长
    final totalDuration = widget.itemDuration + (widget.staggerDelay * (widget.children.length - 1));

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    // 为每个子元素创建动画
    _animations = List.generate(
      widget.children.length,
      (index) {
        final startTime = index * widget.staggerDelay.inMilliseconds / totalDuration.inMilliseconds;
        final endTime = startTime + widget.itemDuration.inMilliseconds / totalDuration.inMilliseconds;

        return CurvedAnimation(
          parent: _controller,
          curve: Interval(
            startTime,
            endTime,
            curve: widget.curve,
          ),
        );
      },
    );

    // 延迟一帧后启动动画，确保布局已完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      children: List.generate(
        widget.children.length,
        (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            // 组合多种动画效果
            Widget animatedChild = Opacity(
              opacity: _animations[index].value,
              child: Transform.translate(
                offset: Offset(0, widget.slideDistance * (1 - _animations[index].value)),
                child: child,
              ),
            );

            // 如果启用缩放效果
            if (widget.useScale) {
              final scaleValue = 0.95 + (0.05 * _animations[index].value);
              animatedChild = Transform.scale(
                scale: scaleValue,
                alignment: Alignment.center,
                child: animatedChild,
              );
            }

            return animatedChild;
          },
          child: widget.children[index],
        ),
      ),
    );
  }
}

/// 淡入滑动动画组件
/// 用于单个元素的淡入滑动效果
class FadeSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset beginOffset;
  final bool useScale; // 是否使用缩放效果
  final double beginScale; // 起始缩放比例

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500), // 更短的动画时间
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic, // 更平滑的曲线
    this.beginOffset = const Offset(0, 15), // 更小的滑动距离
    this.useScale = true, // 默认使用缩放效果
    this.beginScale = 0.97, // 起始缩放比例
  });

  @override
  State<FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<FadeSlideAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // 延迟启动动画
    if (widget.delay == Duration.zero) {
      // 延迟一帧后启动动画，确保布局已完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget animatedChild = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );

    // 如果启用缩放效果
    if (widget.useScale) {
      animatedChild = ScaleTransition(
        scale: _scaleAnimation,
        child: animatedChild,
      );
    }

    return animatedChild;
  }
}

/// 页面内容淡入动画包装器
/// 用于整个页面内容的淡入效果
class PageContentFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const PageContentFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<PageContentFadeIn> createState() => _PageContentFadeInState();
}

class _PageContentFadeInState extends State<PageContentFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    // 延迟一帧后启动动画，确保布局已完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}
