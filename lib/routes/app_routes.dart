import 'package:flutter/material.dart';
import '../presentation/notifications_settings_screen/notifications_settings_screen.dart';
import '../presentation/weather_forecast_screen/weather_forecast_screen.dart';
import '../presentation/packing_list_screen/packing_list_screen.dart';
import '../presentation/trip_setup_screen/trip_setup_screen.dart';
import '../presentation/trip_dashboard_screen/trip_dashboard_screen.dart';
import '../presentation/profile_settings_screen/profile_settings_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/signup_screen/signup_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String signupScreen = '/signup-screen';
  static const String notificationsSettingsScreen =
      '/notifications-settings-screen';
  static const String weatherForecastScreen = '/weather-forecast-screen';
  static const String packingListScreen = '/packing-list-screen';
  static const String tripSetupScreen = '/trip-setup-screen';
  static const String tripDashboardScreen = '/trip-dashboard-screen';
  static const String profileSettingsScreen = '/profile-settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    loginScreen: (context) => const LoginScreen(),
    signupScreen: (context) => const SignupScreen(),
    notificationsSettingsScreen: (context) =>
        const NotificationsSettingsScreen(),
    weatherForecastScreen: (context) => const WeatherForecastScreen(),
    packingListScreen: (context) => const PackingListScreen(),
    tripSetupScreen: (context) => const TripSetupScreen(),
    tripDashboardScreen: (context) => const TripDashboardScreen(),
    profileSettingsScreen: (context) => const ProfileSettingsScreen(),
    // TODO: Add your other routes here
  };
}
