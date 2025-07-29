import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditableFieldWidget extends StatefulWidget {
  final String title;
  final String value;
  final String? iconName;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool showDivider;

  const EditableFieldWidget({
    super.key,
    required this.title,
    required this.value,
    this.iconName,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.showDivider = true,
  });

  @override
  State<EditableFieldWidget> createState() => _EditableFieldWidgetState();
}

class _EditableFieldWidgetState extends State<EditableFieldWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _errorText = null;
    });
  }

  void _saveChanges() {
    final newValue = _controller.text.trim();

    if (widget.validator != null) {
      final error = widget.validator!(newValue);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }

    widget.onChanged(newValue);
    setState(() {
      _isEditing = false;
      _errorText = null;
    });
  }

  void _cancelEditing() {
    _controller.text = widget.value;
    setState(() {
      _isEditing = false;
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.iconName != null) ...[
                    CustomIconWidget(
                      iconName: widget.iconName!,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: 3.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        _isEditing
                            ? TextFormField(
                                controller: _controller,
                                keyboardType: widget.keyboardType,
                                autofocus: true,
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 3.w, vertical: 1.h),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                    ),
                                  ),
                                ),
                                onFieldSubmitted: (_) => _saveChanges(),
                              )
                            : Text(
                                widget.value.isEmpty ? 'Not set' : widget.value,
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  color: widget.value.isEmpty
                                      ? AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                  fontStyle: widget.value.isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  if (_isEditing) ...[
                    IconButton(
                      onPressed: _cancelEditing,
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: _saveChanges,
                      icon: CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ] else
                    IconButton(
                      onPressed: _startEditing,
                      icon: CustomIconWidget(
                        iconName: 'edit',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                ],
              ),
              if (_errorText != null) ...[
                SizedBox(height: 1.h),
                Text(
                  _errorText!,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.lightTheme.dividerColor,
            indent: widget.iconName != null ? 15.w : 4.w,
            endIndent: 4.w,
          ),
      ],
    );
  }
}