import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

class GetSaleById {
  final SaleRepository repository;

  GetSaleById(this.repository);

  Future<Sale> call(
      String businessId,
      String saleId,
      ) {
    return repository.getSaleById(
      businessId,
      saleId,
    );
  }
}