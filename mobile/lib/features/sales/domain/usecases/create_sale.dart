
import '../entities/sale.dart';
import '../entities/sale_item.dart';
import '../repositories/sale_repository.dart';

import '../../../inventory/domain/entities/item.dart';
import '../../../inventory/domain/entities/stock_movement.dart';
import '../../../inventory/domain/usecases/get_item_by_id.dart';
import '../../../inventory/domain/usecases/update_item.dart';
import '../../../inventory/domain/usecases/create_stock_movement.dart';

class CreateSale {
  final SaleRepository repository;
  final GetItemById getItemById;
  final UpdateItem updateItem;
  final CreateStockMovement createStockMovement;

  CreateSale(
      this.repository,
      this.getItemById,
      this.updateItem,
      this.createStockMovement,
      );

  Future<Sale> call(Sale sale) async {
    if (sale.items.isEmpty) {
      throw ArgumentError('A sale must contain at least one item.');
    }

    if (sale.discount < 0) {
      throw ArgumentError('Discount cannot be negative.');
    }

    // Combine duplicate item lines before validating stock.
    final quantities = <String, double>{};

    for (final line in sale.items) {
      if (!line.quantity.isFinite || line.quantity <= 0) {
        throw ArgumentError(
          'Quantity must be greater than zero for ${line.itemName}.',
        );
      }

      quantities.update(
        line.itemId,
            (quantity) => quantity + line.quantity,
        ifAbsent: () => line.quantity,
      );
    }

    // Load and validate every item before changing any stock.
    final itemsById = <String, Item>{};

    for (final itemId in quantities.keys) {
      final item = await getItemById(sale.businessId, itemId);

      if (item.businessId != sale.businessId) {
        throw StateError(
          'Item $itemId does not belong to this business.',
        );
      }

      final quantity = quantities[itemId]!;

      if (item.tracksInventory &&
          quantity > item.stockQuantity) {
        throw StateError(
          'Insufficient stock for ${item.name}. '
              'Available: ${item.stockQuantity}, requested: $quantity.',
        );
      }

      itemsById[itemId] = item;
    }

    // Build sale lines using current Inventory prices and costs.
    final saleItems = <SaleItem>[];

    for (final entry in quantities.entries) {
      final item = itemsById[entry.key]!;

      saleItems.add(
        SaleItem(
          itemId: item.id,
          itemName: item.name,
          quantity: entry.value,
          unitPrice: item.unitPrice,
          costPrice: item.costPrice,
        ),
      );
    }

    final subtotal = saleItems.fold<double>(
      0,
          (sum, item) => sum + item.subtotal,
    );

    if (sale.discount > subtotal) {
      throw ArgumentError(
        'Discount cannot exceed the sale subtotal.',
      );
    }

    final confirmedSale = Sale(
      id: sale.id,
      businessId: sale.businessId,
      customerName: sale.customerName,
      items: saleItems,
      subtotal: subtotal,
      discount: sale.discount,
      total: subtotal - sale.discount,
      paymentMethod: sale.paymentMethod,
      createdAt: sale.createdAt,
    );

    // Update stock and record movements for tracked items only.
    for (final entry in quantities.entries) {
      final item = itemsById[entry.key]!;

      if (!item.tracksInventory) {
        continue;
      }

      final quantity = entry.value;
      final stockBefore = item.stockQuantity;
      final stockAfter = stockBefore - quantity;

      await updateItem(
        Item(
          id: item.id,
          businessId: item.businessId,
          name: item.name,
          category: item.category,
          tracksInventory: item.tracksInventory,
          unitPrice: item.unitPrice,
          costPrice: item.costPrice,
          stockQuantity: stockAfter,
          reorderThreshold: item.reorderThreshold,
        ),
      );

      await createStockMovement(
        StockMovement(
          id: '${sale.id}_${item.id}_${sale.createdAt.microsecondsSinceEpoch}',
          businessId: sale.businessId,
          itemId: item.id,
          type: 'sale',
          quantity: quantity,
          reason: 'Sale ${sale.id}',
          stockBefore: stockBefore,
          stockAfter: stockAfter,
          createdAt: sale.createdAt,
        ),
      );
    }

    return repository.createSale(confirmedSale);
  }
}