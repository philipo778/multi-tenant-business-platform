import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

class GetSales {
  final SaleRepository repository;

  GetSales(this.repository);

  Future<List<Sale>> call(String businessId) {
    return repository.getSales(businessId);
  }
}