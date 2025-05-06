/// 应用常量
class AppConstants {
  // 应用名称
  static const String appName = 'AI聊天助手';
  
  // 页面切换动画时长
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  
  // 默认动画时长
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // 消息发送延迟（模拟网络延迟）
  static const Duration messageSendDelay = Duration(milliseconds: 500);
  
  // 消息接收延迟（模拟AI思考时间）
  static const Duration messageReceiveDelay = Duration(milliseconds: 1000);
  
  // 默认头像URL
  static const String defaultAvatarUrl = 'https://ui-avatars.com/api/?name=User&background=random';
  
  // 默认AI头像URL
  static const String defaultAIAvatarUrl = 'https://ui-avatars.com/api/?name=AI&background=0D8ABC&color=fff';
  
  // 默认点数
  static const int defaultPoints = 100;
  
  // 每条消息消耗的点数
  static const int pointsPerMessage = 1;
  
  // 默认AI模型
  static const String defaultAIModel = 'gpt-4';
  
  // 支持的AI模型
  static const List<String> supportedAIModels = [
    'gpt-4',
    'claude',
    'gemini',
    'llama',
  ];
  
  // 每个AI模型的价格（点数）
  static const Map<String, int> modelPrices = {
    'gpt-4': 10,
    'claude': 8,
    'gemini': 5,
    'llama': 3,
  };
  
  // 每个AI模型的评分
  static const Map<String, double> modelRatings = {
    'gpt-4': 4.9,
    'claude': 4.7,
    'gemini': 4.5,
    'llama': 4.2,
  };
}
