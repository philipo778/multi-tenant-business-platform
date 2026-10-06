import '../models/business_model.dart';
import 'business_local_data_source.dart';

class BusinessLocalDataSourceImpl
    implements BusinessLocalDataSource {
  final List<BusinessModel> _businesses = [];

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    return List.unmodifiable(_businesses);
  }

  @override
  Future<BusinessModel> createBusiness(
      BusinessModel business,
      ) async {
    _businesses.add(business);

    return business;
  }
}