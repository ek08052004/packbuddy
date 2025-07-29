import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ReminderTimingSection extends StatelessWidget {
  final String selectedTiming;
  final Function(String) onTimingChanged;
  final VoidCallback onCustomTimePressed;

  const ReminderTimingSection({
    Key? key,
    required this.selectedTiming,
    required this.onTimingChanged,
    required this.onCustomTimePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> timingOptions = [
      {
        'value': '1_day',
        'label': '1 Day Before',
        'description': 'Reminder 24 hours before departure'
      },
      {
        'value': '3_days',
        'label': '3 Days Before',
        'description': 'Reminder 72 hours before departure'
      },
      {
        'value': '1_week',
        'label': '1 Week Before',
        'description': 'Reminder 7 days before departure'
      },
      {
        'value': 'custom',
        'label': 'Custom Timing',
        'description': 'Set your own reminder schedule'
      },
    ];

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
                  iconName: 'schedule',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Reminder Timing',
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
          ...timingOptions.map((option) => _buildTimingOption(
                context,
                option['value']!,
                option['label']!,
                option['description']!,
              )),
        ],
      ),
    );
  }

  Widget _buildTimingOption(
      BuildContext context, String value, String label, String description) {
    final bool isSelected = selectedTiming == value;

    return InkWell(
      onTap: () {
        if (value == 'custom') {
          onCustomTimePressed();
        } else {
          onTimingChanged(value);
        }
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedTiming,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  if (newValue == 'custom') {
                    onCustomTimePressed();
                  } else {
                    onTimingChanged(newValue);
                  }
                }
              },
              activeColor: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
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
            if (value == 'custom')
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
