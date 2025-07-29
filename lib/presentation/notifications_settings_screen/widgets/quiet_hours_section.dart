import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class QuietHoursSection extends StatelessWidget {
  final bool quietHoursEnabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(bool) onQuietHoursChanged;
  final VoidCallback onStartTimePressed;
  final VoidCallback onEndTimePressed;

  const QuietHoursSection({
    Key? key,
    required this.quietHoursEnabled,
    required this.startTime,
    required this.endTime,
    required this.onQuietHoursChanged,
    required this.onStartTimePressed,
    required this.onEndTimePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'bedtime',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Quiet Hours',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildQuietHoursToggle(context),
          if (quietHoursEnabled) ...[
            _buildTimeSelector(
              context,
              'Start Time',
              startTime,
              onStartTimePressed,
            ),
            _buildTimeSelector(
              context,
              'End Time',
              endTime,
              onEndTimePressed,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuietHoursToggle(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Quiet Hours',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Prevent notifications during sleep hours',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Switch(
            value: quietHoursEnabled,
            onChanged: onQuietHoursChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    TimeOfDay time,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'access_time',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    time.format(context),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
