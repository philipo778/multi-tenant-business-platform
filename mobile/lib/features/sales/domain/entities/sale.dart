import 'sale_item.dart';

class Sale {
  final String id;
  final String businessId;
  final String? customerName;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod;
  final DateTime createdAt;

  const Sale({
    required this.id,
    required this.businessId,
    this.customerName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
  });

  double get costTotal {
    return items.fold(
      0,
          (total, item) => total + item.costTotal,
    );
  }

  double get grossProfit {
    return total - costTotal;
  }

  int get totalUnitsSold {
    return items.fold(
      0,
          (total, item) => total + item.quantity.toInt(),
    );
  }
}