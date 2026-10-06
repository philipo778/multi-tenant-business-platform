import '../entities/item.dart';
import '../repositories/item_repository.dart';

class CreateItem {
  final ItemRepository repository;

  CreateItem(this.repository);

  Future<Item> call(Item item) {
    return repository.createItem(item);
  }
}