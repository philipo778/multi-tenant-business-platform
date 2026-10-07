import '../entities/stock_movement.dart';

abstract class StockMovementRepository {
  Future<List<StockMovement>> getMovements(String businessId);

  Future<List<StockMovement>> getItemMovements(
      String businessId,
      String itemId,
      );

  Future<StockMovement> createMovement(
      StockMovement movement,
      );
}