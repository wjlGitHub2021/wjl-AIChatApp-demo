import 'package:flutter/material.dart';

/// 代码格式化工具类
/// 用于检测和格式化各种代码和Markdown格式
class CodeFormatter {
  /// 支持的代码语言
  static const List<String> supportedLanguages = [
    'markdown',
    'python',
    'javascript',
    'typescript',
    'java',
    'kotlin',
    'swift',
    'dart',
    'c',
    'cpp',
    'csharp',
    'go',
    'rust',
    'ruby',
    'php',
    'html',
    'css',
    'json',
    'yaml',
    'xml',
    'sql',
    'bash',
    'powershell',
    'plaintext',
  ];

  /// 代码语言图标
  static Map<String, IconData> languageIcons = {
    'markdown': Icons.text_fields,
    'python': Icons.code,
    'javascript': Icons.javascript,
    'typescript': Icons.code,
    'java': Icons.coffee,
    'kotlin': Icons.code,
    'swift': Icons.code,
    'dart': Icons.flutter_dash,
    'c': Icons.code,
    'cpp': Icons.code,
    'csharp': Icons.code,
    'go': Icons.code,
    'rust': Icons.code,
    'ruby': Icons.code,
    'php': Icons.code,
    'html': Icons.html,
    'css': Icons.css,
    'json': Icons.data_object,
    'yaml': Icons.data_object,
    'xml': Icons.code,
    'sql': Icons.storage,
    'bash': Icons.terminal,
    'powershell': Icons.terminal,
    'plaintext': Icons.text_snippet,
  };

  /// 检测代码块语言
  /// 返回检测到的语言和代码内容
  static Map<String, dynamic> detectCodeBlock(String text) {
    // 检查是否包含标准格式的代码块 (```language\ncode```)
    final RegExp standardCodeBlockRegex = RegExp(
      r'```(\w*)\n([\s\S]*?)```',
      multiLine: true,
    );

    final standardMatches = standardCodeBlockRegex.allMatches(text);

    if (standardMatches.isNotEmpty) {
      // 获取第一个代码块
      final match = standardMatches.first;
      String language = match.group(1)?.toLowerCase() ?? '';
      final code = match.group(2) ?? '';

      // 如果没有指定语言或语言不受支持，尝试自动检测
      if (language.isEmpty || !supportedLanguages.contains(language)) {
        language = _detectLanguage(code);
      }

      return {
        'isCodeBlock': true,
        'language': language,
        'code': code,
        'fullMatch': match.group(0) ?? '',
      };
    }

    // 特殊处理：检查是否是冒泡排序代码
    if (text.contains('bubble_sort') ||
        text.contains('冒泡排序') ||
        (text.contains('def ') && text.contains('for ') && text.contains('range(') && text.contains('if '))) {
      return {
        'isCodeBlock': true,
        'language': 'python',
        'code': text,
        'fullMatch': text,
      };
    }

    // 直接检查是否包含Python代码特征（简化版）
    if (text.contains('def ') ||
        text.contains('import ') ||
        text.contains('print(') ||
        (text.contains('for ') && text.contains('in range(')) ||
        text.contains('python') && text.contains('def ')) {
      return {
        'isCodeBlock': true,
        'language': 'python',
        'code': text,
        'fullMatch': text,
      };
    }

    // 检查是否包含其他编程语言特征（简化版）
    if (text.contains('function') ||
        text.contains('const ') ||
        text.contains('let ') ||
        text.contains('var ')) {
      return {
        'isCodeBlock': true,
        'language': 'javascript',
        'code': text,
        'fullMatch': text,
      };
    }

    if (text.contains('public class') ||
        text.contains('System.out.println')) {
      return {
        'isCodeBlock': true,
        'language': 'java',
        'code': text,
        'fullMatch': text,
      };
    }

    if (text.contains('#include') ||
        text.contains('int main')) {
      return {
        'isCodeBlock': true,
        'language': 'cpp',
        'code': text,
        'fullMatch': text,
      };
    }

    // 检查是否包含Markdown格式
    if (_containsMarkdown(text)) {
      return {
        'isCodeBlock': false,
        'language': 'markdown',
        'code': text,
        'fullMatch': text,
      };
    }

    return {
      'isCodeBlock': false,
      'language': 'plaintext',
      'code': text,
      'fullMatch': text,
    };
  }

  /// 检查是否包含Python代码特征
  static bool _containsPythonCode(String text) {
    // 检查Python代码的特征
    final pythonFeatures = [
      r'def\s+\w+\s*\(',  // 函数定义
      r'for\s+\w+\s+in\s+range\(',  // for循环
      r'if\s+__name__\s*==\s*[\'"]__main__[\'"]',  // 主函数检查
      r'print\s*\(',  // print语句
      r'import\s+\w+',  // import语句
      r'class\s+\w+\s*:',  // 类定义
      r'#.*?python',  // Python注释
      r'len\(\w+\)',  // len()函数
      r'bubble_sort',  // 冒泡排序函数名
      r'sorted\(',  // sorted函数
      r'arr\[\w+\]',  // 数组访问
      r'n\s*=\s*len\(',  // 获取数组长度
      r'O\(n\^2\)',  // 时间复杂度
      r'O\(n\)',  // 时间复杂度
      r'O\(1\)',  // 空间复杂度
      r'swapped\s*=\s*(True|False)',  // 布尔值赋值
      r'break',  // break语句
      r'if\s+\w+\s*[><=]=?\s*\w+',  // if条件判断
    ];

    // 如果包含多个Python特征，则认为是Python代码
    int matchCount = 0;
    for (final feature in pythonFeatures) {
      if (RegExp(feature, caseSensitive: false).hasMatch(text)) {
        matchCount++;

        // 如果匹配到2个或以上特征，认为是Python代码
        if (matchCount >= 2) {
          return true;
        }
      }
    }

    // 特殊情况：如果文本中包含"python"和"def"或"for"等关键字，直接判定为Python代码
    if ((text.toLowerCase().contains('python') &&
        (text.contains('def ') || text.contains('for ') || text.contains('import '))) ||
        (text.contains('def ') && text.contains('for ') && text.contains('if '))) {
      return true;
    }

    return false;
  }

  /// 自动检测代码语言
  static String _detectLanguage(String code) {
    // 检查Python代码特征
    if (_containsPythonCode(code)) {
      return 'python';
    }

    // 检查JavaScript代码特征
    if (code.contains('import React') ||
        code.contains('function(') ||
        code.contains('const ') ||
        code.contains('let ') ||
        code.contains('document.getElementById') ||
        code.contains('addEventListener')) {
      return 'javascript';
    }

    // 检查TypeScript代码特征
    if (code.contains('import ') && code.contains('from ') ||
        code.contains('interface ') ||
        code.contains(': string') ||
        code.contains(': number') ||
        code.contains(': boolean')) {
      return 'typescript';
    }

    // 检查Java代码特征
    if (code.contains('public class') ||
        code.contains('private ') ||
        code.contains('protected ') ||
        code.contains('System.out.println') ||
        code.contains('extends ') && code.contains('implements ')) {
      return 'java';
    }

    // 检查Kotlin代码特征
    if (code.contains('fun ') ||
        code.contains('val ') ||
        code.contains('var ') ||
        code.contains('companion object') ||
        code.contains('suspend fun')) {
      return 'kotlin';
    }

    // 检查Swift代码特征
    if (code.contains('func ') ||
        code.contains('let ') ||
        code.contains('var ') ||
        code.contains('UIViewController') ||
        code.contains('import UIKit')) {
      return 'swift';
    }

    // 检查Dart/Flutter代码特征
    if (code.contains('Widget') ||
        code.contains('BuildContext') ||
        code.contains('setState') ||
        code.contains('StatefulWidget') ||
        code.contains('StatelessWidget')) {
      return 'dart';
    }

    // 检查HTML代码特征
    if (code.contains('<html') ||
        code.contains('<!DOCTYPE') ||
        code.contains('<div') ||
        code.contains('<body') ||
        code.contains('<head')) {
      return 'html';
    }

    // 检查JSON代码特征
    if ((code.contains('{') && code.contains('}') && code.contains(':')) ||
        code.trim().startsWith('{') && code.trim().endsWith('}') ||
        code.trim().startsWith('[') && code.trim().endsWith(']')) {
      return 'json';
    }

    // 检查SQL代码特征
    if (code.toUpperCase().contains('SELECT') &&
        code.toUpperCase().contains('FROM') ||
        code.toUpperCase().contains('WHERE') ||
        code.toUpperCase().contains('INSERT INTO') ||
        code.toUpperCase().contains('UPDATE') && code.toUpperCase().contains('SET')) {
      return 'sql';
    }

    // 检查Bash代码特征
    if (code.contains('#!/bin/bash') ||
        code.contains('echo ') ||
        code.contains('chmod ') ||
        code.contains('sudo ') ||
        code.contains('grep ')) {
      return 'bash';
    }

    // 检查C代码特征
    if (code.contains('#include') ||
        code.contains('int main') ||
        code.contains('printf(') ||
        code.contains('scanf(') ||
        code.contains('malloc(')) {
      return 'c';
    }

    // 检查C++代码特征
    if (code.contains('using namespace') ||
        code.contains('std::') ||
        code.contains('cout <<') ||
        code.contains('cin >>') ||
        code.contains('vector<')) {
      return 'cpp';
    }

    // 检查C#代码特征
    if (code.contains('using System') ||
        code.contains('namespace ') ||
        code.contains('Console.WriteLine') ||
        code.contains('public class') && code.contains('void Main')) {
      return 'csharp';
    }

    // 检查Go代码特征
    if (code.contains('package ') ||
        code.contains('func ') ||
        code.contains('import (') ||
        code.contains('fmt.Println') ||
        code.contains('go func')) {
      return 'go';
    }

    // 检查Rust代码特征
    if (code.contains('fn ') ||
        code.contains('let mut') ||
        code.contains('impl ') ||
        code.contains('pub struct') ||
        code.contains('match ')) {
      return 'rust';
    }

    // 检查Ruby代码特征
    if (code.contains('require ') ||
        code.contains('def ') && code.contains('end') ||
        code.contains('puts ') ||
        code.contains('attr_accessor')) {
      return 'ruby';
    }

    // 检查PHP代码特征
    if (code.contains('<?php') ||
        code.contains('function ') && code.contains('$') ||
        code.contains('echo ') ||
        code.contains('$_POST') ||
        code.contains('$_GET')) {
      return 'php';
    }

    // 检查CSS代码特征
    if (code.contains('@media') ||
        code.contains('margin:') ||
        code.contains('padding:') ||
        code.contains('background-color:') ||
        code.contains('font-size:')) {
      return 'css';
    }

    // 检查XML代码特征
    if (code.contains('<?xml') ||
        code.contains('</') && code.contains('<') && !code.contains('<html') ||
        code.contains('xmlns=')) {
      return 'xml';
    }

    // 检查YAML代码特征
    if (code.contains('---') ||
        code.contains('key:') ||
        code.contains('  - ') ||
        code.trim().startsWith('- ') ||
        code.contains(': |')) {
      return 'yaml';
    }

    // 如果没有匹配到任何语言特征，返回纯文本
    return 'plaintext';
  }

  /// 检查是否包含Markdown格式
  static bool _containsMarkdown(String text) {
    // 检查常见的Markdown语法
    final RegExp markdownRegex = RegExp(
      r'(\#{1,6}\s+.+)|(\*\*.+\*\*)|(\*.+\*)|(\[.+\]\(.+\))|(\n\s*[\*\-\+]\s+.+)|(\n\s*\d+\.\s+.+)|(\n\s*>\s+.+)',
      multiLine: true,
    );

    return markdownRegex.hasMatch(text);
  }

  /// 获取语言图标
  static IconData getLanguageIcon(String language) {
    return languageIcons[language] ?? Icons.code;
  }

  /// 获取语言显示名称
  static String getLanguageDisplayName(String language) {
    switch (language) {
      case 'markdown':
        return 'Markdown';
      case 'python':
        return 'Python';
      case 'javascript':
        return 'JavaScript';
      case 'typescript':
        return 'TypeScript';
      case 'java':
        return 'Java';
      case 'kotlin':
        return 'Kotlin';
      case 'swift':
        return 'Swift';
      case 'dart':
        return 'Dart';
      case 'c':
        return 'C';
      case 'cpp':
        return 'C++';
      case 'csharp':
        return 'C#';
      case 'go':
        return 'Go';
      case 'rust':
        return 'Rust';
      case 'ruby':
        return 'Ruby';
      case 'php':
        return 'PHP';
      case 'html':
        return 'HTML';
      case 'css':
        return 'CSS';
      case 'json':
        return 'JSON';
      case 'yaml':
        return 'YAML';
      case 'xml':
        return 'XML';
      case 'sql':
        return 'SQL';
      case 'bash':
        return 'Bash';
      case 'powershell':
        return 'PowerShell';
      case 'plaintext':
        return '纯文本';
      default:
        return language.toUpperCase();
    }
  }
}
