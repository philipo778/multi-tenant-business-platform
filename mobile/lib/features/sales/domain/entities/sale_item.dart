class SaleItem {
  final String itemId;
  final String itemName;
  final double quantity;
  final double unitPrice;
  final double costPrice;

  const SaleItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
  });

  double get subtotal {
    return quantity * unitPrice;
  }

  double get costTotal {
    return quantity * costPrice;
  }

  double get profit {
    return subtotal - costTotal;
  }
}