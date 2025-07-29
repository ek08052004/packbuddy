import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ToggleSettingWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? iconName;
  final bool showDivider;

  const ToggleSettingWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconName,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              if (iconName != null) ...[
                CustomIconWidget(
                  iconName: iconName!,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle!,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                activeTrackColor: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.lightTheme.dividerColor,
            indent: iconName != null ? 15.w : 4.w,
            endIndent: 4.w,
          ),
      ],
    );
  }
}
