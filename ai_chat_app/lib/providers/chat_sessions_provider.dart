import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../models/ai_model_info.dart';
import '../services/ai_service.dart';
import '../utils/points_util.dart' as points;

class ChatSessionsProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  List<ChatSessionModel> _sessions = [];
  String _currentSessionId = '';
  bool _isLoading = false;
  UserModel _user = MockUsers.defaultUser;
  String _currentAIModel = 'gemini'; // 默认使用Google Gemini

  // Getters
  List<ChatSessionModel> get sessions => _sessions;
  List<ChatSessionModel> get visibleSessions =>
      _sessions.where((s) => !s.isHidden).toList();
  ChatSessionModel? get currentSession =>
      _sessions.isEmpty
          ? null
          : _sessions.firstWhere(
            (s) => s.id == _currentSessionId,
            orElse: () => _sessions.first,
          );
  bool get isLoading => _isLoading;
  UserModel get user => _user;
  String get currentAIModel => _currentAIModel;

  // 初始化，加载会话列表
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 加载会话列表
      final sessions = await _loadSessions();
      _sessions = sessions;

      // 如果有会话，设置当前会话为第一个
      if (_sessions.isNotEmpty) {
        _currentSessionId = _sessions.first.id;
      }

      // 加载用户信息
      await _loadUserInfo();
    } catch (e) {
      developer.log('初始化会话列表失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 创建新会话
  ChatSessionModel createNewSession(String title, {String aiModel = 'gemini'}) {
    final newSession = ChatSessionModel(title: title, aiModel: aiModel);

    _sessions.insert(0, newSession);
    _currentSessionId = newSession.id;

    _saveSessions();
    notifyListeners();

    return newSession;
  }

  // 添加AI消息
  Future<void> addAIMessage(String sessionId, String message) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _sessions[index];

      // 创建AI消息
      final aiMessage = MessageModel(text: message, isUser: false);

      // 获取当前会话的消息列表
      final currentMessages = List<MessageModel>.from(session.messages);
      currentMessages.insert(0, aiMessage);

      // 更新会话
      final updatedSession = session.copyWith(
        messages: currentMessages,
        lastMessage: message,
        lastMessageTime: DateTime.now(),
      );

      // 更新会话列表
      _sessions[index] = updatedSession;
      await _saveSessions();
      notifyListeners();
    }
  }

  // 设置当前会话
  void setCurrentSession(String sessionId) {
    _currentSessionId = sessionId;
    notifyListeners();
  }

  // 设置当前AI模型
  Future<bool> setCurrentAIModel(String modelId) async {
    // 计算使用该模型的成本
    final cost = points.PointsUtil.calculateCost(modelId);

    // 检查用户是否有足够的点数
    if (!points.PointsUtil.hasEnoughPoints(_user, cost)) {
      return false;
    }

    _currentAIModel = modelId;

    // 如果有当前会话，更新会话的AI模型
    if (currentSession != null) {
      final updatedSession = currentSession!.copyWith(aiModel: modelId);

      final index = _sessions.indexWhere((s) => s.id == _currentSessionId);
      if (index != -1) {
        _sessions[index] = updatedSession;
        await _saveSessions();
      }
    }

    notifyListeners();
    return true;
  }

  // 发送消息
  Future<bool> sendMessage(String text) async {
    if (text.trim().isEmpty || currentSession == null) return false;

    // 计算使用当前模型的成本
    final cost = points.PointsUtil.calculateCost(_currentAIModel);

    // 检查用户是否有足够的点数
    if (!points.PointsUtil.hasEnoughPoints(_user, cost)) {
      return false;
    }

    // 扣除点数
    _user = _user.copyWith(points: _user.points - cost.toInt());
    await _saveUserInfo();

    // 添加用户消息
    final userMessage = MessageModel(text: text, isUser: true);

    // 获取当前会话的消息列表
    final currentMessages = List<MessageModel>.from(currentSession!.messages);
    currentMessages.insert(0, userMessage);

    // 更新会话
    final updatedSession = currentSession!.copyWith(
      messages: currentMessages,
      lastMessage: text,
      lastMessageTime: DateTime.now(),
    );

    // 更新会话列表
    final index = _sessions.indexWhere((s) => s.id == _currentSessionId);
    if (index != -1) {
      _sessions[index] = updatedSession;
      await _saveSessions();
    }

    notifyListeners();

    // 设置加载状态
    _isLoading = true;
    notifyListeners();

    try {
      // 准备历史消息格式
      final history =
          currentMessages.map((msg) => msg.toJson()).toList().reversed.toList();

      // 获取AI回复
      final response = await _aiService.sendMessage(
        text,
        history,
        _currentAIModel,
      );

      // 添加AI回复消息
      final aiMessage = MessageModel(text: response, isUser: false);

      // 更新消息列表
      currentMessages.insert(0, aiMessage);

      // 再次更新会话
      final finalUpdatedSession = updatedSession.copyWith(
        messages: currentMessages,
        lastMessage: response,
        lastMessageTime: DateTime.now(),
      );

      // 更新会话列表
      _sessions[index] = finalUpdatedSession;
      await _saveSessions();

      return true;
    } catch (e) {
      // 添加错误消息
      final errorMessage = MessageModel(text: '发送消息失败: $e', isUser: false);

      // 更新消息列表
      currentMessages.insert(0, errorMessage);

      // 再次更新会话
      final finalUpdatedSession = updatedSession.copyWith(
        messages: currentMessages,
        lastMessage: '发送消息失败',
        lastMessageTime: DateTime.now(),
      );

      // 更新会话列表
      _sessions[index] = finalUpdatedSession;
      await _saveSessions();

      return false;
    } finally {
      // 更新状态
      _isLoading = false;
      notifyListeners();
    }
  }

  // 置顶会话
  Future<void> pinSession(String sessionId) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _sessions[index];
      final updatedSession = session.copyWith(isPinned: !session.isPinned);

      _sessions.removeAt(index);

      // 如果是置顶，放在列表最前面，否则放在所有置顶会话之后
      if (updatedSession.isPinned) {
        _sessions.insert(0, updatedSession);
      } else {
        final lastPinnedIndex = _sessions.lastIndexWhere((s) => s.isPinned);
        _sessions.insert(lastPinnedIndex + 1, updatedSession);
      }

      await _saveSessions();
      notifyListeners();
    }
  }

  // 隐藏会话
  Future<void> hideSession(String sessionId) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _sessions[index];
      final updatedSession = session.copyWith(isHidden: !session.isHidden);

      _sessions[index] = updatedSession;
      await _saveSessions();
      notifyListeners();
    }
  }

  // 删除会话
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);

    // 如果删除的是当前会话，设置新的当前会话
    if (_currentSessionId == sessionId && _sessions.isNotEmpty) {
      _currentSessionId = _sessions.first.id;
    }

    await _saveSessions();
    notifyListeners();
  }

  // 清除所有会话
  Future<void> clearAllSessions() async {
    _sessions.clear();
    _currentSessionId = '';
    await _saveSessions();
    notifyListeners();
  }

  // 加载会话列表
  Future<List<ChatSessionModel>> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString('chat_sessions');

      if (sessionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        return decoded.map((json) => ChatSessionModel.fromJson(json)).toList();
      }
    } catch (e) {
      developer.log('加载会话列表失败: $e');
    }

    return [];
  }

  // 保存会话列表
  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = jsonEncode(
        _sessions.map((s) => s.toJson()).toList(),
      );
      await prefs.setString('chat_sessions', sessionsJson);
    } catch (e) {
      developer.log('保存会话列表失败: $e');
    }
  }

  // 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_info');

      if (userJson != null) {
        final decoded = jsonDecode(userJson);
        _user = UserModel.fromJson(decoded);
      }
    } catch (e) {
      developer.log('加载用户信息失败: $e');
    }
  }

  // 保存用户信息
  Future<void> _saveUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(_user.toJson());
      await prefs.setString('user_info', userJson);
    } catch (e) {
      developer.log('保存用户信息失败: $e');
    }
  }

  // 添加点数
  Future<void> addPoints(int amount) async {
    _user = _user.copyWith(points: _user.points + amount);
    await _saveUserInfo();
    notifyListeners();
  }
}
