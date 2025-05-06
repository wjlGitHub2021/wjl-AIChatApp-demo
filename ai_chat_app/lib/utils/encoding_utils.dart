import 'dart:convert';
import 'dart:developer' as developer;

/// 编码工具类
/// 用于处理和修复文本编码问题，特别是中文乱码
class EncodingUtils {
  /// 检查内容是否包含编码问题
  static bool containsEncodingIssues(String content) {
    // 如果内容为空，则不需要检查
    if (content.isEmpty) {
      return false;
    }
    
    // 检查常见的中文乱码字符 - 扩展范围以涵盖更多可能的乱码字符
    final RegExp encodingIssuePattern = RegExp(
      r'[åãæäëìíîïðñòóôõöçèéêÿþýüûúùø÷öõôóòñðïîíìëêéèçæåäãâáàß\u00e0-\u00ff]',
    );
    
    // 检查是否有连续的乱码字符，这通常表示编码问题
    final RegExp consecutivePattern = RegExp(r'[åãæäëìíîïðñòóôõöçèéêÿþýüûúùø÷öõôóòñðïîíìëêéèçæåäãâáàß]{2,}');
    if (consecutivePattern.hasMatch(content)) {
      return true;
    }
    
    // 检查乱码字符的密度，如果乱码字符占比过高，可能是编码问题
    if (encodingIssuePattern.hasMatch(content)) {
      final int totalMatches = encodingIssuePattern.allMatches(content).length;
      final double density = totalMatches / content.length;
      
      // 如果乱码字符密度超过2%，认为存在编码问题
      if (density > 0.02) {
        return true;
      }
    }
    
    // 检查常见的乱码特征模式
    final List<RegExp> brokenPatterns = [
      RegExp(r'ä\w+ å\w+'), // 类似"你好"的乱码模式
      RegExp(r'æ\w+ å\w+'), // 类似"的你"的乱码模式
      RegExp(r'è\w+ è\w+'), // 类似"谢谢"的乱码模式
      RegExp(r'ä\w+ æ'), // 类似"中文"的乱码模式
    ];
    
    for (final pattern in brokenPatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    
    return false;
  }

  /// 尝试修复中文编码问题
  static String fixChineseEncoding(String content) {
    try {
      developer.log('开始尝试修复编码问题，原始内容长度: ${content.length}');
      
      // 方法1: Latin-1到UTF-8的直接转换（最常见的中文乱码问题）
      try {
        List<int> bytes = latin1.encode(content);
        String decodedContent = utf8.decode(bytes, allowMalformed: true);
        
        if (!containsEncodingIssues(decodedContent)) {
          developer.log('Latin-1到UTF-8直接转换成功');
          return decodedContent;
        }
      } catch (e) {
        developer.log('Latin-1到UTF-8转换失败: $e');
      }
      
      // 方法2: 尝试ISO-8859-1到UTF-8的转换
      try {
        // 模拟ISO-8859-1编码，这是一种常见的西欧编码
        // 在Dart中，latin1实际上就是ISO-8859-1的别名
        List<int> bytes = [];
        for (int i = 0; i < content.length; i++) {
          int code = content.codeUnitAt(i);
          if (code <= 0xFF) {
            bytes.add(code);
          } else {
            bytes.add(0x3F); // 添加问号作为替代
          }
        }
        String decodedContent = utf8.decode(bytes, allowMalformed: true);
        
        if (!containsEncodingIssues(decodedContent)) {
          developer.log('ISO-8859-1到UTF-8转换成功');
          return decodedContent;
        }
      } catch (e) {
        developer.log('ISO-8859-1到UTF-8转换失败: $e');
      }
      
      // 方法3: 尝试Windows-1252到UTF-8的转换（常见于Windows系统）
      try {
        // 模拟Windows-1252编码转换
        // 注意：这是一个简化版本，因为Dart没有内置的Windows-1252编码支持
        List<int> bytes = [];
        for (int i = 0; i < content.length; i++) {
          int code = content.codeUnitAt(i);
          // Windows-1252特殊字符映射
          if (code >= 0x80 && code <= 0x9F) {
            // Windows-1252特殊区域映射
            switch (code) {
              case 0x80: bytes.add(0xE2); bytes.add(0x82); bytes.add(0xAC); break; // €
              case 0x82: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x9A); break; // ‚
              case 0x83: bytes.add(0xC6); bytes.add(0x92); break; // ƒ
              case 0x84: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x9E); break; // „
              case 0x85: bytes.add(0xE2); bytes.add(0x80); bytes.add(0xA6); break; // …
              case 0x86: bytes.add(0xE2); bytes.add(0x80); bytes.add(0xA0); break; // †
              case 0x87: bytes.add(0xE2); bytes.add(0x80); bytes.add(0xA1); break; // ‡
              case 0x88: bytes.add(0xCB); bytes.add(0x86); break; // ˆ
              case 0x89: bytes.add(0xE2); bytes.add(0x80); bytes.add(0xB0); break; // ‰
              case 0x8A: bytes.add(0xC5); bytes.add(0xA0); break; // Š
              case 0x8B: bytes.add(0xE2); bytes.add(0x80); bytes.add(0xB9); break; // ‹
              case 0x8C: bytes.add(0xC5); bytes.add(0x92); break; // Œ
              case 0x8E: bytes.add(0xC5); bytes.add(0xBD); break; // Ž
              case 0x91: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x98); break; // '
              case 0x92: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x99); break; // '
              case 0x93: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x9C); break; // "
              case 0x94: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x9D); break; // "
              case 0x95: bytes.add(0xE2); bytes.add(0x80); bytes.add(0xA2); break; // •
              case 0x96: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x93); break; // –
              case 0x97: bytes.add(0xE2); bytes.add(0x80); bytes.add(0x94); break; // —
              case 0x98: bytes.add(0xCB); bytes.add(0x9C); break; // ˜
              case 0x99: bytes.add(0xE2); bytes.add(0x84); bytes.add(0xA2); break; // ™
              case 0x9A: bytes.add(0xC5); bytes.add(0xA1); break; // š
              case 0x9B: bytes.add(0xE2); bytes.add(0x80); bytes.add(0xBA); break; // ›
              case 0x9C: bytes.add(0xC5); bytes.add(0x93); break; // œ
              case 0x9E: bytes.add(0xC5); bytes.add(0xBE); break; // ž
              case 0x9F: bytes.add(0xC5); bytes.add(0xB8); break; // Ÿ
              default: bytes.add(0x3F); break; // 添加问号作为替代
            }
          } else if (code <= 0xFF) {
            bytes.add(code);
          } else {
            bytes.add(0x3F); // 添加问号作为替代
          }
        }
        
        String decodedContent = utf8.decode(bytes, allowMalformed: true);
        
        if (!containsEncodingIssues(decodedContent)) {
          developer.log('Windows-1252到UTF-8转换成功');
          return decodedContent;
        }
      } catch (e) {
        developer.log('Windows-1252到UTF-8转换失败: $e');
      }
      
      // 方法4: 处理Unicode转义序列
      try {
        if (content.contains('\\u') || content.contains('&#')) {
          // 处理Unicode转义序列
          String processed = content;
          // 替换Unicode转义序列 \uXXXX
          RegExp unicodePattern = RegExp(r'\\u([0-9a-fA-F]{4})');
          processed = processed.replaceAllMapped(unicodePattern, (match) {
            try {
              int codePoint = int.parse(match.group(1)!, radix: 16);
              return String.fromCharCode(codePoint);
            } catch (e) {
              return match.group(0)!;
            }
          });
          
          // 替换HTML实体 &#XXXX;
          RegExp htmlEntityPattern = RegExp(r'&#([0-9]+);');
          processed = processed.replaceAllMapped(htmlEntityPattern, (match) {
            try {
              int codePoint = int.parse(match.group(1)!);
              return String.fromCharCode(codePoint);
            } catch (e) {
              return match.group(0)!;
            }
          });
          
          if (!containsEncodingIssues(processed)) {
            developer.log('Unicode转义序列处理成功');
            return processed;
          }
        }
      } catch (e) {
        developer.log('Unicode转义序列处理失败: $e');
      }
      
      // 方法5: 尝试双重编码修复（有时API返回的是双重编码的内容）
      try {
        List<int> bytes = utf8.encode(content);
        String firstDecode = utf8.decode(bytes, allowMalformed: true);
        bytes = utf8.encode(firstDecode);
        String secondDecode = utf8.decode(bytes, allowMalformed: true);
        
        if (!containsEncodingIssues(secondDecode)) {
          developer.log('双重编码修复成功');
          return secondDecode;
        }
      } catch (e) {
        developer.log('双重编码修复失败: $e');
      }
      
      // 如果所有方法都失败，返回原始内容
      developer.log('所有编码修复方法都失败');
      return content;
    } catch (e) {
      developer.log('修复编码错误: $e');
      return content;
    }
  }
  
  /// 清理文本内容，修复可能的乱码问题
  static String cleanTextContent(String text) {
    try {
      // 1. 检查是否有编码问题
      if (containsEncodingIssues(text)) {
        // 尝试修复编码问题
        text = fixChineseEncoding(text);
      }
      
      // 2. 尝试UTF-8解码/编码循环，修复编码问题
      String cleaned = utf8.decode(utf8.encode(text), allowMalformed: true);
      
      // 3. 移除控制字符
      cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
      
      // 4. 替换Unicode替换字符
      cleaned = cleaned.replaceAll(RegExp(r'[\uFFFD]'), '');
      
      // 5. 处理HTML实体
      cleaned = cleaned
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');
      
      // 6. 规范化空白字符
      cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      return cleaned;
    } catch (e) {
      developer.log('清理文本内容时出错: $e');
      return text; // 如果处理失败，返回原始文本
    }
  }
}
