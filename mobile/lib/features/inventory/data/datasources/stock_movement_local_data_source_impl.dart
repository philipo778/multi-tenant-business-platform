import '../models/stock_movement_model.dart';
import 'stock_movement_local_data_source.dart';

class StockMovementLocalDataSourceImpl
    implements StockMovementLocalDataSource {
  final List<StockMovementModel> _movements = [];

  @override
  Future<List<StockMovementModel>> getMovements(
      String businessId,
      ) async {
    return _movements
        .where(
          (movement) =>
      movement.businessId == businessId,
    )
        .toList();
  }

  @override
  Future<List<StockMovementModel>> getItemMovements(
      String businessId,
      String itemId,
      ) async {
    return _movements
        .where(
          (movement) =>
      movement.businessId == businessId &&
          movement.itemId == itemId,
    )
        .toList();
  }

  @override
  Future<StockMovementModel> createMovement(
      StockMovementModel movement,
      ) async {
    _movements.add(movement);

    return movement;
  }
}