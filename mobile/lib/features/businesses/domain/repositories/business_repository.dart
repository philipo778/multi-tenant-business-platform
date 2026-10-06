import '../entities/business.dart';

abstract class BusinessRepository {
  Future<List<Business>> getBusinesses();

  Future<Business> getBusinessById(String id);

  Future<Business> createBusiness(Business business);

  Future<Business> updateBusiness(Business business);

  Future<void> deleteBusiness(String id);
}