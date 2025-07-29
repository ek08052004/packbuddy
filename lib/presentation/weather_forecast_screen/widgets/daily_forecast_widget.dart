import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;

  const DailyForecastWidget({
    Key? key,
    required this.dailyData,
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
            child: Text(
              '7-Day Forecast',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyData.length,
            itemBuilder: (context, index) {
              final day = dailyData[index];
              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        day['day'] as String? ?? 'Today',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomImageWidget(
                            imageUrl: day['icon'] as String? ??
                                'https://openweathermap.org/img/wn/01d@2x.png',
                            width: 8.w,
                            height: 8.w,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 2.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day['condition'] as String? ?? 'Clear',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'water_drop',
                                    color: AppTheme.lightTheme.primaryColor,
                                    size: 12,
                                  ),
                                  SizedBox(width: 0.5.w),
                                  Text(
                                    '${day['precipitation']}%',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${day['high']}°',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '/${day['low']}°',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildPackingIcons(
                          day['packingItems'] as List<String>? ?? []),
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

  List<Widget> _buildPackingIcons(List<String> items) {
    final iconMap = {
      'umbrella': 'umbrella',
      'jacket': 'checkroom',
      'sunscreen': 'wb_sunny',
      'sunglasses': 'visibility',
      'boots': 'hiking',
    };

    return items.take(3).map((item) {
      final iconName = iconMap[item] ?? 'info';
      return Padding(
        padding: EdgeInsets.only(left: 1.w),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.primaryColor,
          size: 16,
        ),
      );
    }).toList();
  }
}
