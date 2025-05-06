import 'package:flutter/material.dart';

/// 商品类型
enum ProductType {
  points,    // 点数
  premium,   // 会员
  feature,   // 功能
  theme,     // 主题
}

/// 商品模型
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final ProductType type;
  final int? points;
  final bool isPopular;
  final Color color;
  final DateTime? validUntil;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.type,
    this.points,
    this.isPopular = false,
    required this.color,
    this.validUntil,
  });
}

/// 模拟商品数据
class Products {
  static List<ProductModel> items = [
    // 点数商品
    ProductModel(
      id: 'points_1',
      name: '100点数',
      description: '购买100点数，可用于AI对话',
      price: 6.0,
      type: ProductType.points,
      points: 100,
      color: Colors.blue,
    ),
    ProductModel(
      id: 'points_2',
      name: '500点数',
      description: '购买500点数，可用于AI对话',
      price: 25.0,
      originalPrice: 30.0,
      type: ProductType.points,
      points: 500,
      isPopular: true,
      color: Colors.green,
    ),
    ProductModel(
      id: 'points_3',
      name: '1000点数',
      description: '购买1000点数，可用于AI对话',
      price: 45.0,
      originalPrice: 60.0,
      type: ProductType.points,
      points: 1000,
      color: Colors.purple,
    ),
    
    // 会员商品
    ProductModel(
      id: 'premium_1',
      name: '月度会员',
      description: '每天赠送50点数，所有AI模型半价使用',
      price: 28.0,
      type: ProductType.premium,
      color: Colors.orange,
      validUntil: DateTime.now().add(const Duration(days: 30)),
    ),
    ProductModel(
      id: 'premium_2',
      name: '年度会员',
      description: '每天赠送100点数，所有AI模型半价使用',
      price: 198.0,
      originalPrice: 336.0,
      type: ProductType.premium,
      isPopular: true,
      color: Colors.red,
      validUntil: DateTime.now().add(const Duration(days: 365)),
    ),
    
    // 功能商品
    ProductModel(
      id: 'feature_1',
      name: '语音转文字',
      description: '将语音转换为文字，支持多种语言',
      price: 18.0,
      type: ProductType.feature,
      color: Colors.teal,
    ),
    ProductModel(
      id: 'feature_2',
      name: '图像识别',
      description: '识别图像中的物体、场景和文字',
      price: 28.0,
      type: ProductType.feature,
      color: Colors.indigo,
    ),
    
    // 主题商品
    ProductModel(
      id: 'theme_1',
      name: '暗夜主题',
      description: '深色系主题，保护眼睛',
      price: 12.0,
      type: ProductType.theme,
      color: Colors.blueGrey,
    ),
    ProductModel(
      id: 'theme_2',
      name: '森林主题',
      description: '绿色系主题，清新自然',
      price: 12.0,
      type: ProductType.theme,
      color: Colors.lightGreen,
    ),
  ];
}
