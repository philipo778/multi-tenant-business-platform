
import 'package:get_it/get_it.dart';

// Businesses
import '../../features/businesses/data/datasources/business_local_data_source.dart';
import '../../features/businesses/data/datasources/business_local_data_source_impl.dart';
import '../../features/businesses/data/repositories/business_repository_impl.dart';
import '../../features/businesses/domain/repositories/business_repository.dart';
import '../../features/businesses/domain/usecases/create_business.dart';
import '../../features/businesses/domain/usecases/delete_business.dart';
import '../../features/businesses/domain/usecases/get_business_by_id.dart';
import '../../features/businesses/domain/usecases/get_businesses.dart';
import '../../features/businesses/domain/usecases/update_business.dart';

// Inventory - Items
import '../../features/inventory/data/datasources/item_local_data_source.dart';
import '../../features/inventory/data/datasources/item_local_data_source_impl.dart';
import '../../features/inventory/data/repositories/item_repository_impl.dart';
import '../../features/inventory/domain/repositories/item_repository.dart';
import '../../features/inventory/domain/usecases/create_item.dart';
import '../../features/inventory/domain/usecases/delete_item.dart';
import '../../features/inventory/domain/usecases/get_item_by_id.dart';
import '../../features/inventory/domain/usecases/get_items.dart';
import '../../features/inventory/domain/usecases/update_item.dart';

// Inventory - Stock Movements
import '../../features/inventory/data/datasources/stock_movement_local_data_source.dart';
import '../../features/inventory/data/datasources/stock_movement_local_data_source_impl.dart';
import '../../features/inventory/data/repositories/stock_movement_repository_impl.dart';
import '../../features/inventory/domain/repositories/stock_movement_repository.dart';
import '../../features/inventory/domain/usecases/create_stock_movement.dart';
import '../../features/inventory/domain/usecases/get_item_stock_movements.dart';
import '../../features/inventory/domain/usecases/get_stock_movements.dart';

// Sales
import '../../features/sales/data/datasources/local_sale_data_source.dart';
import '../../features/sales/data/repositories/sale_repository_impl.dart';
import '../../features/sales/domain/repositories/sale_repository.dart';
import '../../features/sales/domain/usecases/create_sale.dart';
import '../../features/sales/domain/usecases/delete_sale.dart';
import '../../features/sales/domain/usecases/get_sale_by_id.dart';
import '../../features/sales/domain/usecases/get_sales.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // ============================================================
  // BUSINESSES
  // ============================================================

  getIt.registerLazySingleton<BusinessLocalDataSource>(
        () => BusinessLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<BusinessRepository>(
        () => BusinessRepositoryImpl(
      getIt<BusinessLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetBusinesses>(
        () => GetBusinesses(
      getIt<BusinessRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetBusinessById>(
        () => GetBusinessById(
      getIt<BusinessRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateBusiness>(
        () => CreateBusiness(
      getIt<BusinessRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateBusiness>(
        () => UpdateBusiness(
      getIt<BusinessRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteBusiness>(
        () => DeleteBusiness(
      getIt<BusinessRepository>(),
    ),
  );

  // ============================================================
  // INVENTORY - ITEMS
  // ============================================================

  getIt.registerLazySingleton<ItemLocalDataSource>(
        () => ItemLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<ItemRepository>(
        () => ItemRepositoryImpl(
      getIt<ItemLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetItems>(
        () => GetItems(
      getIt<ItemRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetItemById>(
        () => GetItemById(
      getIt<ItemRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateItem>(
        () => CreateItem(
      getIt<ItemRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateItem>(
        () => UpdateItem(
      getIt<ItemRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteItem>(
        () => DeleteItem(
      getIt<ItemRepository>(),
    ),
  );

  // ============================================================
  // INVENTORY - STOCK MOVEMENTS
  // ============================================================

  getIt.registerLazySingleton<StockMovementLocalDataSource>(
        () => StockMovementLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<StockMovementRepository>(
        () => StockMovementRepositoryImpl(
      getIt<StockMovementLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CreateStockMovement>(
        () => CreateStockMovement(
      getIt<StockMovementRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetStockMovements>(
        () => GetStockMovements(
      getIt<StockMovementRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetItemStockMovements>(
        () => GetItemStockMovements(
      getIt<StockMovementRepository>(),
    ),
  );

  // ============================================================
  // SALES
  // ============================================================

  getIt.registerLazySingleton<LocalSaleDataSource>(
        () => LocalSaleDataSource(),
  );

  getIt.registerLazySingleton<SaleRepository>(
        () => SaleRepositoryImpl(
      getIt<LocalSaleDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetSales>(
        () => GetSales(
      getIt<SaleRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetSaleById>(
        () => GetSaleById(
      getIt<SaleRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateSale>(
        () => CreateSale(
      getIt<SaleRepository>(),
      getIt<GetItemById>(),
      getIt<UpdateItem>(),
      getIt<CreateStockMovement>(),
    ),
  );

  getIt.registerLazySingleton<DeleteSale>(
        () => DeleteSale(
      getIt<SaleRepository>(),
    ),
  );
}