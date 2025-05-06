import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'dart:developer' as developer;
import '../models/message_model.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String _selectedModelId = 'gemini'; // 默认使用gemini模型

  // Getters
  List<MessageModel> get messages => _messages;
  List<types.Message> get chatMessages =>
      _messages.map((msg) => msg.toTextMessage()).toList();
  bool get isLoading => _isLoading;
  String get selectedModelId => _selectedModelId;

  // 设置选择的模型ID
  void setSelectedModelId(String modelId) {
    _selectedModelId = modelId;
    notifyListeners();
  }

  // 初始化，加载历史消息
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final history = await _aiService.loadHistory();
      _messages =
          history
              .map((json) => MessageModel.fromJson(json))
              .toList()
              .reversed
              .toList();
    } catch (e) {
      developer.log('初始化聊天历史失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 发送消息
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 添加用户消息
    final userMessage = MessageModel(text: text, isUser: true);
    _messages.insert(0, userMessage);
    notifyListeners();

    // 保存历史
    _saveHistory();

    // 设置加载状态
    _isLoading = true;
    notifyListeners();

    try {
      // 准备历史消息格式
      final history =
          _messages.map((msg) => msg.toJson()).toList().reversed.toList();

      // 获取AI回复
      final response = await _aiService.sendMessage(
        text,
        history,
        _selectedModelId, // 使用用户选择的模型ID
      );

      // 处理AI回复，确保代码块格式正确
      String formattedResponse = _formatCodeBlocks(response);

      // 添加AI回复消息
      final aiMessage = MessageModel(text: formattedResponse, isUser: false);
      _messages.insert(0, aiMessage);
    } catch (e) {
      // 添加错误消息
      final errorMessage = MessageModel(text: '发送消息失败: $e', isUser: false);
      _messages.insert(0, errorMessage);
    }

    // 更新状态
    _isLoading = false;
    notifyListeners();

    // 保存历史
    _saveHistory();
  }

  // 清除聊天历史
  Future<void> clearChat() async {
    _messages.clear();
    await _aiService.clearHistory();
    notifyListeners();
  }

  // 保存聊天历史
  Future<void> _saveHistory() async {
    final history = _messages.map((msg) => msg.toJson()).toList();
    await _aiService.saveHistory(history);
  }

  // 格式化代码块
  String _formatCodeBlocks(String text) {
    // 如果文本中已经包含完整的Markdown代码块格式，则不需要处理
    if (RegExp(r'```[a-z]*\n[\s\S]*?```').hasMatch(text)) {
      return text;
    }

    // 检查是否包含Python代码特征
    if (_containsPythonCode(text)) {
      return '```python\n$text\n```';
    }

    // 检查是否包含JavaScript代码特征
    if (_containsJavaScriptCode(text)) {
      return '```js\n$text\n```';
    }

    // 检查是否包含Dart代码特征
    if (_containsDartCode(text)) {
      return '```dart\n$text\n```';
    }

    // 检查是否包含Java代码特征
    if (_containsJavaCode(text)) {
      return '```java\n$text\n```';
    }

    // 检查是否包含C/C++代码特征
    if (_containsCppCode(text)) {
      return '```cpp\n$text\n```';
    }

    // 检查是否包含HTML代码特征
    if (_containsHtmlCode(text)) {
      return '```html\n$text\n```';
    }

    // 检查是否包含CSS代码特征
    if (_containsCssCode(text)) {
      return '```css\n$text\n```';
    }

    // 如果没有检测到特定语言，但看起来像代码，使用纯文本代码块
    if (_looksLikeCode(text)) {
      return '```\n$text\n```';
    }

    return text;
  }

  // 检查是否包含Python代码特征
  bool _containsPythonCode(String text) {
    return text.contains('def ') ||
        text.contains('import ') ||
        text.contains('print(') ||
        (text.contains('for ') && text.contains('in range(')) ||
        text.contains('bubble_sort') ||
        text.contains('冒泡排序') ||
        text.contains('class ') && text.contains('self') ||
        text.contains('if __name__ == "__main__"');
  }

  // 检查是否包含JavaScript代码特征
  bool _containsJavaScriptCode(String text) {
    return text.contains('function ') ||
        text.contains('const ') ||
        text.contains('let ') ||
        text.contains('var ') ||
        text.contains('() =>') ||
        text.contains('document.') ||
        text.contains('window.') ||
        text.contains('console.log');
  }

  // 检查是否包含Dart代码特征
  bool _containsDartCode(String text) {
    return text.contains('void main()') ||
        text.contains('StatelessWidget') ||
        text.contains('StatefulWidget') ||
        text.contains('BuildContext') ||
        text.contains('Widget build') ||
        text.contains('flutter');
  }

  // 检查是否包含Java代码特征
  bool _containsJavaCode(String text) {
    return text.contains('public class') ||
        text.contains('private ') ||
        text.contains('protected ') ||
        text.contains('System.out.println') ||
        text.contains('public static void main');
  }

  // 检查是否包含C/C++代码特征
  bool _containsCppCode(String text) {
    return text.contains('#include') ||
        text.contains('int main()') ||
        text.contains('std::') ||
        text.contains('cout <<') ||
        text.contains('printf(');
  }

  // 检查是否包含HTML代码特征
  bool _containsHtmlCode(String text) {
    return text.contains('<html') ||
        text.contains('<!DOCTYPE') ||
        text.contains('<div') ||
        text.contains('<body') ||
        text.contains('<head') ||
        (text.contains('<') && text.contains('</') && text.contains('>'));
  }

  // 检查是否包含CSS代码特征
  bool _containsCssCode(String text) {
    return text.contains('{') &&
        (text.contains('margin:') ||
            text.contains('padding:') ||
            text.contains('color:') ||
            text.contains('background:') ||
            text.contains('font-size:'));
  }

  // 检查文本是否看起来像代码
  bool _looksLikeCode(String text) {
    // 如果包含多行，且有缩进或特殊符号，可能是代码
    return text.contains('\n') &&
        (text.contains('  ') || // 两个空格的缩进
            text.contains('\t') || // Tab缩进
            text.contains(';') || // 语句结束符
            text.contains('{') && text.contains('}') || // 代码块
            text.contains('(') && text.contains(')')); // 函数调用
  }
}
