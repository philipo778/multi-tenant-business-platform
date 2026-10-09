import '../entities/sale.dart';

abstract class SaleRepository {
  Future<List<Sale>> getSales(String businessId);

  Future<Sale> getSaleById(
      String businessId,
      String saleId,
      );

  Future<Sale> createSale(Sale sale);

  Future<void> deleteSale(
      String businessId,
      String saleId,
      );
}