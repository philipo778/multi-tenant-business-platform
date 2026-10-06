class BusinessModuleConfig {
  static List<String> defaultModulesFor(String category) {
    switch (category) {
      case 'Retail':
        return [
          'sales',
          'inventory',
          'expenses',
          'debts',
          'reports',
        ];

      case 'Mobile Money':
        return [
          'transactions',
          'float',
          'cash',
          'vouchers',
          'reports',
        ];

      case 'Lodge':
        return [
          'rooms',
          'bookings',
          'expenses',
          'reports',
        ];

      case 'Beverage':
        return [
          'sales',
          'inventory',
          'expenses',
          'reports',
        ];

      case 'Other':
        return [];

      default:
        return [];
    }
  }
}