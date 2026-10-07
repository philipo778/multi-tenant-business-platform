import '../entities/stock_movement.dart';
import '../repositories/stock_movement_repository.dart';

class GetItemStockMovements {
  final StockMovementRepository repository;

  GetItemStockMovements(this.repository);

  Future<List<StockMovement>> call(
      String businessId,
      String itemId,
      ) {
    return repository.getItemMovements(
      businessId,
      itemId,
    );
  }
}