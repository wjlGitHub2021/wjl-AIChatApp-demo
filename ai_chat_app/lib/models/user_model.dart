/// 用户模型
class UserModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String email;
  int points; // 付费点数，非final以便可以修改
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? premiumUntil;

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.email,
    this.points = 100, // 默认给100点
    this.isPremium = false,
    DateTime? createdAt,
    this.premiumUntil,
  }) : createdAt = createdAt ?? DateTime.now();

  // 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      email: json['email'],
      points: json['points'],
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      premiumUntil:
          json['premiumUntil'] != null
              ? DateTime.parse(json['premiumUntil'])
              : null,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'email': email,
      'points': points,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'premiumUntil': premiumUntil?.toIso8601String(),
    };
  }

  // 复制用户模型
  UserModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? email,
    int? points,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? premiumUntil,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      points: points ?? this.points,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      premiumUntil: premiumUntil ?? this.premiumUntil,
    );
  }
}

/// 模拟用户数据
class MockUsers {
  static UserModel defaultUser = UserModel(
    id: '1',
    name: '测试用户',
    avatarUrl: null,
    email: 'test@example.com',
    points: 100,
    isPremium: false,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );
}
