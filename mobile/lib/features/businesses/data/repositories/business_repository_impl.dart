import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_remote_data_source.dart';
import '../models/business_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessRemoteDataSource remoteDataSource;

  BusinessRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Business>> getBusinesses() {
    return remoteDataSource.getBusinesses();
  }

  @override
  Future<Business> getBusinessById(String id) {
    return remoteDataSource.getBusinessById(id);
  }

  @override
  Future<Business> createBusiness(Business business) {
    final model = BusinessModel(
      id: business.id,
      name: business.name,
      businessType: business.businessType,
      location: business.location,
      isActive: business.isActive,
    );

    return remoteDataSource.createBusiness(model);
  }

  @override
  Future<Business> updateBusiness(Business business) {
    final model = BusinessModel(
      id: business.id,
      name: business.name,
      businessType: business.businessType,
      location: business.location,
      isActive: business.isActive,
    );

    return remoteDataSource.updateBusiness(model);
  }

  @override
  Future<void> deleteBusiness(String id) {
    return remoteDataSource.deleteBusiness(id);
  }
}