import '../models/business_model.dart';

abstract class BusinessRemoteDataSource {
  Future<List<BusinessModel>> getBusinesses();

  Future<BusinessModel> getBusinessById(String id);

  Future<BusinessModel> createBusiness(BusinessModel business);

  Future<BusinessModel> updateBusiness(BusinessModel business);

  Future<void> deleteBusiness(String id);
}