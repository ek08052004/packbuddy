import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onCreateTrip;

  const EmptyStateWidget({
    Key? key,
    this.onCreateTrip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Travel Illustration
          Container(
            width: 60.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TravelPatternPainter(),
                  ),
                ),
                // Main illustration elements
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Suitcase icon
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'luggage',
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Airplane trail
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'flight',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                        Container(
                          width: 15.w,
                          height: 2,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Title
          Text(
            'Ready for Your Next Adventure?',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          // Subtitle
          Text(
            'Create your first trip and let PackBuddy help you pack smart with weather-based recommendations.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          // CTA Button
          SizedBox(
            width: 70.w,
            height: 6.h,
            child: ElevatedButton(
              onPressed: onCreateTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'add',
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Plan Your First Trip',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Features preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureItem('Weather-based packing', 'cloud'),
              _buildFeatureItem('Smart reminders', 'notifications'),
              _buildFeatureItem('Progress tracking', 'check_circle'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, String iconName) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 20,
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          width: 20.w,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TravelPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dotted path pattern
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.2,
      size.height * 0.7,
    );

    // Draw dashed path
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(distance, distance + 10);
        canvas.drawPath(segment, paint);
        distance += 20;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
