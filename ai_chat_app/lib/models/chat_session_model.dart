import 'package:uuid/uuid.dart';
import 'message_model.dart';

class ChatSessionModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String aiModel; // 使用的AI模型
  final List<MessageModel> messages;
  final bool isPinned;
  final bool isHidden;
  final String avatarIcon; // 可以是图标名称或图片路径

  ChatSessionModel({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? lastMessageTime,
    this.lastMessage = '',
    this.aiModel = 'default',
    this.messages = const [],
    this.isPinned = false,
    this.isHidden = false,
    this.avatarIcon = 'smart_toy',
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       lastMessageTime = lastMessageTime ?? DateTime.now();

  // 从JSON创建ChatSessionModel
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        json['lastMessageTime'],
      ),
      lastMessage: json['lastMessage'],
      aiModel: json['aiModel'],
      messages:
          (json['messages'] as List?)
              ?.map((m) => MessageModel.fromJson(m))
              .toList() ??
          [],
      isPinned: json['isPinned'] ?? false,
      isHidden: json['isHidden'] ?? false,
      avatarIcon: json['avatarIcon'] ?? 'smart_toy',
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'aiModel': aiModel,
      'messages': messages.map((m) => m.toJson()).toList(),
      'isPinned': isPinned,
      'isHidden': isHidden,
      'avatarIcon': avatarIcon,
    };
  }

  // 创建一个新的实例，但更新某些属性
  ChatSessionModel copyWith({
    String? title,
    DateTime? lastMessageTime,
    String? lastMessage,
    String? aiModel,
    List<MessageModel>? messages,
    bool? isPinned,
    bool? isHidden,
    String? avatarIcon,
  }) {
    return ChatSessionModel(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      aiModel: aiModel ?? this.aiModel,
      messages: messages ?? this.messages,
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
      avatarIcon: avatarIcon ?? this.avatarIcon,
    );
  }
}
