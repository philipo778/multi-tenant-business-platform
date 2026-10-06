import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_local_data_source.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemLocalDataSource localDataSource;

  ItemRepositoryImpl(this.localDataSource);

  @override
  Future<List<Item>> getItems(String businessId) {
    return localDataSource.getItems(businessId);
  }

  @override
  Future<Item> getItemById(
      String businessId,
      String itemId,
      ) async {
    final items = await localDataSource.getItems(businessId);

    return items.firstWhere(
          (item) => item.id == itemId,
    );
  }

  @override
  Future<Item> createItem(Item item) {
    final model = ItemModel(
      id: item.id,
      businessId: item.businessId,
      name: item.name,
      category: item.category,
      tracksInventory: item.tracksInventory,
      unitPrice: item.unitPrice,
      costPrice: item.costPrice,
      stockQuantity: item.stockQuantity,
      reorderThreshold: item.reorderThreshold,
    );

    return localDataSource.createItem(model);
  }

  @override
  Future<Item> updateItem(Item item) {
    final model = ItemModel(
      id: item.id,
      businessId: item.businessId,
      name: item.name,
      category: item.category,
      tracksInventory: item.tracksInventory,
      unitPrice: item.unitPrice,
      costPrice: item.costPrice,
      stockQuantity: item.stockQuantity,
      reorderThreshold: item.reorderThreshold,
    );

    return localDataSource.updateItem(model);
  }

  @override
  Future<void> deleteItem(
      String businessId,
      String itemId,
      ) {
    return localDataSource.deleteItem(
      businessId,
      itemId,
    );
  }
}