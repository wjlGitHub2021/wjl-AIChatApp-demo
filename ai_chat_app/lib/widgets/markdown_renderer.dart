import 'package:flutter/material.dart';
import '../utils/code_formatter.dart';

/// Markdown渲染组件
/// 简单实现，用于渲染基本的Markdown格式
class MarkdownRenderer extends StatelessWidget {
  final String markdown;

  const MarkdownRenderer({
    super.key,
    required this.markdown,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final linkColor = isDarkMode ? Colors.blue[300] : Colors.blue;

    // 解析Markdown
    final List<Widget> widgets = [];

    // 按行分割
    final lines = markdown.split('\n');

    // 当前段落的文本
    String currentParagraph = '';

    // 处理每一行
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 检查是否是标题
      if (line.startsWith('#')) {
        // 如果有未处理的段落，先添加段落
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph, textColor, linkColor));
          currentParagraph = '';
        }

        // 添加标题
        widgets.add(_buildHeading(line, textColor));
        continue;
      }

      // 检查是否是列表项
      if (line.trim().startsWith('- ') || line.trim().startsWith('* ') || RegExp(r'^\d+\.\s').hasMatch(line.trim())) {
        // 如果有未处理的段落，先添加段落
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph, textColor, linkColor));
          currentParagraph = '';
        }

        // 添加列表项
        widgets.add(_buildListItem(line, textColor, linkColor));
        continue;
      }

      // 检查是否是引用
      if (line.trim().startsWith('> ')) {
        // 如果有未处理的段落，先添加段落
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph, textColor, linkColor));
          currentParagraph = '';
        }

        // 添加引用
        widgets.add(_buildBlockquote(line, textColor));
        continue;
      }

      // 检查是否是分隔线
      if (line.trim() == '---' || line.trim() == '***' || line.trim() == '___') {
        // 如果有未处理的段落，先添加段落
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph, textColor, linkColor));
          currentParagraph = '';
        }

        // 添加分隔线
        widgets.add(_buildDivider());
        continue;
      }

      // 检查是否是空行
      if (line.trim().isEmpty) {
        // 如果有未处理的段落，先添加段落
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph, textColor, linkColor));
          currentParagraph = '';
        }
        continue;
      }

      // 普通文本，添加到当前段落
      if (currentParagraph.isNotEmpty) {
        currentParagraph += '\n';
      }
      currentParagraph += line;
    }

    // 处理最后一个段落
    if (currentParagraph.isNotEmpty) {
      widgets.add(_buildParagraph(currentParagraph, textColor, linkColor));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // 构建标题
  Widget _buildHeading(String line, Color textColor) {
    // 计算标题级别
    int level = 0;
    while (level < line.length && line[level] == '#') {
      level++;
    }

    // 提取标题文本
    final text = line.substring(level).trim();

    // 根据级别设置字体大小
    double fontSize;
    FontWeight fontWeight;

    switch (level) {
      case 1:
        fontSize = 24;
        fontWeight = FontWeight.bold;
        break;
      case 2:
        fontSize = 22;
        fontWeight = FontWeight.bold;
        break;
      case 3:
        fontSize = 20;
        fontWeight = FontWeight.bold;
        break;
      case 4:
        fontSize = 18;
        fontWeight = FontWeight.bold;
        break;
      case 5:
        fontSize = 16;
        fontWeight = FontWeight.bold;
        break;
      case 6:
        fontSize = 14;
        fontWeight = FontWeight.bold;
        break;
      default:
        fontSize = 16;
        fontWeight = FontWeight.normal;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }

  // 构建段落
  Widget _buildParagraph(String text, Color textColor, Color? linkColor) {
    // 处理段落中的格式化
    final formattedText = _formatText(text, textColor, linkColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: formattedText,
    );
  }

  // 构建列表项
  Widget _buildListItem(String line, Color textColor, Color? linkColor) {
    String text;
    bool isOrdered = false;

    if (line.trim().startsWith('- ')) {
      text = line.trim().substring(2);
    } else if (line.trim().startsWith('* ')) {
      text = line.trim().substring(2);
    } else {
      // 有序列表
      final match = RegExp(r'^\d+\.\s(.*)$').firstMatch(line.trim());
      if (match != null) {
        text = match.group(1) ?? '';
        isOrdered = true;
      } else {
        text = line.trim();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOrdered ? '• ' : '• ',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _formatText(text, textColor, linkColor),
          ),
        ],
      ),
    );
  }

  // 构建引用
  Widget _buildBlockquote(String line, Color textColor) {
    // 提取引用文本
    final text = line.trim().substring(1).trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 20,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建分隔线
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(),
    );
  }

  // 格式化文本，处理粗体、斜体、链接等
  Widget _formatText(String text, Color textColor, Color? linkColor) {
    // 简单实现，实际应用中可能需要更复杂的解析

    // 处理粗体
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => '<b>${match.group(1)}</b>',
    );

    // 处理斜体
    text = text.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
      (match) => '<i>${match.group(1)}</i>',
    );

    // 处理链接
    text = text.replaceAllMapped(
      RegExp(r'\[(.*?)\]\((.*?)\)'),
      (match) => '<a href="${match.group(2)}">${match.group(1)}</a>',
    );

    // 处理代码
    text = text.replaceAllMapped(
      RegExp(r'`(.*?)`'),
      (match) => '<code>${match.group(1)}</code>',
    );

    // 构建富文本
    final List<TextSpan> spans = [];

    // 分割文本
    final parts = text.split(RegExp(r'(<[^>]+>)'));

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];

      if (part.startsWith('<b>') && part.endsWith('</b>')) {
        // 粗体
        spans.add(TextSpan(
          text: part.substring(3, part.length - 4),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ));
      } else if (part.startsWith('<i>') && part.endsWith('</i>')) {
        // 斜体
        spans.add(TextSpan(
          text: part.substring(3, part.length - 4),
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: textColor,
          ),
        ));
      } else if (part.startsWith('<a href="') && part.contains('">') && part.endsWith('</a>')) {
        // 链接
        final href = part.substring(9, part.indexOf('">'));
        final linkText = part.substring(part.indexOf('">') + 2, part.length - 4);

        spans.add(TextSpan(
          text: linkText,
          style: TextStyle(
            color: linkColor,
            decoration: TextDecoration.underline,
          ),
          // 实际应用中，这里可以添加点击事件
        ));
      } else if (part.startsWith('<code>') && part.endsWith('</code>')) {
        // 代码
        spans.add(TextSpan(
          text: part.substring(6, part.length - 7),
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.withOpacity(0.2),
            color: textColor,
          ),
        ));
      } else {
        // 普通文本
        spans.add(TextSpan(
          text: part,
          style: TextStyle(
            color: textColor,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: textColor,
        ),
        children: spans,
      ),
    );
  }
}
