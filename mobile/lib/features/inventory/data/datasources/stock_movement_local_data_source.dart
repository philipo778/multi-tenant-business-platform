import '../models/stock_movement_model.dart';

abstract class StockMovementLocalDataSource {
  Future<List<StockMovementModel>> getMovements(
      String businessId,
      );

  Future<List<StockMovementModel>> getItemMovements(
      String businessId,
      String itemId,
      );

  Future<StockMovementModel> createMovement(
      StockMovementModel movement,
      );
}