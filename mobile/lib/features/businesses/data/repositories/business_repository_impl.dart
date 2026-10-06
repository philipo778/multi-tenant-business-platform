import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_local_data_source.dart';
import '../models/business_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessLocalDataSource localDataSource;

  BusinessRepositoryImpl(this.localDataSource);

  @override
  Future<List<Business>> getBusinesses() {
    return localDataSource.getBusinesses();
  }

  @override
  Future<Business> getBusinessById(String id) async {
    final businesses = await localDataSource.getBusinesses();

    return businesses.firstWhere(
          (business) => business.id == id,
    );
  }

  @override
  Future<Business> createBusiness(Business business) {
    final model = BusinessModel(
      id: business.id,
      name: business.name,
      category: business.category,
      location: business.location,
      isActive: business.isActive,
      enabledModules: business.enabledModules,
    );

    return localDataSource.createBusiness(model);
  }

  @override
  Future<Business> updateBusiness(Business business) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBusiness(String id) async {
    throw UnimplementedError();
  }
}