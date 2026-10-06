class ItemCategoryConfig {
  static List<String> categoriesFor({
    required String businessCategory,
    required String businessSubCategory,
  }) {
    switch (businessSubCategory) {
      case 'Stationery':
        return [
          'Writing Materials',
          'Paper Products',
          'Exercise Books',
          'Office Supplies',
          'School Supplies',
          'Art Supplies',
          'Other',
        ];

      case 'Grocery':
        return [
          'Food',
          'Household Items',
          'Personal Care',
          'Cleaning Products',
          'Other',
        ];

      case 'Electronics':
        return [
          'Phones',
          'Computer Accessories',
          'Chargers & Cables',
          'Audio',
          'Other',
        ];

      case 'Clothing':
        return [
          'Men',
          'Women',
          'Children',
          'Shoes',
          'Accessories',
          'Other',
        ];

      case 'General Retail':
        return [
          'General Products',
          'Household Items',
          'Personal Care',
          'Other',
        ];

      case 'Beverage Shop':
        return [
          'Soft Drinks',
          'Water',
          'Juice',
          'Energy Drinks',
          'Beer',
          'Other',
        ];

      case 'Mobile Money Shop':
        return [
          'Airtime',
          'Voucher',
          'SIM Card',
          'Mobile Money Service',
          'Other',
        ];

      case 'Lodge':
      case 'Guest House':
      case 'Hotel':
        return [
          'Accommodation',
          'Food',
          'Beverages',
          'Laundry',
          'Other',
        ];

      case 'General Business':
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

  static String nameHintFor({
    required String businessCategory,
    required String businessSubCategory,
  }) {
    switch (businessSubCategory) {
      case 'Stationery':
        return 'e.g. A4 Paper';

      case 'Grocery':
        return 'e.g. Rice 1kg';

      case 'Electronics':
        return 'e.g. USB-C Charger';

      case 'Clothing':
        return 'e.g. Men T-Shirt';

      case 'General Retail':
        return 'e.g. Laundry Basket';

      case 'Beverage Shop':
        return 'e.g. Coca-Cola 500ml';

      case 'Mobile Money Shop':
        return 'e.g. Vodacom Airtime 1000';

      case 'Lodge':
      case 'Guest House':
      case 'Hotel':
        return 'e.g. Room Service';

      default:
        return 'e.g. Business Item';
    }
  }
}