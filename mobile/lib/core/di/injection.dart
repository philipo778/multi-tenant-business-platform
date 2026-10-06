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

// Inventory
import '../../features/inventory/data/datasources/item_local_data_source.dart';
import '../../features/inventory/data/datasources/item_local_data_source_impl.dart';
import '../../features/inventory/data/repositories/item_repository_impl.dart';
import '../../features/inventory/domain/repositories/item_repository.dart';
import '../../features/inventory/domain/usecases/create_item.dart';
import '../../features/inventory/domain/usecases/delete_item.dart';
import '../../features/inventory/domain/usecases/get_item_by_id.dart';
import '../../features/inventory/domain/usecases/get_items.dart';
import '../../features/inventory/domain/usecases/update_item.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // =========================
  // Businesses
  // =========================

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

  // =========================
  // Inventory
  // =========================

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
}