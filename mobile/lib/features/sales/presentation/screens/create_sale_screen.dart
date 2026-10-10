
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../../inventory/domain/entities/item.dart';
import '../../../inventory/domain/usecases/get_items.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/usecases/create_sale.dart';

class CreateSaleScreen extends StatefulWidget {
  final Business business;

  const CreateSaleScreen({
    super.key,
    required this.business,
  });

  @override
  State<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');

  late Future<List<Item>> _itemsFuture;

  final Map<String, double> _cart = {};

  String? _selectedItemId;
  String _paymentMethod = 'Cash';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _loadItems() {
    _itemsFuture = getIt<GetItems>()(widget.business.id);
  }

  double _priceOf(Item item) {
    return item.unitPrice;
  }

  double get _subtotal {
    return _cart.entries.fold<double>(0, (sum, entry) {
      final item = _findItem(entry.key);
      if (item == null) return sum;

      return sum + (_priceOf(item) * entry.value);
    });
  }

  double get _discount {
    return double.tryParse(_discountController.text.trim()) ?? 0;
  }

  double get _total => _subtotal - _discount;

  Item? _findItem(String itemId) {
    for (final item in _availableItems) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  List<Item> _availableItems = [];

  void _addItem() {
    final itemId = _selectedItemId;
    final quantity = double.tryParse(_quantityController.text.trim());

    if (itemId == null) {
      _showMessage('Please select a product or service.');
      return;
    }

    if (quantity == null || !quantity.isFinite || quantity <= 0) {
      _showMessage('Enter a valid quantity greater than zero.');
      return;
    }

    final item = _findItem(itemId);

    if (item == null) {
      _showMessage('Selected item could not be found.');
      return;
    }

    final newQuantity = (_cart[itemId] ?? 0) + quantity;

    if (item.tracksInventory && newQuantity > item.stockQuantity) {
      _showMessage(
        'Insufficient stock for ${item.name}. '
            'Available: ${item.stockQuantity}.',
      );
      return;
    }

    setState(() {
      _cart[itemId] = newQuantity;
      _quantityController.text = '1';
    });
  }

  void _changeQuantity(Item item, double change) {
    final currentQuantity = _cart[item.id] ?? 0;
    final newQuantity = currentQuantity + change;

    if (newQuantity <= 0) {
      setState(() => _cart.remove(item.id));
      return;
    }

    if (item.tracksInventory && newQuantity > item.stockQuantity) {
      _showMessage('Not enough stock for ${item.name}.');
      return;
    }

    setState(() => _cart[item.id] = newQuantity);
  }

  void _removeItem(String itemId) {
    setState(() => _cart.remove(itemId));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatAmount(double amount) {
    return 'TZS ${amount.toStringAsFixed(2)}';
  }

  Future<void> _saveSale() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (_cart.isEmpty) {
      _showMessage('Add at least one item to the sale.');
      return;
    }

    if (_discount < 0 || _discount > _subtotal) {
      _showMessage('Discount must be between zero and the subtotal.');
      return;
    }

    final saleId = DateTime.now().microsecondsSinceEpoch.toString();

    final saleItems = _cart.entries.map((entry) {
      final item = _findItem(entry.key)!;

      return SaleItem(
        itemId: item.id,
        itemName: item.name,
        quantity: entry.value,
        unitPrice: item.unitPrice,
        costPrice: item.costPrice,
      );
    }).toList();

    final sale = Sale(
      id: saleId,
      businessId: widget.business.id,
      customerName: _customerController.text.trim().isEmpty
          ? null
          : _customerController.text.trim(),
      items: saleItems,
      subtotal: _subtotal,
      discount: _discount,
      total: _total,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
    );

    setState(() => _isSaving = true);

    try {
      await getIt<CreateSale>()(sale);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: AppTheme.header,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text('Unable to load products and services.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(_loadItems),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          _availableItems = snapshot.data ?? [];

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('Customer'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customerController,
                  decoration: _inputDecoration(
                    label: 'Customer name (optional)',
                    icon: Icons.person_outline,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                _sectionTitle('Add products or services'),
                const SizedBox(height: 8),
                if (_availableItems.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No items found for this business. '
                            'Add products or services in Inventory first.',
                      ),
                    ),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    value: _selectedItemId,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      label: 'Select item',
                      icon: Icons.inventory_2_outlined,
                    ),
                    items: _availableItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(
                          '${item.name} — ${_formatAmount(item.unitPrice)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedItemId = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration(
                            label: 'Quantity',
                            icon: Icons.numbers,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.header,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _sectionTitle('Sale items (${_cart.length})'),
                const SizedBox(height: 8),
                if (_cart.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('Your cart is empty.'),
                      ),
                    ),
                  )
                else
                  ..._cart.entries.map((entry) {
                    final item = _findItem(entry.key);
                    if (item == null) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.header,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove item',
                                  onPressed: () => _removeItem(item.id),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_formatAmount(item.unitPrice)} per unit',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _changeQuantity(item, -1),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                  ),
                                ),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _changeQuantity(item, 1),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatAmount(
                                    item.unitPrice * entry.value,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                _sectionTitle('Payment'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  decoration: _inputDecoration(
                    label: 'Payment method',
                    icon: Icons.payments_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Cash',
                      child: Text('Cash'),
                    ),
                    DropdownMenuItem(
                      value: 'Mobile Money',
                      child: Text('Mobile Money'),
                    ),
                    DropdownMenuItem(
                      value: 'Bank Transfer',
                      child: Text('Bank Transfer'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _paymentMethod = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration(
                    label: 'Discount (TZS)',
                    icon: Icons.discount_outlined,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final discount =
                    double.tryParse((value ?? '').trim());

                    if (discount == null ||
                        !discount.isFinite ||
                        discount < 0) {
                      return 'Enter a valid discount.';
                    }

                    if (discount > _subtotal) {
                      return 'Discount cannot exceed subtotal.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  color: AppTheme.header,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _totalRow('Subtotal', _subtotal),
                        const SizedBox(height: 8),
                        _totalRow('Discount', _discount),
                        const Divider(color: Colors.white30, height: 24),
                        _totalRow(
                          'TOTAL',
                          _total,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSale,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _isSaving ? 'Saving sale...' : 'Complete Sale',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.action,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.header,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
    );
  }

  Widget _totalRow(
      String label,
      double amount, {
        bool isTotal = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 17 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}