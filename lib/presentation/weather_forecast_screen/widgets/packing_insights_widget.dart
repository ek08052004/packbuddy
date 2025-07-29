import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PackingInsightsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> insights;
  final VoidCallback? onAddItem;

  const PackingInsightsWidget({
    Key? key,
    required this.insights,
    this.onAddItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Packing Insights',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: _getInsightColor(
                                    insight['type'] as String? ?? 'info')
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: _getInsightIcon(
                                insight['type'] as String? ?? 'info'),
                            color: _getInsightColor(
                                insight['type'] as String? ?? 'info'),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insight['day'] as String? ?? 'Day 1',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                insight['condition'] as String? ??
                                    'Weather condition',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      insight['recommendation'] as String? ??
                          'Pack appropriate items for the weather.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 2.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: ((insight['items'] as List<String>?) ?? [])
                          .map((item) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              GestureDetector(
                                onTap: onAddItem,
                                child: CustomIconWidget(
                                  iconName: 'add_circle_outline',
                                  color: AppTheme.lightTheme.primaryColor,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(String type) {
    switch (type.toLowerCase()) {
      case 'rain':
        return AppTheme.lightTheme.primaryColor;
      case 'cold':
        return Colors.blue;
      case 'hot':
        return Colors.orange;
      case 'wind':
        return Colors.teal;
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _getInsightIcon(String type) {
    switch (type.toLowerCase()) {
      case 'rain':
        return 'umbrella';
      case 'cold':
        return 'ac_unit';
      case 'hot':
        return 'wb_sunny';
      case 'wind':
        return 'air';
      default:
        return 'info';
    }
  }
}
