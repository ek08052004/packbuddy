import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PermissionStatusCard extends StatelessWidget {
  final bool isNotificationEnabled;
  final VoidCallback onEnablePressed;

  const PermissionStatusCard({
    Key? key,
    required this.isNotificationEnabled,
    required this.onEnablePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isNotificationEnabled
            ? AppTheme.lightTheme.colorScheme.secondaryContainer
            : AppTheme.lightTheme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNotificationEnabled
              ? AppTheme.lightTheme.colorScheme.secondary
              : AppTheme.lightTheme.colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: isNotificationEnabled
                    ? 'notifications_active'
                    : 'notifications_off',
                color: isNotificationEnabled
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  isNotificationEnabled
                      ? 'Notifications Enabled'
                      : 'Notifications Disabled',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: isNotificationEnabled
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            isNotificationEnabled
                ? 'You\'ll receive packing reminders and trip alerts to help you stay organized.'
                : 'Enable notifications to receive packing reminders and important trip alerts.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: isNotificationEnabled
                  ? AppTheme.lightTheme.colorScheme.onSecondaryContainer
                  : AppTheme.lightTheme.colorScheme.onErrorContainer,
            ),
          ),
          if (!isNotificationEnabled) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onEnablePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Enable Notifications',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
