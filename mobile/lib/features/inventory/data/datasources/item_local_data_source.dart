import '../models/item_model.dart';

abstract class ItemLocalDataSource {
  Future<List<ItemModel>> getItems(String businessId);

  Future<ItemModel> createItem(ItemModel item);

  Future<ItemModel> updateItem(ItemModel item);

  Future<void> deleteItem(
      String businessId,
      String itemId,
      );
}