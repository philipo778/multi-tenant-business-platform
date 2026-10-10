import '../repositories/sale_repository.dart';

class DeleteSale {
  final SaleRepository repository;

  DeleteSale(this.repository);

  Future<void> call(
      String businessId,
      String saleId,
      ) {
    return repository.deleteSale(
      businessId,
      saleId,
    );
  }
}