class AIModelInfo {
  final String id;
  final String name;
  final String description;
  final int costPerMessage; // 每条消息的点数消耗
  final Map<String, double> ratings; // 各项能力的星级评分（满分5星）
  final String iconName;
  final bool isPremium;

  AIModelInfo({
    required this.id,
    required this.name,
    required this.description,
    this.costPerMessage = 10,
    required this.ratings,
    required this.iconName,
    this.isPremium = false,
  });

  // 获取平均评分
  double get averageRating {
    if (ratings.isEmpty) return 0;
    double sum = 0;
    ratings.forEach((key, value) {
      sum += value;
    });
    return sum / ratings.length;
  }

  // 预定义的AI模型列表
  static List<AIModelInfo> get predefinedModels {
    return [
      AIModelInfo(
        id: 'gemini',
        name: 'Google Gemini',
        description: 'Gemini 2.5 Pro Experimental (free)',
        costPerMessage: 0,
        ratings: {
          '知识广度': 5.0,
          '推理能力': 5.0,
          '创意水平': 4.8,
          '指令遵循': 4.9,
          '代码能力': 4.8,
          '图像理解': 5.0,
        },
        iconName: 'diamond',
      ),
      AIModelInfo(
        id: 'deepseek',
        name: 'DeepSeek',
        description: 'DeepSeek V3 0324 (free)',
        costPerMessage: 0,
        ratings: {
          '知识广度': 4.7,
          '推理能力': 4.8,
          '创意水平': 4.5,
          '指令遵循': 4.6,
          '代码能力': 4.9,
        },
        iconName: 'psychology',
      ),
      AIModelInfo(
        id: 'shisa',
        name: 'Shisa AI',
        description: 'Shisa V2 Llama 3.3 70B (free)',
        costPerMessage: 0,
        ratings: {
          '知识广度': 4.6,
          '推理能力': 4.7,
          '创意水平': 4.5,
          '指令遵循': 4.8,
          '代码能力': 4.6,
        },
        iconName: 'smart_toy',
      ),
    ];
  }

  // 根据ID获取模型信息
  static AIModelInfo getModelById(String id) {
    return predefinedModels.firstWhere(
      (model) => model.id == id,
      orElse: () => predefinedModels[1], // 默认返回GPT-3.5
    );
  }
}
