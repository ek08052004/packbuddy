import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyData,
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
              '24-Hour Forecast',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 15.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: hourlyData.length,
              itemBuilder: (context, index) {
                final hour = hourlyData[index];
                return Container(
                  width: 18.w,
                  margin: EdgeInsets.only(right: 3.w),
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hour['time'] as String? ?? '00:00',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      CustomImageWidget(
                        imageUrl: hour['icon'] as String? ??
                            'https://openweathermap.org/img/wn/01d@2x.png',
                        width: 8.w,
                        height: 8.w,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        '${hour['temperature']}°',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'water_drop',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 12,
                          ),
                          SizedBox(width: 0.5.w),
                          Text(
                            '${hour['precipitation']}%',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
