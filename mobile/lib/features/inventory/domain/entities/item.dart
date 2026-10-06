class Item {
  final String id;
  final String businessId;
  final String name;
  final String category;
  final bool tracksInventory;
  final double unitPrice;
  final double costPrice;
  final double stockQuantity;
  final double reorderThreshold;

  const Item({
    required this.id,
    required this.businessId,
    required this.name,
    required this.category,
    required this.tracksInventory,
    required this.unitPrice,
    required this.costPrice,
    required this.stockQuantity,
    required this.reorderThreshold,
  });
}