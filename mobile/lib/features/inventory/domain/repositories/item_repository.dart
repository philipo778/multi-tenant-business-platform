import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getItems(String businessId);

  Future<Item> getItemById(
      String businessId,
      String itemId,
      );

  Future<Item> createItem(Item item);

  Future<Item> updateItem(Item item);

  Future<void> deleteItem(
      String businessId,
      String itemId,
      );
}