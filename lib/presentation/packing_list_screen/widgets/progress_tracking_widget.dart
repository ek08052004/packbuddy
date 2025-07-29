import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressTrackingWidget extends StatelessWidget {
  final int completedItems;
  final int totalItems;
  final int daysUntilTrip;

  const ProgressTrackingWidget({
    Key? key,
    required this.completedItems,
    required this.totalItems,
    required this.daysUntilTrip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;
    final progressPercentage = (progress * 100).round();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primaryContainer,
            AppTheme.lightTheme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Packing Progress",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "$completedItems of $totalItems items packed",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$progressPercentage%",
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 1.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: daysUntilTrip <= 1 ? 'schedule' : 'event',
                color: daysUntilTrip <= 1
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _getMotivationalMessage(progressPercentage, daysUntilTrip),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int progressPercentage, int daysUntilTrip) {
    if (progressPercentage == 100) {
      return "🎉 All packed! You're ready for your adventure!";
    } else if (daysUntilTrip <= 1) {
      return "⏰ Trip starts soon! ${100 - progressPercentage}% remaining";
    } else if (daysUntilTrip <= 3) {
      return "🚀 Almost time to go! ${100 - progressPercentage}% left to pack";
    } else if (progressPercentage >= 75) {
      return "💪 Great progress! You're almost there!";
    } else if (progressPercentage >= 50) {
      return "👍 Halfway done! Keep it up!";
    } else if (progressPercentage >= 25) {
      return "📝 Good start! $daysUntilTrip days to finish packing";
    } else {
      return "✈️ $daysUntilTrip days until departure. Time to start packing!";
    }
  }
}
