import 'package:shared_preferences/shared_preferences.dart';

/// 主题模式
enum ThemeMode {
  light,
  dark,
  system,
}

/// 主题服务
class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  // 获取主题模式
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    
    if (themeIndex == null) {
      return ThemeMode.system;
    }
    
    return ThemeMode.values[themeIndex];
  }
  
  // 设置主题模式
  static Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }
}
