import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/ai_model.dart';

/// AI模型选择器
class AIModelSelector extends StatelessWidget {
  final String currentModelId;
  final Function(String) onModelSelected;

  const AIModelSelector({
    super.key,
    required this.currentModelId,
    required this.onModelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // 0.1*255=25
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择AI模型',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AIModels.items.length,
              itemBuilder: (context, index) {
                final model = AIModels.items[index];
                final isSelected = model.id == currentModelId;

                return _buildModelCard(context, model, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(BuildContext context, AIModel model, bool isSelected) {
    return GestureDetector(
      onTap: () => onModelSelected(model.id),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? model.color.withAlpha(25) // 0.1*255=25
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? model.color
                    : Colors.grey.withAlpha(76), // 0.3*255=76
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: model.color.withAlpha(25), // 0.1*255=25
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology, color: model.color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                model.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? model.color : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppConstants.modelPrices[model.id] ?? AppConstants.pointsPerMessage}点/条',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? model.color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
