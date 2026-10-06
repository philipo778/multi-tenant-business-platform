import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required super.id,
    required super.name,
    required super.category,
    required super.subCategory,
    required super.location,
    required super.isActive,
    required super.enabledModules,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      subCategory: json['sub_category'],
      location: json['location'],
      isActive: json['is_active'],
      enabledModules: List<String>.from(
        json['enabled_modules'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sub_category': subCategory,
      'location': location,
      'is_active': isActive,
      'enabled_modules': enabledModules,
    };
  }
}