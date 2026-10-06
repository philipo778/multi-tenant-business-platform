import '../entities/item.dart';
import '../repositories/item_repository.dart';

class GetItemById {
  final ItemRepository repository;

  GetItemById(this.repository);

  Future<Item> call(
      String businessId,
      String itemId,
      ) {
    return repository.getItemById(
      businessId,
      itemId,
    );
  }
}