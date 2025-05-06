import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

/// 用户Provider
class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  
  UserProvider() {
    _loadUser();
  }
  
  // 加载用户信息
  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        _user = UserModel.fromJson(json.decode(userJson));
      } else {
        // 如果没有保存的用户信息，使用默认用户
        _user = MockUsers.defaultUser;
        await _saveUser();
      }
    } catch (e) {
      debugPrint('加载用户信息失败: $e');
      _user = MockUsers.defaultUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 保存用户信息
  Future<void> _saveUser() async {
    if (_user == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
    } catch (e) {
      debugPrint('保存用户信息失败: $e');
    }
  }
  
  // 更新用户信息
  Future<void> updateUser(UserModel user) async {
    _user = user;
    await _saveUser();
    notifyListeners();
  }
  
  // 更新用户点数
  Future<void> updatePoints(int points) async {
    if (_user == null) return;
    
    _user = _user!.copyWith(
      points: _user!.points + points,
    );
    
    await _saveUser();
    notifyListeners();
  }
  
  // 消费点数
  Future<bool> consumePoints(int points) async {
    if (_user == null) return false;
    
    if (_user!.points < points) {
      return false;
    }
    
    _user = _user!.copyWith(
      points: _user!.points - points,
    );
    
    await _saveUser();
    notifyListeners();
    
    return true;
  }
  
  // 清除用户数据
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      
      _user = MockUsers.defaultUser;
      notifyListeners();
    } catch (e) {
      debugPrint('清除用户数据失败: $e');
    }
  }
}
