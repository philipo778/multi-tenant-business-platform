import '../entities/business.dart';
import '../repositories/business_repository.dart';

class CreateBusiness {
  final BusinessRepository repository;

  CreateBusiness(this.repository);

  Future<Business> call(Business business) {
    return repository.createBusiness(business);
  }
}