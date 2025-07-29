import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/current_weather_card.dart';
import './widgets/daily_forecast_widget.dart';
import './widgets/hourly_forecast_widget.dart';
import './widgets/packing_insights_widget.dart';
import './widgets/temperature_range_widget.dart';
import './widgets/weather_alerts_widget.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({Key? key}) : super(key: key);

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock weather data
  final Map<String, dynamic> _currentWeather = {
    "location": "Paris, France",
    "temperature": 22,
    "condition": "Partly Cloudy",
    "feelsLike": 25,
    "humidity": 65,
    "icon": "https://openweathermap.org/img/wn/02d@2x.png",
  };

  final List<Map<String, dynamic>> _hourlyForecast = [
    {
      "time": "12:00",
      "temperature": 22,
      "precipitation": 10,
      "icon": "https://openweathermap.org/img/wn/02d@2x.png",
    },
    {
      "time": "13:00",
      "temperature": 24,
      "precipitation": 5,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
    },
    {
      "time": "14:00",
      "temperature": 26,
      "precipitation": 0,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
    },
    {
      "time": "15:00",
      "temperature": 27,
      "precipitation": 0,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
    },
    {
      "time": "16:00",
      "temperature": 25,
      "precipitation": 15,
      "icon": "https://openweathermap.org/img/wn/02d@2x.png",
    },
    {
      "time": "17:00",
      "temperature": 23,
      "precipitation": 20,
      "icon": "https://openweathermap.org/img/wn/03d@2x.png",
    },
    {
      "time": "18:00",
      "temperature": 21,
      "precipitation": 30,
      "icon": "https://openweathermap.org/img/wn/04d@2x.png",
    },
    {
      "time": "19:00",
      "temperature": 19,
      "precipitation": 40,
      "icon": "https://openweathermap.org/img/wn/09d@2x.png",
    },
  ];

  final List<Map<String, dynamic>> _dailyForecast = [
    {
      "day": "Today",
      "high": 27,
      "low": 18,
      "condition": "Partly Cloudy",
      "precipitation": 20,
      "icon": "https://openweathermap.org/img/wn/02d@2x.png",
      "packingItems": ["sunglasses", "jacket"],
    },
    {
      "day": "Tomorrow",
      "high": 24,
      "low": 16,
      "condition": "Light Rain",
      "precipitation": 70,
      "icon": "https://openweathermap.org/img/wn/10d@2x.png",
      "packingItems": ["umbrella", "jacket", "boots"],
    },
    {
      "day": "Wednesday",
      "high": 29,
      "low": 20,
      "condition": "Sunny",
      "precipitation": 5,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
      "packingItems": ["sunscreen", "sunglasses"],
    },
    {
      "day": "Thursday",
      "high": 26,
      "low": 19,
      "condition": "Cloudy",
      "precipitation": 15,
      "icon": "https://openweathermap.org/img/wn/03d@2x.png",
      "packingItems": ["jacket"],
    },
    {
      "day": "Friday",
      "high": 23,
      "low": 15,
      "condition": "Heavy Rain",
      "precipitation": 85,
      "icon": "https://openweathermap.org/img/wn/11d@2x.png",
      "packingItems": ["umbrella", "jacket", "boots"],
    },
    {
      "day": "Saturday",
      "high": 25,
      "low": 17,
      "condition": "Partly Cloudy",
      "precipitation": 25,
      "icon": "https://openweathermap.org/img/wn/02d@2x.png",
      "packingItems": ["jacket", "sunglasses"],
    },
    {
      "day": "Sunday",
      "high": 28,
      "low": 21,
      "condition": "Sunny",
      "precipitation": 0,
      "icon": "https://openweathermap.org/img/wn/01d@2x.png",
      "packingItems": ["sunscreen", "sunglasses"],
    },
  ];

  final List<Map<String, dynamic>> _weatherAlerts = [
    {
      "title": "Heavy Rain Warning",
      "summary":
          "Heavy rainfall expected Friday afternoon affecting outdoor activities",
      "description":
          "A low-pressure system will bring heavy rainfall to the Paris region on Friday afternoon and evening. Rainfall amounts of 25-40mm are expected within 6 hours. This may cause localized flooding in low-lying areas and could impact transportation services.",
      "severity": "moderate",
      "startTime": "Fri 2:00 PM",
      "endTime": "Fri 11:00 PM",
    },
  ];

  final List<Map<String, dynamic>> _packingInsights = [
    {
      "day": "Day 2 (Tomorrow)",
      "condition": "Light Rain Expected",
      "type": "rain",
      "recommendation":
          "Rain expected tomorrow with 70% chance of precipitation. Pack waterproof items to stay dry during outdoor activities.",
      "items": ["Waterproof Jacket", "Umbrella", "Rain Boots"],
    },
    {
      "day": "Day 5 (Friday)",
      "condition": "Heavy Rain & Cool Temperatures",
      "type": "rain",
      "recommendation":
          "Heavy rain and cooler temperatures on Friday. Consider indoor activities or pack extra protection.",
      "items": ["Heavy Rain Coat", "Warm Layers", "Waterproof Bag"],
    },
    {
      "day": "Weekend",
      "condition": "Sunny & Warm",
      "type": "hot",
      "recommendation":
          "Beautiful sunny weather expected for the weekend. Perfect for outdoor sightseeing and activities.",
      "items": ["Sunscreen SPF 30+", "Sunglasses", "Light Clothing"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshWeatherData,
        color: AppTheme.lightTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CurrentWeatherCard(weatherData: _currentWeather),
              HourlyForecastWidget(hourlyData: _hourlyForecast),
              SizedBox(height: 2.h),
              DailyForecastWidget(dailyData: _dailyForecast),
              SizedBox(height: 2.h),
              WeatherAlertsWidget(alerts: _weatherAlerts),
              SizedBox(height: 2.h),
              PackingInsightsWidget(
                insights: _packingInsights,
                onAddItem: _handleAddItem,
              ),
              SizedBox(height: 2.h),
              TemperatureRangeWidget(temperatureData: _dailyForecast),
              SizedBox(height: 2.h),
              _buildLastUpdated(),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareWeatherSummary,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'share',
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          'Share',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Text(
        'Weather Forecast',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshWeatherData,
          icon: _isRefreshing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                )
              : CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'packing_list',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'checklist',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('View Packing List'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'trip_dashboard',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'dashboard',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('Trip Dashboard'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Last updated: ${_formatLastUpdated()}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weather data updated successfully'),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleAddItem() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item added to packing list'),
        backgroundColor: AppTheme.successLight,
        action: SnackBarAction(
          label: 'View List',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/packing-list-screen');
          },
        ),
      ),
    );
  }

  void _shareWeatherSummary() {
    final summary = '''
Weather Summary for ${_currentWeather['location']}

Current: ${_currentWeather['temperature']}° - ${_currentWeather['condition']}
Feels like: ${_currentWeather['feelsLike']}°

7-Day Outlook:
${_dailyForecast.map((day) => '${day['day']}: ${day['high']}°/${day['low']}° - ${day['condition']}').join('\n')}

Generated by PackBuddy
''';

    // In a real app, this would use the share package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weather summary copied to clipboard'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'packing_list':
        Navigator.pushNamed(context, '/packing-list-screen');
        break;
      case 'trip_dashboard':
        Navigator.pushNamed(context, '/trip-dashboard-screen');
        break;
    }
  }
}
