import 'package:intl/intl.dart';

/// 格式化工具类
class FormatUtils {
  // 格式化日期时间
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // 今天
      return 'HH:mm'.format(dateTime);
    } else if (difference.inDays == 1) {
      // 昨天
      return '昨天 HH:mm'.format(dateTime);
    } else if (difference.inDays < 7) {
      // 一周内
      return '${_getWeekdayName(dateTime.weekday)} HH:mm'.format(dateTime);
    } else if (dateTime.year == now.year) {
      // 今年
      return 'MM-dd HH:mm'.format(dateTime);
    } else {
      // 往年
      return 'yyyy-MM-dd HH:mm'.format(dateTime);
    }
  }

  // 格式化消息时间
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays == 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return _getWeekdayName(dateTime.weekday);
    } else if (dateTime.year == now.year) {
      return 'MM-dd'.format(dateTime);
    } else {
      return 'yyyy-MM-dd'.format(dateTime);
    }
  }

  // 格式化价格
  static String formatPrice(double price) {
    return '¥${price.toStringAsFixed(2)}';
  }

  // 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // 获取星期几名称
  static String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return '星期一';
      case 2:
        return '星期二';
      case 3:
        return '星期三';
      case 4:
        return '星期四';
      case 5:
        return '星期五';
      case 6:
        return '星期六';
      case 7:
        return '星期日';
      default:
        return '';
    }
  }
}

// 扩展String类，添加format方法
extension StringFormatExtension on String {
  String format(DateTime dateTime) {
    return DateFormat(this).format(dateTime);
  }
}
