import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/business.dart';
import '../widgets/dashboard_module_card.dart';

class BusinessDashboardScreen extends StatelessWidget {
  final Business business;

  const BusinessDashboardScreen({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            business.category,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            business.location,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Business Modules',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),

          const SizedBox(height: 12),

          ...business.enabledModules.map(
                (module) => DashboardModuleCard(
              title: _moduleTitle(module),
              subtitle: _moduleSubtitle(module),
              icon: _moduleIcon(module),
            ),
          ),
        ],
      ),
    );
  }

  String _moduleTitle(String module) {
    switch (module) {
      case 'sales':
        return 'Sales';
      case 'inventory':
        return 'Inventory';
      case 'expenses':
        return 'Expenses';
      case 'debts':
        return 'Debts';
      case 'reports':
        return 'Reports';
      case 'transactions':
        return 'Transactions';
      case 'float':
        return 'Float';
      case 'cash':
        return 'Cash';
      case 'vouchers':
        return 'Vouchers';
      case 'rooms':
        return 'Rooms';
      case 'bookings':
        return 'Bookings';
      default:
        return module;
    }
  }

  String _moduleSubtitle(String module) {
    switch (module) {
      case 'sales':
        return 'Record and monitor sales';
      case 'inventory':
        return 'Manage products and stock';
      case 'expenses':
        return 'Track business expenses';
      case 'debts':
        return 'Manage credit and repayments';
      case 'reports':
        return 'View business performance';
      case 'transactions':
        return 'Track mobile money transactions';
      case 'float':
        return 'Monitor float balances';
      case 'cash':
        return 'Monitor cash operations';
      case 'vouchers':
        return 'Manage voucher stock and profit';
      case 'rooms':
        return 'Manage rooms and occupancy';
      case 'bookings':
        return 'Manage guest bookings';
      default:
        return 'Manage this business module';
    }
  }

  IconData _moduleIcon(String module) {
    switch (module) {
      case 'sales':
        return Icons.point_of_sale;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'expenses':
        return Icons.receipt_long_outlined;
      case 'debts':
        return Icons.account_balance_wallet_outlined;
      case 'reports':
        return Icons.bar_chart_outlined;
      case 'transactions':
        return Icons.swap_horiz;
      case 'float':
        return Icons.account_balance;
      case 'cash':
        return Icons.payments_outlined;
      case 'vouchers':
        return Icons.confirmation_number_outlined;
      case 'rooms':
        return Icons.hotel_outlined;
      case 'bookings':
        return Icons.calendar_month_outlined;
      default:
        return Icons.extension_outlined;
    }
  }
}