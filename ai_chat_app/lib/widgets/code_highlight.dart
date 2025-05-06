import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../utils/code_formatter.dart';

/// 代码高亮显示组件
class CodeHighlight extends StatefulWidget {
  final String code;
  final String language;
  final bool showLanguageLabel;

  const CodeHighlight({
    super.key,
    required this.code,
    required this.language,
    this.showLanguageLabel = true,
  });

  @override
  State<CodeHighlight> createState() => _CodeHighlightState();
}

class _CodeHighlightState extends State<CodeHighlight> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final textColor = isDarkMode ? Colors.grey[300]! : Colors.grey[800]!;
    final headerColor = isDarkMode ? const Color(0xFF333333) : const Color(0xFFEAEAEA);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 语言标签和操作按钮
          if (widget.showLanguageLabel)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
                border: Border(
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 语言标签
                  Text(
                    widget.language,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  // 操作按钮
                  Row(
                    children: [
                      // 复制按钮
                      _buildActionButton(
                        icon: Icons.copy_outlined,
                        label: 'Copy',
                        onTap: _copyToClipboard,
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(width: 8),

                      // 下载按钮
                      _buildActionButton(
                        icon: Icons.download_outlined,
                        label: 'Download',
                        onTap: _downloadCode,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 代码内容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: _buildSyntaxHighlightedCode(textColor, isDarkMode),
          ),
        ],
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 构建语法高亮代码
  Widget _buildSyntaxHighlightedCode(Color textColor, bool isDarkMode) {
    // 根据语言应用不同的语法高亮
    if (widget.language == 'python') {
      return _buildPythonHighlightedCode(textColor, isDarkMode);
    } else {
      // 默认代码显示
      return SelectableText(
        widget.code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.5,
          color: textColor,
        ),
      );
    }
  }

  // Python语法高亮
  Widget _buildPythonHighlightedCode(Color textColor, bool isDarkMode) {
    // 关键字颜色
    final keywordColor = isDarkMode ? Colors.orange[300]! : Colors.orange[700]!;
    // 字符串颜色
    final stringColor = isDarkMode ? Colors.green[300]! : Colors.green[700]!;
    // 注释颜色
    final commentColor = isDarkMode ? Colors.grey[500]! : Colors.grey[600]!;
    // 数字颜色
    final numberColor = isDarkMode ? Colors.blue[300]! : Colors.blue[700]!;

    // 分割代码行
    final lines = widget.code.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // 处理注释行
        if (line.trim().startsWith('#')) {
          return SelectableText(
            line,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.5,
              color: commentColor,
            ),
          );
        }

        // 处理普通代码行
        final spans = <TextSpan>[];

        // 简单的Python语法高亮规则
        final regex = RegExp(
          r'(def|for|in|if|return|print|range|import|class|while|else|elif|try|except|finally|with|as|from|global|nonlocal|lambda|and|or|not|is|None|True|False)\b|(\d+)|("#.*?"|\'.*?\')|(\w+)|(\s+)|(#.*$)',
          multiLine: true,
        );

        final matches = regex.allMatches(line);

        for (final match in matches) {
          if (match.group(1) != null) {
            // 关键字
            spans.add(TextSpan(
              text: match.group(0),
              style: TextStyle(color: keywordColor, fontWeight: FontWeight.bold),
            ));
          } else if (match.group(2) != null) {
            // 数字
            spans.add(TextSpan(
              text: match.group(0),
              style: TextStyle(color: numberColor),
            ));
          } else if (match.group(3) != null) {
            // 字符串
            spans.add(TextSpan(
              text: match.group(0),
              style: TextStyle(color: stringColor),
            ));
          } else if (match.group(6) != null) {
            // 注释
            spans.add(TextSpan(
              text: match.group(0),
              style: TextStyle(color: commentColor, fontStyle: FontStyle.italic),
            ));
          } else {
            // 其他（变量、空格等）
            spans.add(TextSpan(
              text: match.group(0),
              style: TextStyle(color: textColor),
            ));
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: SelectableText.rich(
            TextSpan(
              children: spans,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _isCopied = true;
    });

    // 2秒后重置状态
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });

    // 显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('代码已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 下载代码文件
  void _downloadCode() {
    // 根据语言确定文件扩展名
    String extension = '.txt';
    switch (widget.language) {
      case 'python':
        extension = '.py';
        break;
      case 'javascript':
        extension = '.js';
        break;
      case 'typescript':
        extension = '.ts';
        break;
      case 'java':
        extension = '.java';
        break;
      case 'dart':
        extension = '.dart';
        break;
      case 'html':
        extension = '.html';
        break;
      case 'css':
        extension = '.css';
        break;
      case 'json':
        extension = '.json';
        break;
      case 'markdown':
        extension = '.md';
        break;
    }

    // 创建文件名
    final fileName = 'code${extension}';

    // 创建Blob对象
    final blob = html.Blob([widget.code], 'text/plain');

    // 创建下载链接
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    // 添加到DOM并触发点击
    html.document.body!.children.add(anchor);
    anchor.click();

    // 清理
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    // 显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('代码已下载为 $fileName'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
