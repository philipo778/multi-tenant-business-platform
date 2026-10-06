import '../models/business_model.dart';
import 'business_local_data_source.dart';

class BusinessLocalDataSourceImpl
    implements BusinessLocalDataSource {
  final List<BusinessModel> _businesses = [
    BusinessModel(
      id: '1',
      name: 'Phililancer Stationery',
      category: 'Retail',
      subCategory: 'Stationery',
      location: 'Dar es Salaam',
      isActive: true,
      enabledModules: [
        'sales',
        'inventory',
        'expenses',
        'debts',
        'reports',
      ],
    ),
    BusinessModel(
      id: '2',
      name: 'Phililancer Mobile Money',
      category: 'Mobile Money',
      subCategory: 'Mobile Money Shop',
      location: 'Dar es Salaam',
      isActive: true,
      enabledModules: [
        'transactions',
        'float',
        'cash',
        'vouchers',
        'reports',
      ],
    ),
    BusinessModel(
      id: '3',
      name: 'Phililancer Lodge',
      category: 'Lodge',
      subCategory: 'Lodge',
      location: 'Dodoma',
      isActive: true,
      enabledModules: [
        'rooms',
        'bookings',
        'expenses',
        'reports',
      ],
    ),
    BusinessModel(
      id: '4',
      name: 'Phililancer Beverage Shop',
      category: 'Beverage',
      subCategory: 'Beverage Shop',
      location: 'Dar es Salaam',
      isActive: false,
      enabledModules: [
        'sales',
        'inventory',
        'expenses',
        'reports',
      ],
    ),
  ];

  @override
  Future<List<BusinessModel>> getBusinesses() async {
    return List.unmodifiable(_businesses);
  }

  @override
  Future<BusinessModel> createBusiness(
      BusinessModel business,
      ) async {
    _businesses.add(business);
    return business;
  }
}