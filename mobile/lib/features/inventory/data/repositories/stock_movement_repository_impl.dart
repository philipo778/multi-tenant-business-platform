import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_movement_repository.dart';
import '../datasources/stock_movement_local_data_source.dart';
import '../models/stock_movement_model.dart';

class StockMovementRepositoryImpl
    implements StockMovementRepository {
  final StockMovementLocalDataSource localDataSource;

  StockMovementRepositoryImpl(this.localDataSource);

  @override
  Future<List<StockMovement>> getMovements(
      String businessId,
      ) async {
    return localDataSource.getMovements(businessId);
  }

  @override
  Future<List<StockMovement>> getItemMovements(
      String businessId,
      String itemId,
      ) async {
    return localDataSource.getItemMovements(
      businessId,
      itemId,
    );
  }

  @override
  Future<StockMovement> createMovement(
      StockMovement movement,
      ) async {
    final model = StockMovementModel(
      id: movement.id,
      businessId: movement.businessId,
      itemId: movement.itemId,
      type: movement.type,
      quantity: movement.quantity,
      reason: movement.reason,
      stockBefore: movement.stockBefore,
      stockAfter: movement.stockAfter,
      createdAt: movement.createdAt,
    );

    return localDataSource.createMovement(model);
  }
}