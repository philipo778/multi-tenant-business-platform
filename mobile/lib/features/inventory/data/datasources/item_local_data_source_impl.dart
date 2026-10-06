import '../models/item_model.dart';
import 'item_local_data_source.dart';

class ItemLocalDataSourceImpl
    implements ItemLocalDataSource {
  final List<ItemModel> _items = [];

  @override
  Future<List<ItemModel>> getItems(String businessId) async {
    return _items
        .where((item) => item.businessId == businessId)
        .toList();
  }

  @override
  Future<ItemModel> createItem(ItemModel item) async {
    _items.add(item);
    return item;
  }

  @override
  Future<ItemModel> updateItem(ItemModel item) async {
    final index = _items.indexWhere(
          (existingItem) =>
      existingItem.businessId == item.businessId &&
          existingItem.id == item.id,
    );

    if (index == -1) {
      throw Exception('Item not found');
    }

    _items[index] = item;

    return item;
  }

  @override
  Future<void> deleteItem(
      String businessId,
      String itemId,
      ) async {
    _items.removeWhere(
          (item) =>
      item.businessId == businessId &&
          item.id == itemId,
    );
  }
}