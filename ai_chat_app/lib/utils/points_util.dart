import '../models/user_model.dart';
import '../models/ai_model_info.dart';

/// 点数工具类
class PointsUtil {
  /// 计算使用AI模型的成本
  static int calculateCost(String modelId) {
    final model = AIModelInfo.getModelById(modelId);
    return model.costPerMessage;
  }
  
  /// 检查用户是否有足够的点数
  static bool hasEnoughPoints(UserModel user, int cost) {
    return user.points >= cost;
  }
  
  /// 计算用户可以发送的消息数量
  static int calculateMessageCount(UserModel user, String modelId) {
    final cost = calculateCost(modelId);
    if (cost <= 0) return 0;
    return user.points ~/ cost;
  }
}
