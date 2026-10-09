import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../datasources/local_sale_data_source.dart';

class SaleRepositoryImpl implements SaleRepository {
  final LocalSaleDataSource dataSource;

  SaleRepositoryImpl(this.dataSource);

  @override
  Future<List<Sale>> getSales(String businessId) {
    return dataSource.getSales(businessId);
  }

  @override
  Future<Sale> getSaleById(
      String businessId,
      String saleId,
      ) {
    return dataSource.getSaleById(
      businessId,
      saleId,
    );
  }

  @override
  Future<Sale> createSale(Sale sale) {
    return dataSource.createSale(sale);
  }

  @override
  Future<void> deleteSale(
      String businessId,
      String saleId,
      ) {
    return dataSource.deleteSale(
      businessId,
      saleId,
    );
  }
}