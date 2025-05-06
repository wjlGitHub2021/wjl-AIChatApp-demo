import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/ai_model_info.dart';
import '../utils/encoding_utils.dart';

class AIService {
  // OpenRouter API 基础URL
  static const String _baseUrl = "https://openrouter.ai/api/v1";

  // API密钥
  static const String _apiKey =
      "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";

  // 网站信息，用于OpenRouter排名 - 直接在请求头中使用

  // 模型ID映射
  final Map<String, String> _modelIds = {
    'gemini': 'google/gemini-2.5-pro-exp-03-25:free',
    'deepseek': 'deepseek/deepseek-chat-v3-0324:free',
    'shisa': 'shisa-ai/shisa-v2-llama3.3-70b:free',
  };

  // 发送消息到AI并获取回复
  Future<String> sendMessage(
    String message,
    List<Map<String, dynamic>> history,
    String modelId,
  ) async {
    try {
      // 检查消息是否为空
      if (message.trim().isEmpty) {
        return '请输入有效的消息内容';
      }
      // 获取模型ID
      final String openrouterModelId =
          _modelIds[modelId] ?? _modelIds['gemini']!;

      // 构建消息历史
      final List<Map<String, dynamic>> messages = [];

      // 添加历史消息
      for (var msg in history) {
        messages.add({
          'role': msg['isUser'] ? 'user' : 'assistant',
          'content': msg['text'],
        });
      }

      // 添加当前消息
      messages.add({'role': 'user', 'content': message});

      // 构建请求体
      final Map<String, dynamic> requestBody = {
        'model': openrouterModelId,
        'messages': messages,
      };

      // 设置请求头，确保使用UTF-8编码
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://aichatapp.example.com',
        'X-Title': 'AI Chat App',
        'Accept': 'application/json; charset=utf-8',
        'Accept-Charset': 'utf-8',
      };

      // 记录请求信息，便于调试
      developer.log('发送API请求到: $_baseUrl/chat/completions');
      developer.log('请求头: $headers');
      developer.log('请求体: ${jsonEncode(requestBody)}');

      // 发送请求
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // 记录响应信息
      developer.log('API响应状态码: ${response.statusCode}');
      developer.log('API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        String content;
        try {
          // 确保响应体是有效的UTF-8编码
          final String validUtf8Body = utf8.decode(response.bodyBytes, allowMalformed: true);
          final data = jsonDecode(validUtf8Body);
          developer.log('解码后的API响应内容: ${validUtf8Body.length > 100 ? validUtf8Body.substring(0, 100) + "..." : validUtf8Body}');

          content = data['choices'][0]['message']['content'];
          developer.log('API响应成功，内容长度: ${content.length}');
          developer.log('API响应内容前100字符: ${content.length > 100 ? content.substring(0, 100) + "..." : content}');
        } catch (e) {
          developer.log('解析API响应JSON时出错: $e');
          return '解析AI回复时出错，请稍后再试。错误: $e';
        }

        // 无论是否检测到编码问题，都尝试进行文本清理
        try {
          final String cleanedContent = EncodingUtils.cleanTextContent(content);

          // 处理后的内容
          String processedContent = cleanedContent;

          // 如果检测到编码问题，尝试更深入的修复
          if (EncodingUtils.containsEncodingIssues(processedContent)) {
            developer.log('检测到编码问题，尝试修复...');
            final String fixedContent = EncodingUtils.fixChineseEncoding(processedContent);
            developer.log('编码修复尝试完成');

            if (fixedContent != processedContent) {
              processedContent = EncodingUtils.cleanTextContent(fixedContent);
            }
          }

          // 确保代码块正确格式化
          processedContent = _ensureCodeBlocksFormatted(processedContent);

          developer.log('处理后的AI回复内容: ${processedContent.length > 100 ? processedContent.substring(0, 100) + "..." : processedContent}');
          return processedContent;
        } catch (e) {
          developer.log('处理文本内容时出错: $e');
          // 即使处理失败，也尝试确保代码块格式化后返回
          try {
            return _ensureCodeBlocksFormatted(content);
          } catch (formatError) {
            developer.log('格式化代码块时出错: $formatError');
            // 如果格式化也失败，返回原始内容
            return content;
          }
        }
      } else {
        developer.log('API请求失败: ${response.statusCode} ${response.body}');

        // 尝试从响应中提取更详细的错误信息
        String errorMessage = '未知错误';
        try {
          // 确保响应体是有效的UTF-8编码
          final String validUtf8Body = utf8.decode(response.bodyBytes, allowMalformed: true);
          final errorData = jsonDecode(validUtf8Body);
          developer.log('解码后的错误响应: $validUtf8Body');

          if (errorData.containsKey('error') && errorData['error'] is Map) {
            final errorObj = errorData['error'];
            if (errorObj.containsKey('message')) {
              errorMessage = errorObj['message'];
            } else if (errorObj.containsKey('text')) {
              errorMessage = errorObj['text'];
            }
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          developer.log('解析错误响应时出错: $e');
          // 如果JSON解析失败，尝试直接使用响应体作为错误信息
          try {
            errorMessage = utf8.decode(response.bodyBytes, allowMalformed: true);
            errorMessage = errorMessage.length > 100 ? '${errorMessage.substring(0, 100)}...' : errorMessage;
          } catch (decodeError) {
            developer.log('解码错误响应时出错: $decodeError');
            errorMessage = response.body.length > 100 ? '${response.body.substring(0, 100)}...' : response.body;
          }
        }

        return '抱歉，AI回复失败，请稍后再试。错误代码: ${response.statusCode}, 错误信息: $errorMessage';
      }
    } catch (e) {
      developer.log('发送消息时出错: $e');
      return '抱歉，我无法连接到AI服务。错误: $e';
    }
  }

  // 这些方法已移至 EncodingUtils 类

  // 确保代码块正确格式化
  String _ensureCodeBlocksFormatted(String text) {
    // 检查文本是否已经包含格式化的代码块
    if (text.contains('```') && RegExp(r'```\w*\n').hasMatch(text)) {
      // 已经包含格式化的代码块，不需要处理
      return text;
    }

    // 简单检测是否包含代码特征
    String language = 'plaintext';

    // 检测Python代码
    if (text.contains('def ') ||
        text.contains('import ') ||
        text.contains('print(') ||
        text.contains('for ') && text.contains('in range(')) {
      language = 'python';
    }
    // 检测JavaScript代码
    else if (text.contains('function') ||
             text.contains('const ') ||
             text.contains('let ') ||
             text.contains('var ')) {
      language = 'javascript';
    }
    // 检测Java代码
    else if (text.contains('public class') ||
             text.contains('System.out.println')) {
      language = 'java';
    }
    // 检测C/C++代码
    else if (text.contains('#include') ||
             text.contains('int main')) {
      language = 'cpp';
    }

    // 如果检测到特定语言，将文本包装为代码块
    if (language != 'plaintext') {
      return '```$language\n$text\n```';
    }

    // 如果没有检测到特定语言特征，返回原始文本
    return text;
  }

  // 保存聊天历史
  Future<void> saveHistory(List<Map<String, dynamic>> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(history);
      await prefs.setString('chat_history', historyJson);
    } catch (e) {
      developer.log('保存聊天历史失败: $e');
    }
  }

  // 加载聊天历史
  Future<List<Map<String, dynamic>>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('chat_history');

      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      developer.log('加载聊天历史失败: $e');
    }

    return [];
  }

  // 清除聊天历史
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history');
    } catch (e) {
      developer.log('清除聊天历史失败: $e');
    }
  }
}
