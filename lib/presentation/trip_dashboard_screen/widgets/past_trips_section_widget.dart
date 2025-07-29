import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './trip_card_widget.dart';

class PastTripsSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> pastTrips;
  final Function(Map<String, dynamic>) onTripTap;
  final Function(Map<String, dynamic>) onTripEdit;
  final Function(Map<String, dynamic>) onTripDuplicate;
  final Function(Map<String, dynamic>) onTripShare;
  final Function(Map<String, dynamic>) onTripDelete;

  const PastTripsSectionWidget({
    Key? key,
    required this.pastTrips,
    required this.onTripTap,
    required this.onTripEdit,
    required this.onTripDuplicate,
    required this.onTripShare,
    required this.onTripDelete,
  }) : super(key: key);

  @override
  State<PastTripsSectionWidget> createState() => _PastTripsSectionWidgetState();
}

class _PastTripsSectionWidgetState extends State<PastTripsSectionWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pastTrips.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'history',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Past Trips',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${widget.pastTrips.length} completed trips',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.pastTrips.length}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: CustomIconWidget(
                          iconName: 'keyboard_arrow_down',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: EdgeInsets.only(top: 1.h),
              child: Column(
                children: [
                  // Quick stats for past trips
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total Destinations',
                            _getUniqueDestinations().toString(),
                            'location_on',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 6.h,
                          color: AppTheme.lightTheme.dividerColor,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Avg. Packing Score',
                            '${_getAveragePackingScore()}%',
                            'check_circle',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 6.h,
                          color: AppTheme.lightTheme.dividerColor,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Last Trip',
                            _getLastTripDate(),
                            'calendar_today',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Past trips list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.pastTrips.length,
                    itemBuilder: (context, index) {
                      final trip = widget.pastTrips[index];
                      return TripCardWidget(
                        tripData: trip,
                        onTap: () => widget.onTripTap(trip),
                        onEdit: () => widget.onTripEdit(trip),
                        onDuplicate: () => widget.onTripDuplicate(trip),
                        onShare: () => widget.onTripShare(trip),
                        onDelete: () => widget.onTripDelete(trip),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 24,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int _getUniqueDestinations() {
    final destinations =
        widget.pastTrips.map((trip) => trip['destination'] as String).toSet();
    return destinations.length;
  }

  int _getAveragePackingScore() {
    if (widget.pastTrips.isEmpty) return 0;
    final totalScore = widget.pastTrips.fold<double>(
      0.0,
      (sum, trip) => sum + ((trip['packingProgress'] ?? 0.0) as double),
    );
    return (totalScore / widget.pastTrips.length).round();
  }

  String _getLastTripDate() {
    if (widget.pastTrips.isEmpty) return 'N/A';

    // Sort trips by end date and get the most recent
    final sortedTrips = List<Map<String, dynamic>>.from(widget.pastTrips);
    sortedTrips.sort((a, b) {
      final dateA = DateTime.tryParse(a['endDate'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['endDate'] ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    final lastTripDate = DateTime.tryParse(sortedTrips.first['endDate'] ?? '');
    if (lastTripDate == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(lastTripDate).inDays;

    if (difference < 30) {
      return '${difference}d ago';
    } else if (difference < 365) {
      return '${(difference / 30).round()}m ago';
    } else {
      return '${(difference / 365).round()}y ago';
    }
  }
}
