import '../models/business_model.dart';
import 'business_remote_data_source.dart';

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  @override
  Future<List<BusinessModel>> getBusinesses() {
    throw UnimplementedError();
  }

  @override
  Future<BusinessModel> getBusinessById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<BusinessModel> createBusiness(BusinessModel business) {
    throw UnimplementedError();
  }

  @override
  Future<BusinessModel> updateBusiness(BusinessModel business) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBusiness(String id) {
    throw UnimplementedError();
  }
}