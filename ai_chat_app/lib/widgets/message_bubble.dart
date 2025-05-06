import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:html' as html;
import '../constants/colors.dart';
import '../models/message_model.dart';
import '../utils/format_utils.dart';

/// 消息气泡
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isUser;

  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(isDarkMode),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildBubble(context, isDarkMode),
                const SizedBox(height: 4),
                _buildTimestamp(isDarkMode),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDarkMode) {
    if (isUser) {
      return const CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, color: Colors.white, size: 16),
      );
    } else {
      return const CircleAvatar(
        radius: 16,
        backgroundColor: Colors.blue,
        child: Icon(Icons.psychology, color: Colors.white, size: 16),
      );
    }
  }

  Widget _buildBubble(BuildContext context, bool isDarkMode) {
    final bubbleColor =
        isUser
            ? isDarkMode
                ? AppColors.darkUserBubble
                : AppColors.userBubble
            : isDarkMode
            ? AppColors.darkAiBubble
            : AppColors.aiBubble;

    final textColor =
        isUser
            ? Colors.white
            : isDarkMode
            ? Colors.white
            : Colors.black;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft:
              isUser ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight:
              isUser ? const Radius.circular(4) : const Radius.circular(16),
        ),
      ),
      child: _buildMessageContent(context, textColor, isDarkMode),
    );
  }

  Widget _buildMessageContent(
    BuildContext context,
    Color textColor,
    bool isDarkMode,
  ) {
    // 对于所有AI回复，使用Markdown渲染
    if (!isUser) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 如果包含代码块，添加复制和下载按钮
          if (_containsCodeBlock(message.text))
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: textColor.withAlpha(179),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _copyCode(context),
                  tooltip: '复制代码',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.download_outlined, size: 18),
                  color: textColor.withAlpha(179),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _downloadCode(context),
                  tooltip: '下载代码',
                ),
              ],
            ),

          if (_containsCodeBlock(message.text)) const SizedBox(height: 8),

          // 使用Markdown渲染器显示内容
          MarkdownBody(
            data: message.text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              // 段落文本样式
              p: TextStyle(color: textColor, fontSize: 16, height: 1.4),
              // 行内代码样式
              code: TextStyle(
                backgroundColor: Colors.transparent,
                color: isDarkMode ? Colors.orange[300] : Colors.orange[700],
                fontFamily: 'monospace',
              ),
              // 代码块样式
              codeblockDecoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
              codeblockPadding: const EdgeInsets.all(16),
              // 其他Markdown样式
              blockSpacing: 16,
              listIndent: 24,
              h1: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              h2: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              h3: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              h4: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              h5: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              h6: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
              strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              blockquote: TextStyle(
                color: textColor.withAlpha(204),
                fontStyle: FontStyle.italic,
              ),
              blockquoteDecoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.grey[800]!.withAlpha(51)
                        : Colors.grey[200]!,
                borderRadius: BorderRadius.circular(4),
                border: Border(
                  left: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                    width: 4,
                  ),
                ),
              ),
              blockquotePadding: const EdgeInsets.all(8),
            ),
          ),
        ],
      );
    } else {
      // 用户消息，使用普通文本
      return SelectableText(
        message.text,
        style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
      );
    }
  }

  // 检查消息是否包含代码块
  bool _containsCodeBlock(String text) {
    return RegExp(r'```[a-z]*\n[\s\S]*?```').hasMatch(text) ||
        (text.contains('def ') &&
            text.contains('for ') &&
            text.contains('if ')) ||
        text.contains('bubble_sort') ||
        text.contains('冒泡排序');
  }

  // 复制代码
  void _copyCode(BuildContext context) {
    // 尝试提取代码块
    final match = RegExp(r'```[a-z]*\n([\s\S]*?)```').firstMatch(message.text);
    final code = match?.group(1) ?? message.text;

    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('代码已复制到剪贴板'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 下载代码
  void _downloadCode(BuildContext context) {
    // 尝试提取代码块
    final match = RegExp(
      r'```([a-z]*)\n([\s\S]*?)```',
    ).firstMatch(message.text);
    final language = match?.group(1) ?? 'python';
    final code = match?.group(2) ?? message.text;

    // 根据语言确定文件扩展名
    String extension = '.txt';
    switch (language) {
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
    final fileName = 'code$extension';

    // 创建Blob对象
    final blob = html.Blob([code], 'text/plain');

    // 创建下载链接
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';

    // 添加到DOM并触发点击
    html.document.body!.children.add(anchor);
    anchor.click();

    // 清理
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('代码已下载为 $fileName'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildTimestamp(bool isDarkMode) {
    return Text(
      FormatUtils.formatDateTime(message.createdAt),
      style: TextStyle(
        fontSize: 12,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }
}
