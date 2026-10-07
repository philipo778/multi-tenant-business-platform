import '../entities/stock_movement.dart';
import '../repositories/stock_movement_repository.dart';

class CreateStockMovement {
  final StockMovementRepository repository;

  CreateStockMovement(this.repository);

  Future<StockMovement> call(
      StockMovement movement,
      ) {
    return repository.createMovement(movement);
  }
}