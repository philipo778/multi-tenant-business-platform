import 'package:get_it/get_it.dart';

import '../../features/businesses/data/datasources/business_remote_data_source.dart';
import '../../features/businesses/data/datasources/business_remote_data_source_impl.dart';
import '../../features/businesses/data/repositories/business_repository_impl.dart';
import '../../features/businesses/domain/repositories/business_repository.dart';
import '../../features/businesses/domain/usecases/create_business.dart';
import '../../features/businesses/domain/usecases/delete_business.dart';
import '../../features/businesses/domain/usecases/get_business_by_id.dart';
import '../../features/businesses/domain/usecases/get_businesses.dart';
import '../../features/businesses/domain/usecases/update_business.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<BusinessRemoteDataSource>(
        () => BusinessRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<BusinessRepository>(
        () => BusinessRepositoryImpl(
      getIt<BusinessRemoteDataSource>(),
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
}