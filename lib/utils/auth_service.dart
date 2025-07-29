import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final Dio _dio = Dio();

  // Google Sign In configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final client = await _supabaseService.client;

      final response =
          await client.auth.signUp(email: email, password: password, data: {
        'full_name': fullName,
      });

      // Send welcome email if signup is successful
      if (response.user != null) {
        await _sendWelcomeEmail(email, fullName);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final client = await _supabaseService.client;

      return await client.auth
          .signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign In
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final client = await _supabaseService.client;

      // Web-based OAuth for Flutter Web, native for mobile
      if (kIsWeb) {
        await client.auth.signInWithOAuth(OAuthProvider.google,
            redirectTo: '${SupabaseService.supabaseUrl}/auth/v1/callback');
        return null;
      } else {
        // Native Google Sign In for mobile
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        return await client.auth.signInWithIdToken(
            provider: OAuthProvider.google, idToken: googleAuth.idToken!);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Apple Sign In
  Future<AuthResponse?> signInWithApple() async {
    try {
      final client = await _supabaseService.client;

      if (kIsWeb) {
        // Web-based OAuth for Apple
        await client.auth.signInWithOAuth(OAuthProvider.apple,
            redirectTo: '${SupabaseService.supabaseUrl}/auth/v1/callback');
        return null;
      } else {
        // Native Apple Sign In
        final credential = await SignInWithApple.getAppleIDCredential(scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ]);

        return await client.auth.signInWithIdToken(
            provider: OAuthProvider.apple, idToken: credential.identityToken!);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final client = await _supabaseService.client;
      await client.auth.signOut();

      // Also sign out from Google if needed
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Send welcome email via Edge Function
  Future<void> _sendWelcomeEmail(String email, String fullName) async {
    try {
      final supabaseUrl = SupabaseService.supabaseUrl;
      final anonKey = SupabaseService.supabaseAnonKey;
      final edgeFunctionUrl = '$supabaseUrl/functions/v1/send-welcome-email';

      _dio.options.headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $anonKey',
      };

      await _dio.post(edgeFunctionUrl, data: {
        'email': email,
        'fullName': fullName,
      });
    } catch (e) {
      // Silent fail for email - don't block signup process
      debugPrint('Welcome email failed to send: $e');
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) return null;

      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) throw Exception('No authenticated user');

      await client.from('user_profiles').update({
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('user_profiles')
          .select('id')
          .eq('email', email.toLowerCase())
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}