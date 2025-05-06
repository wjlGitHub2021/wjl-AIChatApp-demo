import 'package:flutter/material.dart';

/// AI模型
class AIModel {
  final String id;
  final String name;
  final String description;
  final String provider;
  final int pointsPerMessage;
  final double rating;
  final String? avatarUrl;
  final Color color;
  final bool isPopular;
  
  AIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.provider,
    required this.pointsPerMessage,
    required this.rating,
    this.avatarUrl,
    required this.color,
    this.isPopular = false,
  });
}

/// 模拟AI模型数据
class AIModels {
  static List<AIModel> items = [
    AIModel(
      id: 'gpt-4',
      name: 'GPT-4',
      description: 'OpenAI的最新大型语言模型，拥有强大的理解和生成能力',
      provider: 'OpenAI',
      pointsPerMessage: 10,
      rating: 4.9,
      color: Colors.green,
      isPopular: true,
    ),
    AIModel(
      id: 'claude',
      name: 'Claude',
      description: 'Anthropic的AI助手，擅长自然对话和创意写作',
      provider: 'Anthropic',
      pointsPerMessage: 8,
      rating: 4.7,
      color: Colors.purple,
    ),
    AIModel(
      id: 'gemini',
      name: 'Gemini',
      description: 'Google的多模态AI模型，支持文本、图像和代码',
      provider: 'Google',
      pointsPerMessage: 5,
      rating: 4.5,
      color: Colors.blue,
    ),
    AIModel(
      id: 'llama',
      name: 'Llama',
      description: 'Meta的开源大型语言模型，性能优秀且资源占用低',
      provider: 'Meta',
      pointsPerMessage: 3,
      rating: 4.2,
      color: Colors.orange,
    ),
  ];
  
  // 根据ID获取AI模型
  static AIModel? getById(String id) {
    try {
      return items.firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }
}
