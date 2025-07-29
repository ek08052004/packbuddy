import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../utils/auth_service.dart';
import '../login_screen/widgets/auth_button_widget.dart';
import '../login_screen/widgets/social_auth_button_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _listenToAuthChanges();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  void _listenToAuthChanges() {
    _authService.supabaseService.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn && mounted) {
        // Show success message and navigate
        Fluttertoast.showToast(
          msg: 'Welcome! Check your email for confirmation.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.tripDashboardScreen);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      Fluttertoast.showToast(
        msg: 'Please agree to the Terms and Privacy Policy',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if email already exists
      final emailExists =
          await _authService.emailExists(_emailController.text.trim());
      if (emailExists) {
        Fluttertoast.showToast(
          msg: 'This email is already registered. Please sign in instead.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        return;
      }

      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Account created! Welcome email sent. Please check your inbox.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushReplacementNamed(context, AppRoutes.tripDashboardScreen);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Signup failed. Please try again.';
        if (e.toString().contains('User already registered')) {
          errorMessage =
              'This email is already registered. Please sign in instead.';
        } else if (e
            .toString()
            .contains('Password should be at least 6 characters')) {
          errorMessage = 'Password must be at least 6 characters long.';
        } else if (e.toString().contains('Invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        }

        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.signInWithGoogle();
      if (response?.user != null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.tripDashboardScreen);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Google sign-up failed. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignup() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.signInWithApple();
      if (response?.user != null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.tripDashboardScreen);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Apple sign-up failed. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  children: [
                    SizedBox(height: 4.h),
                    _buildBackButton(),
                    SizedBox(height: 4.h),
                    _buildHeader(),
                    SizedBox(height: 4.h),
                    _buildSignupForm(),
                    SizedBox(height: 3.h),
                    _buildSocialSignup(),
                    SizedBox(height: 3.h),
                    _buildLoginPrompt(),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 36,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Create Account',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Join thousands of smart travelers',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildNameField(),
            SizedBox(height: 3.h),
            _buildEmailField(),
            SizedBox(height: 3.h),
            _buildPasswordField(),
            SizedBox(height: 3.h),
            _buildConfirmPasswordField(),
            SizedBox(height: 3.h),
            _buildTermsCheckbox(),
            SizedBox(height: 4.h),
            AuthButtonWidget(
              text: 'Create Account',
              onPressed: _isLoading ? null : _handleEmailSignup,
              isLoading: _isLoading,
              icon: Icons.person_add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'person',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppTheme.lightTheme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        if (value?.trim().isEmpty ?? true) {
          return 'Please enter your full name';
        }
        if (value!.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'email',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppTheme.lightTheme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Create a strong password',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'lock',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        filled: true,
        fillColor: AppTheme.lightTheme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter a password';
        }
        if (value!.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'lock',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        filled: true,
        fillColor: AppTheme.lightTheme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) =>
                setState(() => _agreeToTerms = value ?? false),
            activeColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Navigate to Terms of Service
                    },
                ),
                TextSpan(
                  text: ' and ',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Navigate to Privacy Policy
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSignup() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Divider(color: AppTheme.lightTheme.colorScheme.outline)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or sign up with',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
                child: Divider(color: AppTheme.lightTheme.colorScheme.outline)),
          ],
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: SocialAuthButtonWidget(
                provider: 'Google',
                icon: Icons.g_mobiledata,
                onPressed: _isLoading ? null : _handleGoogleSignup,
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                borderColor: Colors.grey.shade300,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: SocialAuthButtonWidget(
                provider: 'Apple',
                icon: Icons.apple,
                onPressed: _isLoading ? null : _handleAppleSignup,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Already have an account? ',
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(
            text: 'Sign In',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pop(context);
              },
          ),
        ],
      ),
    );
  }
}