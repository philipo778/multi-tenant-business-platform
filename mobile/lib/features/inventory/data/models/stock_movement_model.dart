import '../../domain/entities/stock_movement.dart';

class StockMovementModel extends StockMovement {
  const StockMovementModel({
    required super.id,
    required super.businessId,
    required super.itemId,
    required super.type,
    required super.quantity,
    required super.reason,
    required super.stockBefore,
    required super.stockAfter,
    required super.createdAt,
  });

  factory StockMovementModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StockMovementModel(
      id: json['id'],
      businessId: json['business_id'],
      itemId: json['item_id'],
      type: json['type'],
      quantity: (json['quantity'] as num).toDouble(),
      reason: json['reason'],
      stockBefore: (json['stock_before'] as num).toDouble(),
      stockAfter: (json['stock_after'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'item_id': itemId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'stock_before': stockBefore,
      'stock_after': stockAfter,
      'created_at': createdAt.toIso8601String(),
    };
  }
}