import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NotificationToggleSection extends StatelessWidget {
  final String title;
  final String iconName;
  final List<Map<String, dynamic>> toggleOptions;

  const NotificationToggleSection({
    Key? key,
    required this.title,
    required this.iconName,
    required this.toggleOptions,
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
                  iconName: iconName,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
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
          ...toggleOptions.map((option) => _buildToggleOption(
                context,
                option['label'] as String,
                option['description'] as String,
                option['value'] as bool,
                option['onChanged'] as Function(bool),
                option['priority'] as String? ?? 'normal',
              )),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context,
    String label,
    String description,
    bool value,
    Function(bool) onChanged,
    String priority,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (priority == 'high') ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CRITICAL',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: priority == 'high'
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor: priority == 'high'
                ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
