import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/past_trips_section_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/trip_card_widget.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({Key? key}) : super(key: key);

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearchExpanded = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredTrips = [];

  // Mock data for trips
  final List<Map<String, dynamic>> _allTrips = [
    {
      "id": 1,
      "destination": "Tokyo, Japan",
      "startDate": "2025-08-15",
      "endDate": "2025-08-22",
      "imageUrl":
          "https://images.pexels.com/photos/2506923/pexels-photo-2506923.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "packingProgress": 75.0,
      "weatherCondition": "Sunny",
      "temperature": 28,
      "isPastTrip": false,
      "tripType": "Leisure",
    },
    {
      "id": 2,
      "destination": "London, UK",
      "startDate": "2025-09-10",
      "endDate": "2025-09-17",
      "imageUrl":
          "https://images.pexels.com/photos/460672/pexels-photo-460672.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "packingProgress": 45.0,
      "weatherCondition": "Rainy",
      "temperature": 15,
      "isPastTrip": false,
      "tripType": "Business",
    },
    {
      "id": 3,
      "destination": "Bali, Indonesia",
      "startDate": "2025-10-05",
      "endDate": "2025-10-12",
      "imageUrl":
          "https://images.pexels.com/photos/2166559/pexels-photo-2166559.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "packingProgress": 20.0,
      "weatherCondition": "Cloudy",
      "temperature": 26,
      "isPastTrip": false,
      "tripType": "Leisure",
    },
    {
      "id": 4,
      "destination": "Paris, France",
      "startDate": "2025-06-20",
      "endDate": "2025-06-27",
      "imageUrl":
          "https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "packingProgress": 100.0,
      "weatherCondition": "Clear",
      "temperature": 22,
      "isPastTrip": true,
      "tripType": "Leisure",
    },
    {
      "id": 5,
      "destination": "New York, USA",
      "startDate": "2025-05-15",
      "endDate": "2025-05-20",
      "imageUrl":
          "https://images.pexels.com/photos/290386/pexels-photo-290386.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "packingProgress": 95.0,
      "weatherCondition": "Sunny",
      "temperature": 18,
      "isPastTrip": true,
      "tripType": "Business",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredTrips = _allTrips;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _upcomingTrips {
    return _filteredTrips
        .where((trip) => !(trip['isPastTrip'] as bool))
        .toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['startDate'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['startDate'] ?? '') ?? DateTime.now();
        return dateA.compareTo(dateB);
      });
  }

  List<Map<String, dynamic>> get _pastTrips {
    return _filteredTrips.where((trip) => trip['isPastTrip'] as bool).toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['endDate'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['endDate'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
  }

  void _filterTrips(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTrips = _allTrips;
      } else {
        _filteredTrips = _allTrips.where((trip) {
          final destination = (trip['destination'] as String).toLowerCase();
          final startDate = trip['startDate'] as String;
          final endDate = trip['endDate'] as String;
          final tripType = (trip['tripType'] as String).toLowerCase();

          return destination.contains(query.toLowerCase()) ||
              startDate.contains(query) ||
              endDate.contains(query) ||
              tripType.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchQuery = '';
        _filteredTrips = _allTrips;
      }
    });
  }

  Future<void> _refreshTrips() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    // In a real app, this would fetch updated data from the server
    setState(() {
      // Update weather data and recommendations
      for (var trip in _allTrips) {
        // Simulate weather update
        if (!(trip['isPastTrip'] as bool)) {
          trip['temperature'] = (trip['temperature'] as int) +
              (DateTime.now().millisecond % 5 - 2);
        }
      }
      _filteredTrips = _allTrips;
    });
  }

  void _handleTripTap(Map<String, dynamic> trip) {
    Navigator.pushNamed(context, '/packing-list-screen');
  }

  void _handleTripEdit(Map<String, dynamic> trip) {
    Navigator.pushNamed(context, '/trip-setup-screen');
  }

  void _handleTripDuplicate(Map<String, dynamic> trip) {
    setState(() {
      final newTrip = Map<String, dynamic>.from(trip);
      newTrip['id'] = _allTrips.length + 1;
      newTrip['destination'] = '${trip['destination']} (Copy)';
      newTrip['packingProgress'] = 0.0;
      newTrip['isPastTrip'] = false;
      _allTrips.add(newTrip);
      _filteredTrips = _allTrips;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trip duplicated successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _handleTripShare(Map<String, dynamic> trip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Packing list shared for ${trip['destination']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleTripDelete(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trip'),
        content: Text(
            'Are you sure you want to delete this trip to ${trip['destination']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allTrips.removeWhere((t) => t['id'] == trip['id']);
                _filteredTrips = _allTrips;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip deleted'),
                  backgroundColor: AppTheme.errorLight,
                ),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleCreateTrip() {
    Navigator.pushNamed(context, '/trip-setup-screen');
  }

  void _handleNotificationTap() {
    Navigator.pushNamed(context, '/notifications-settings-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          DashboardHeaderWidget(
            onNotificationTap: _handleNotificationTap,
            notificationCount: 3,
          ),
          // Tab Bar
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'dashboard',
                        color: _tabController.index == 0
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text('Dashboard'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'add_circle',
                        color: _tabController.index == 1
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text('New Trip'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color: _tabController.index == 2
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text('Profile'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Dashboard Tab
                _buildDashboardTab(),
                // New Trip Tab
                _buildNewTripTab(),
                // Profile Tab
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _handleCreateTrip,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshTrips,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: GestureDetector(
              onVerticalDragDown: (_) => _toggleSearch(),
              child: SearchBarWidget(
                onSearchChanged: _filterTrips,
                isExpanded: _isSearchExpanded,
                onFilterTap: () {
                  // Handle filter options
                },
              ),
            ),
          ),
          // Main content
          _upcomingTrips.isEmpty && _pastTrips.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    onCreateTrip: _handleCreateTrip,
                  ),
                )
              : SliverList(
                  delegate: SliverChildListDelegate([
                    // Upcoming trips section
                    if (_upcomingTrips.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'upcoming',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Upcoming Trips',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme
                                    .lightTheme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_upcomingTrips.length}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._upcomingTrips.map((trip) => TripCardWidget(
                            tripData: trip,
                            onTap: () => _handleTripTap(trip),
                            onEdit: () => _handleTripEdit(trip),
                            onDuplicate: () => _handleTripDuplicate(trip),
                            onShare: () => _handleTripShare(trip),
                            onDelete: () => _handleTripDelete(trip),
                          )),
                    ],
                    // Past trips section
                    if (_pastTrips.isNotEmpty)
                      PastTripsSectionWidget(
                        pastTrips: _pastTrips,
                        onTripTap: _handleTripTap,
                        onTripEdit: _handleTripEdit,
                        onTripDuplicate: _handleTripDuplicate,
                        onTripShare: _handleTripShare,
                        onTripDelete: _handleTripDelete,
                      ),
                    SizedBox(height: 10.h), // Bottom padding for FAB
                  ]),
                ),
        ],
      ),
    );
  }

  Widget _buildNewTripTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'flight_takeoff',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Create New Trip',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start planning your next adventure with smart packing recommendations',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 70.w,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _handleCreateTrip,
              child: Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'person_outline',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Profile Settings',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Manage your account and preferences',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: 70.w,
            height: 6.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile-settings-screen');
              },
              child: Text('View Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
