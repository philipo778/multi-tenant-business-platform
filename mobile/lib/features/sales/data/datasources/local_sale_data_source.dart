import '../../domain/entities/sale.dart';

class LocalSaleDataSource {
  final List<Sale> _sales = [];

  Future<List<Sale>> getSales(String businessId) async {
    return _sales
        .where((sale) => sale.businessId == businessId)
        .toList();
  }

  Future<Sale> getSaleById(
      String businessId,
      String saleId,
      ) async {
    return _sales.firstWhere(
          (sale) =>
      sale.businessId == businessId &&
          sale.id == saleId,
      orElse: () => throw StateError(
        'Sale not found: $saleId',
      ),
    );
  }

  Future<Sale> createSale(Sale sale) async {
    final alreadyExists = _sales.any(
          (existingSale) =>
      existingSale.businessId == sale.businessId &&
          existingSale.id == sale.id,
    );

    if (alreadyExists) {
      throw StateError(
        'A sale with ID ${sale.id} already exists.',
      );
    }

    _sales.add(sale);
    return sale;
  }

  Future<void> deleteSale(
      String businessId,
      String saleId,
      ) async {
    final index = _sales.indexWhere(
          (sale) =>
      sale.businessId == businessId &&
          sale.id == saleId,
    );

    if (index == -1) {
      throw StateError(
        'Sale not found: $saleId',
      );
    }

    _sales.removeAt(index);
  }
}