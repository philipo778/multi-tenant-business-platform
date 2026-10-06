class ItemCategoryConfig {
  static List<String> categoriesFor(String businessCategory) {
    switch (businessCategory) {
      case 'Retail':
        return [
          'Stationery',
          'School Supplies',
          'Office Supplies',
          'Electronics',
          'Food',
          'Other',
        ];

      case 'Beverage':
        return [
          'Soft Drinks',
          'Water',
          'Juice',
          'Energy Drinks',
          'Beer',
          'Other',
        ];

      case 'Mobile Money':
        return [
          'Airtime',
          'Voucher',
          'SIM Card',
          'Service',
          'Other',
        ];

      case 'Lodge':
        return [
          'Accommodation',
          'Food',
          'Beverages',
          'Laundry',
          'Other',
        ];

      case 'Other':
        return [
          'General',
          'Service',
          'Other',
        ];

      default:
        return [
          'General',
          'Other',
        ];
    }
  }

  static String nameHintFor(String businessCategory) {
    switch (businessCategory) {
      case 'Retail':
        return 'e.g. A4 Paper';

      case 'Beverage':
        return 'e.g. Coca-Cola 500ml';

      case 'Mobile Money':
        return 'e.g. Vodacom Airtime 1000';

      case 'Lodge':
        return 'e.g. Room 101 Service';

      default:
        return 'e.g. Business Item';
    }
  }
}