import '../repositories/item_repository.dart';

class DeleteItem {
  final ItemRepository repository;

  DeleteItem(this.repository);

  Future<void> call(
      String businessId,
      String itemId,
      ) {
    return repository.deleteItem(
      businessId,
      itemId,
    );
  }
}