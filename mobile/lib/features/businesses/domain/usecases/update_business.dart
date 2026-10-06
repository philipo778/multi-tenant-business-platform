import '../entities/business.dart';
import '../repositories/business_repository.dart';

class UpdateBusiness {
  final BusinessRepository repository;

  UpdateBusiness(this.repository);

  Future<Business> call(Business business) {
    return repository.updateBusiness(business);
  }
}