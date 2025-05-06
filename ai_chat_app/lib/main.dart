import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/chat_sessions_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'animations/theme_transition.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日期格式化（中文支持）
  await initializeDateFormatting('zh_CN', null);

  // 状态栏设置为透明，导航栏样式将由ThemeProvider控制
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // 设置首选方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatSessionsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // 初始化主题过渡动画控制器
          WidgetsBinding.instance.addPostFrameCallback((_) {
            themeProvider.initializeAnimation(this);
          });

          return MaterialApp(
            title: 'AI聊天助手',
            // 使用自定义主题，不设置pageTransitionsTheme，因为我们将使用自定义过渡效果
            theme: themeProvider.themeData,
            // 使用自定义主题
            onGenerateRoute: (settings) {
              // 获取路由名称对应的页面构建器
              final routes = <String, WidgetBuilder>{
                '/splash': (context) => const SplashScreen(),
                // 其他路由可以在这里添加
              };

              // 如果路由名称存在于routes中，使用自定义过渡效果
              if (settings.name != null && routes.containsKey(settings.name)) {
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                    routes[settings.name]!(context),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 0.05);
                    const end = Offset.zero;
                    const curve = Curves.easeOutQuint;

                    // 位移动画
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    // 淡入动画
                    var fadeAnimation = CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
                    );

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                );
              }

              // 默认返回null，让系统处理未知路由
              return null;
            },
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
