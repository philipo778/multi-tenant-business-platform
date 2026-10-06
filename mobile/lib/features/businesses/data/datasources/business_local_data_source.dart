import '../models/business_model.dart';

abstract class BusinessLocalDataSource {
  Future<List<BusinessModel>> getBusinesses();

  Future<BusinessModel> createBusiness(
      BusinessModel business,
      );
}