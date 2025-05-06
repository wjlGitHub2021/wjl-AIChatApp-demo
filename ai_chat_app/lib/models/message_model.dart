import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class MessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  MessageModel({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // 转换为flutter_chat_types的Message格式
  types.TextMessage toTextMessage() {
    final author = types.User(
      id: isUser ? 'user' : 'ai',
      firstName: isUser ? '用户' : 'AI助手',
    );

    return types.TextMessage(
      author: author,
      createdAt: createdAt.millisecondsSinceEpoch,
      id: id,
      text: text,
    );
  }

  // 从JSON创建MessageModel
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
