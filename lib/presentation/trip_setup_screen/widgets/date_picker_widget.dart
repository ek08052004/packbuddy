import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DatePickerWidget extends StatefulWidget {
  final Function(DateTime?, DateTime?) onDatesSelected;
  final DateTime? initialDepartureDate;
  final DateTime? initialReturnDate;

  const DatePickerWidget({
    Key? key,
    required this.onDatesSelected,
    this.initialDepartureDate,
    this.initialReturnDate,
  }) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _departureDate;
  DateTime? _returnDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _departureDate = widget.initialDepartureDate;
    _returnDate = widget.initialReturnDate;
  }

  Future<void> _selectDepartureDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _departureDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            headerBackgroundColor: AppTheme.lightTheme.colorScheme.primary,
            headerForegroundColor: Colors.white,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return AppTheme.lightTheme.colorScheme.onSurface;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.lightTheme.colorScheme.primary;
              }
              return Colors.transparent;
            }),
            todayForegroundColor: WidgetStateProperty.all(
              AppTheme.lightTheme.colorScheme.primary,
            ),
            todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
            todayBorder: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _departureDate = picked;
        _dateError = null;

        // Reset return date if it's before departure date
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      });
      widget.onDatesSelected(_departureDate, _returnDate);
    }
  }

  Future<void> _selectReturnDate() async {
    if (_departureDate == null) {
      setState(() {
        _dateError = "Please select departure date first";
      });
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _departureDate!.add(const Duration(days: 1)),
      firstDate: _departureDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            headerBackgroundColor: AppTheme.lightTheme.colorScheme.primary,
            headerForegroundColor: Colors.white,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return AppTheme.lightTheme.colorScheme.onSurface;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.lightTheme.colorScheme.primary;
              }
              return Colors.transparent;
            }),
            todayForegroundColor: WidgetStateProperty.all(
              AppTheme.lightTheme.colorScheme.primary,
            ),
            todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
            todayBorder: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _returnDate = picked;
        _dateError = null;
      });
      widget.onDatesSelected(_departureDate, _returnDate);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return "${date.month}/${date.day}/${date.year}";
  }

  int _getTripDuration() {
    if (_departureDate == null || _returnDate == null) return 0;
    return _returnDate!.difference(_departureDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Travel Dates",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: _buildDateCard(
                title: "Departure",
                date: _departureDate,
                onTap: _selectDepartureDate,
                icon: 'flight_takeoff',
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildDateCard(
                title: "Return",
                date: _returnDate,
                onTap: _selectReturnDate,
                icon: 'flight_land',
              ),
            ),
          ],
        ),
        if (_dateError != null) ...[
          SizedBox(height: 1.h),
          Text(
            _dateError!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
        if (_getTripDuration() > 0) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  "${_getTripDuration()} day${_getTripDuration() > 1 ? 's' : ''} trip",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateCard({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
    required String icon,
  }) {
    final bool hasDate = date != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: hasDate
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              _formatDate(date),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                color: hasDate
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
