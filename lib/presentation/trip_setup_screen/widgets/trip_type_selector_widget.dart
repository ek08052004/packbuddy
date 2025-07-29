import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum TripType { business, leisure }

class TripTypeSelectorWidget extends StatefulWidget {
  final Function(TripType) onTripTypeSelected;
  final TripType? initialTripType;

  const TripTypeSelectorWidget({
    Key? key,
    required this.onTripTypeSelected,
    this.initialTripType,
  }) : super(key: key);

  @override
  State<TripTypeSelectorWidget> createState() => _TripTypeSelectorWidgetState();
}

class _TripTypeSelectorWidgetState extends State<TripTypeSelectorWidget> {
  TripType _selectedTripType = TripType.leisure;

  @override
  void initState() {
    super.initState();
    if (widget.initialTripType != null) {
      _selectedTripType = widget.initialTripType!;
    }
  }

  void _selectTripType(TripType tripType) {
    setState(() {
      _selectedTripType = tripType;
    });
    widget.onTripTypeSelected(tripType);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Trip Type",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: _buildTripTypeCard(
                tripType: TripType.business,
                title: "Business",
                subtitle: "Professional attire & essentials",
                icon: 'business_center',
                isSelected: _selectedTripType == TripType.business,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildTripTypeCard(
                tripType: TripType.leisure,
                title: "Leisure",
                subtitle: "Casual & vacation items",
                icon: 'beach_access',
                isSelected: _selectedTripType == TripType.leisure,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _buildTripTypeInfo(),
      ],
    );
  }

  Widget _buildTripTypeCard({
    required TripType tripType,
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectTripType(tripType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primaryContainer
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
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
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                const Spacer(),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.8)
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeInfo() {
    final Map<String, dynamic> tripTypeInfo =
        _selectedTripType == TripType.business
            ? {
                "title": "Business Trip Essentials",
                "items": [
                  "Formal attire & dress shoes",
                  "Business documents & laptop",
                  "Professional accessories",
                  "Meeting materials"
                ],
                "color": AppTheme.lightTheme.colorScheme.tertiary,
                "icon": "work"
              }
            : {
                "title": "Leisure Trip Essentials",
                "items": [
                  "Casual & comfortable clothing",
                  "Entertainment & camera",
                  "Outdoor activity gear",
                  "Relaxation items"
                ],
                "color": AppTheme.lightTheme.colorScheme.secondary,
                "icon": "vacation_rental"
              };

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: (tripTypeInfo["color"] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (tripTypeInfo["color"] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: tripTypeInfo["icon"] as String,
                color: tripTypeInfo["color"] as Color,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                tripTypeInfo["title"] as String,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tripTypeInfo["color"] as Color,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...(tripTypeInfo["items"] as List<String>)
              .map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: 'fiber_manual_record',
                          color: (tripTypeInfo["color"] as Color)
                              .withValues(alpha: 0.7),
                          size: 3.w,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
