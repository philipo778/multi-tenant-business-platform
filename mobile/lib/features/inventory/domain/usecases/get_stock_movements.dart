import '../entities/stock_movement.dart';
import '../repositories/stock_movement_repository.dart';

class GetStockMovements {
  final StockMovementRepository repository;

  GetStockMovements(this.repository);

  Future<List<StockMovement>> call(
      String businessId,
      ) {
    return repository.getMovements(businessId);
  }
}