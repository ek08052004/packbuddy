import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum Gender { male, female, other }

class GenderSelectorWidget extends StatefulWidget {
  final Function(Gender) onGenderSelected;
  final Gender? initialGender;

  const GenderSelectorWidget({
    Key? key,
    required this.onGenderSelected,
    this.initialGender,
  }) : super(key: key);

  @override
  State<GenderSelectorWidget> createState() => _GenderSelectorWidgetState();
}

class _GenderSelectorWidgetState extends State<GenderSelectorWidget> {
  Gender _selectedGender = Gender.male;

  @override
  void initState() {
    super.initState();
    if (widget.initialGender != null) {
      _selectedGender = widget.initialGender!;
    }
  }

  void _selectGender(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onGenderSelected(gender);
  }

  String _getGenderLabel(Gender gender) {
    switch (gender) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
      case Gender.other:
        return "Other";
    }
  }

  String _getGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.male:
        return "male";
      case Gender.female:
        return "female";
      case Gender.other:
        return "person";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          "This helps us provide better clothing recommendations",
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: Gender.values.map((gender) {
              final isSelected = _selectedGender == gender;
              final isFirst = gender == Gender.values.first;
              final isLast = gender == Gender.values.last;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectGender(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: isFirst ? const Radius.circular(11) : Radius.zero,
                        right: isLast ? const Radius.circular(11) : Radius.zero,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: _getGenderIcon(gender),
                          color: isSelected
                              ? Colors.white
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 6.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _getGenderLabel(gender),
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 2.h),
        _buildGenderInfo(),
      ],
    );
  }

  Widget _buildGenderInfo() {
    final Map<String, dynamic> genderInfo = _getGenderSpecificInfo();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  genderInfo["title"] as String,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  genderInfo["description"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getGenderSpecificInfo() {
    switch (_selectedGender) {
      case Gender.male:
        return {
          "title": "Male Clothing Recommendations",
          "description":
              "We'll suggest appropriate men's clothing, accessories, and grooming essentials based on your destination's weather and cultural norms."
        };
      case Gender.female:
        return {
          "title": "Female Clothing Recommendations",
          "description":
              "We'll suggest appropriate women's clothing, accessories, and beauty essentials based on your destination's weather and cultural considerations."
        };
      case Gender.other:
        return {
          "title": "Inclusive Clothing Recommendations",
          "description":
              "We'll provide versatile clothing and accessory suggestions that work for all gender expressions, focusing on comfort and weather appropriateness."
        };
    }
  }
}
