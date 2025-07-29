import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_picker_widget.dart';
import './widgets/destination_search_widget.dart';
import './widgets/gender_selector_widget.dart';
import './widgets/get_weather_button_widget.dart';
import './widgets/traveler_count_widget.dart';
import './widgets/trip_type_selector_widget.dart';

class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({Key? key}) : super(key: key);

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  final ScrollController _scrollController = ScrollController();

  // Form data
  String? _destination;
  DateTime? _departureDate;
  DateTime? _returnDate;
  TripType _tripType = TripType.leisure;
  Gender _gender = Gender.male;
  int _travelerCount = 1;
  bool _isLoading = false;

  // Form validation
  String? _formError;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _destination != null &&
        _destination!.isNotEmpty &&
        _departureDate != null &&
        _returnDate != null;
  }

  void _onDestinationSelected(String destination) {
    setState(() {
      _destination = destination;
      _formError = null;
    });
  }

  void _onDatesSelected(DateTime? departure, DateTime? returnDate) {
    setState(() {
      _departureDate = departure;
      _returnDate = returnDate;
      _formError = null;
    });
  }

  void _onTripTypeSelected(TripType tripType) {
    setState(() {
      _tripType = tripType;
    });
  }

  void _onGenderSelected(Gender gender) {
    setState(() {
      _gender = gender;
    });
  }

  void _onTravelerCountChanged(int count) {
    setState(() {
      _travelerCount = count;
    });
  }

  Future<void> _getWeatherAndPack() async {
    // Validate form
    if (!_isFormValid) {
      setState(() {
        _formError = "Please fill in all required fields";
      });
      return;
    }

    // Check for past dates
    if (_departureDate!
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      setState(() {
        _formError = "Departure date cannot be in the past";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _formError = null;
    });

    try {
      // Simulate API call for weather data
      await Future.delayed(const Duration(seconds: 2));

      // Haptic feedback for success
      HapticFeedback.lightImpact();

      // Navigate to packing list screen with trip data
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/packing-list-screen',
          arguments: {
            'destination': _destination,
            'departureDate': _departureDate,
            'returnDate': _returnDate,
            'tripType': _tripType,
            'gender': _gender,
            'travelerCount': _travelerCount,
          },
        );
      }
    } catch (e) {
      setState(() {
        _formError = "Failed to get weather data. Please try again.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Plan Your Trip",
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _dismissKeyboard,
            child: Text(
              "Done",
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: _dismissKeyboard,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Header
                      Text(
                        "Let's create your perfect packing list",
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "We'll use weather data and your preferences to recommend exactly what you need.",
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Destination Search
                      DestinationSearchWidget(
                        onDestinationSelected: _onDestinationSelected,
                        initialDestination: _destination,
                      ),
                      SizedBox(height: 4.h),

                      // Date Picker
                      DatePickerWidget(
                        onDatesSelected: _onDatesSelected,
                        initialDepartureDate: _departureDate,
                        initialReturnDate: _returnDate,
                      ),
                      SizedBox(height: 4.h),

                      // Trip Type Selector
                      TripTypeSelectorWidget(
                        onTripTypeSelected: _onTripTypeSelected,
                        initialTripType: _tripType,
                      ),
                      SizedBox(height: 4.h),

                      // Gender Selector
                      GenderSelectorWidget(
                        onGenderSelected: _onGenderSelected,
                        initialGender: _gender,
                      ),
                      SizedBox(height: 4.h),

                      // Traveler Count
                      TravelerCountWidget(
                        onTravelerCountChanged: _onTravelerCountChanged,
                        initialCount: _travelerCount,
                      ),
                      SizedBox(height: 4.h),

                      // Form Error
                      if (_formError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.lightTheme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.error
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'error',
                                color: AppTheme.lightTheme.colorScheme.error,
                                size: 5.w,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  _formError!,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],

                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: GetWeatherButtonWidget(
                  onPressed: _getWeatherAndPack,
                  isEnabled: _isFormValid,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
