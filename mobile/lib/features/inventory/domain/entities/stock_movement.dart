class StockMovement {
  final String id;
  final String businessId;
  final String itemId;
  final String type;
  final double quantity;
  final String reason;
  final double stockBefore;
  final double stockAfter;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.businessId,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.stockBefore,
    required this.stockAfter,
    required this.createdAt,
  });
}