import '../../domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.businessId,
    required super.name,
    required super.category,
    required super.tracksInventory,
    required super.unitPrice,
    required super.costPrice,
    required super.stockQuantity,
    required super.reorderThreshold,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      category: json['category'],
      tracksInventory: json['tracks_inventory'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      stockQuantity: (json['stock_quantity'] as num).toDouble(),
      reorderThreshold:
      (json['reorder_threshold'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'category': category,
      'tracks_inventory': tracksInventory,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'stock_quantity': stockQuantity,
      'reorder_threshold': reorderThreshold,
    };
  }
}