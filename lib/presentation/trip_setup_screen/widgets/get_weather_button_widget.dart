import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GetWeatherButtonWidget extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  const GetWeatherButtonWidget({
    Key? key,
    this.onPressed,
    required this.isEnabled,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<GetWeatherButtonWidget> createState() => _GetWeatherButtonWidgetState();
}

class _GetWeatherButtonWidgetState extends State<GetWeatherButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: widget.isEnabled && !widget.isLoading
                      ? LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary,
                            AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !widget.isEnabled || widget.isLoading
                      ? AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isEnabled && !widget.isLoading
                      ? [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                    ] else ...[
                      CustomIconWidget(
                        iconName: 'cloud',
                        color: widget.isEnabled
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                    ],
                    Text(
                      widget.isLoading
                          ? "Getting Weather Data..."
                          : "Get Weather & Pack",
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.isEnabled
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                      ),
                    ),
                    if (!widget.isLoading) ...[
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: widget.isEnabled
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                        size: 5.w,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
