import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// 用户服务类
class UserService {
  static const String _userKey = 'user_data';

  /// 获取用户信息
  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        return null;
      }

      return UserModel.fromJson(json.decode(userJson));
    } catch (e) {
      developer.log('Error getting user: $e');
      return null;
    }
  }

  /// 保存用户信息
  static Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userKey, json.encode(user.toJson()));
    } catch (e) {
      developer.log('Error saving user: $e');
      return false;
    }
  }

  /// 更新用户点数
  static Future<bool> updatePoints(int points) async {
    try {
      final user = await getUser();

      if (user == null) {
        return false;
      }

      user.points = points;
      return await saveUser(user);
    } catch (e) {
      developer.log('Error updating points: $e');
      return false;
    }
  }

  /// 清除用户信息
  static Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userKey);
    } catch (e) {
      developer.log('Error clearing user: $e');
      return false;
    }
  }
}
