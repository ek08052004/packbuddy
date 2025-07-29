import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TripCardWidget extends StatelessWidget {
  final Map<String, dynamic> tripData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const TripCardWidget({
    Key? key,
    required this.tripData,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onShare,
    this.onArchive,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String destination = tripData['destination'] ?? 'Unknown Destination';
    final String startDate = tripData['startDate'] ?? '';
    final String endDate = tripData['endDate'] ?? '';
    final String imageUrl = tripData['imageUrl'] ?? '';
    final double packingProgress =
        (tripData['packingProgress'] ?? 0.0).toDouble();
    final String weatherCondition = tripData['weatherCondition'] ?? 'Clear';
    final int temperature = tripData['temperature'] ?? 22;
    final bool isPastTrip = tripData['isPastTrip'] ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Dismissible(
        key: Key(tripData['id'].toString()),
        background: _buildSwipeBackground(isLeft: false),
        secondaryBackground: _buildSwipeBackground(isLeft: true),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            onEdit?.call();
          } else if (direction == DismissDirection.endToStart) {
            onDelete?.call();
          }
        },
        child: Container(
          width: 90.w,
          height: 24.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row - Weather and Past Trip Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: _getWeatherIcon(weatherCondition),
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${temperature}°C',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isPastTrip
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.secondary
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Past',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                        Spacer(),
                        // Destination and Dates
                        Text(
                          destination,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '$startDate - $endDate',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        // Packing Progress
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Packing Progress',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  LinearProgressIndicator(
                                    value: packingProgress / 100,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTheme.colorScheme.secondary,
                                    ),
                                    minHeight: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Container(
                              width: 12.w,
                              height: 12.w,
                              child: Stack(
                                children: [
                                  CircularProgressIndicator(
                                    value: packingProgress / 100,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTheme.colorScheme.secondary,
                                    ),
                                    strokeWidth: 3,
                                  ),
                                  Center(
                                    child: Text(
                                      '${packingProgress.toInt()}%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.errorLight
            : AppTheme.lightTheme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'delete' : 'edit',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'Delete' : 'Edit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            _buildContextMenuItem(
              context,
              'Notifications Settings',
              'notifications',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications-settings-screen');
              },
            ),
            _buildContextMenuItem(
              context,
              'Export List',
              'file_download',
              () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            _buildContextMenuItem(
              context,
              'Trip Notes',
              'note',
              () {
                Navigator.pop(context);
                // Handle trip notes
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'wb_sunny';
      case 'cloudy':
      case 'overcast':
        return 'cloud';
      case 'rainy':
      case 'rain':
        return 'umbrella';
      case 'snowy':
      case 'snow':
        return 'ac_unit';
      case 'thunderstorm':
        return 'flash_on';
      default:
        return 'wb_sunny';
    }
  }
}
