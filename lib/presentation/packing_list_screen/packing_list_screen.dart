import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_item_bottom_sheet.dart';
import './widgets/category_card_widget.dart';
import './widgets/progress_tracking_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/trip_header_widget.dart';
import './widgets/weather_forecast_widget.dart';
import './widgets/weather_warning_widget.dart';

class PackingListScreen extends StatefulWidget {
  const PackingListScreen({Key? key}) : super(key: key);

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Mock data for demonstration
  final String _tripId = 'demo_trip_123';
  final Map<String, dynamic> _tripData = {
    'destination': 'Paris, France',
    'dates': 'Dec 15-22, 2024',
    'travelers': 2,
    'weather': {
      'current': '12°C',
      'condition': 'Partly Cloudy',
      'forecast': 'Rain expected in 2 days'
    }
  };

  final List<Map<String, dynamic>> _categories = [
    {
      'id': '1',
      'name': 'Clothing',
      'icon': 'checkroom',
      'color': 0xFF6366F1,
      'itemCount': 8,
      'packedCount': 5,
      'items': [
        {'name': 'T-shirts (5)', 'isPacked': true},
        {'name': 'Jeans (2)', 'isPacked': true},
        {'name': 'Jacket', 'isPacked': false},
        {'name': 'Underwear', 'isPacked': true},
        {'name': 'Socks', 'isPacked': true},
        {'name': 'Pajamas', 'isPacked': false},
        {'name': 'Shoes', 'isPacked': true},
        {'name': 'Belt', 'isPacked': false},
      ]
    },
    {
      'id': '2',
      'name': 'Electronics',
      'icon': 'devices',
      'color': 0xFF8B5CF6,
      'itemCount': 6,
      'packedCount': 3,
      'items': [
        {'name': 'Phone charger', 'isPacked': true},
        {'name': 'Camera', 'isPacked': false},
        {'name': 'Headphones', 'isPacked': true},
        {'name': 'Power bank', 'isPacked': false},
        {'name': 'Laptop', 'isPacked': true},
        {'name': 'Adapters', 'isPacked': false},
      ]
    },
    {
      'id': '3',
      'name': 'Toiletries',
      'icon': 'soap',
      'color': 0xFF06B6D4,
      'itemCount': 7,
      'packedCount': 7,
      'items': [
        {'name': 'Toothbrush', 'isPacked': true},
        {'name': 'Toothpaste', 'isPacked': true},
        {'name': 'Shampoo', 'isPacked': true},
        {'name': 'Deodorant', 'isPacked': true},
        {'name': 'Skincare', 'isPacked': true},
        {'name': 'Razor', 'isPacked': true},
        {'name': 'Sunscreen', 'isPacked': true},
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty && _selectedFilter == 'All') {
      return _categories;
    }

    return _categories.where((category) {
      bool matchesSearch = true;
      bool matchesFilter = true;

      if (_searchQuery.isNotEmpty) {
        matchesSearch = category['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }

      if (_selectedFilter != 'All') {
        switch (_selectedFilter) {
          case 'Packed':
            matchesFilter = category['packedCount'] == category['itemCount'];
            break;
          case 'Incomplete':
            matchesFilter = category['packedCount'] < category['itemCount'];
            break;
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _showAddItemBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddItemBottomSheet(
            categories: _categories.map((cat) => cat['name'] as String).toList(),
            onAddItem: (categoryName, itemName) {
              // Handle adding new item
              setState(() {
                final category = _categories.firstWhere(
                    (cat) => cat['name'] == categoryName);
                category['items'].add({'name': itemName, 'isPacked': false});
                category['itemCount'] = category['items'].length;
              });
            }));
  }

  void _navigateToWeatherForecast() {
    Navigator.pushNamed(context, AppRoutes.weatherForecastScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: AppTheme.lightTheme.colorScheme.onSurface),
                onPressed: () => Navigator.pop(context)),
            title: Text('Packing List',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface)),
            actions: [
              IconButton(
                  icon: Icon(Icons.more_vert,
                      color: AppTheme.lightTheme.colorScheme.onSurface),
                  onPressed: () {
                    // Handle menu action
                  }),
            ]),
        body: Column(children: [
          // Trip Header
          TripHeaderWidget(
              tripData: _tripData,
              onRefresh: () {
                setState(() {
                  // Handle refresh
                });
              }),

          // Weather Warning (NEW)
          WeatherWarningWidget(
              tripId: _tripId, onWarningTap: _navigateToWeatherForecast),

          // Weather Forecast
          WeatherForecastWidget(
              forecastData: _tripData['weather']),

          // Progress Tracking
          ProgressTrackingWidget(
              totalItems: _categories.fold(
                  0, (sum, cat) => sum + (cat['itemCount'] as int)),
              completedItems: _categories.fold(
                  0, (sum, cat) => sum + (cat['packedCount'] as int)),
              daysUntilTrip: 7),

          // Search and Filter
          SearchBarWidget(
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
              },
              onClear: () {
                setState(() => _searchQuery = '');
              }),

          // Categories List
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    return CategoryCardWidget(
                        categoryData: category,
                        onItemToggle: (itemName, isPacked) {
                          setState(() {
                            final item = category['items'].firstWhere(
                                (item) => item['name'] == itemName);
                            item['isPacked'] = isPacked;

                            // Update packed count
                            category['packedCount'] = category['items']
                                .where((item) => item['isPacked'] == true)
                                .length;
                          });
                        },
                        onItemEdit: (itemName) {
                          // Handle item edit
                        },
                        onItemRemove: (itemName) {
                          // Handle item removal
                        },
                        onItemNote: (itemName) {
                          // Handle item note
                        },
                        onItemCritical: (itemName) {
                          // Handle item critical
                        });
                  })),
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: _showAddItemBottomSheet,
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}