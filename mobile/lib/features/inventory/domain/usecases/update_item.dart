import '../entities/item.dart';
import '../repositories/item_repository.dart';

class UpdateItem {
  final ItemRepository repository;

  UpdateItem(this.repository);

  Future<Item> call(Item item) {
    return repository.updateItem(item);
  }
}