import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/users.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  /// 🔒 HASH PASSWORD
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// ================= REGISTER =================
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        return "Passwords do not match";
      }

      final existing = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        return "Username already exists";
      }

      final hashedPassword = _hashPassword(password);

      final inserted = await _supabase.from('users').insert({
        'username': username.trim(),
        'email': email.trim(),
        'password': hashedPassword,
      }).select().single();

      _currentUser = AppUser.fromMap(inserted);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// ================= LOGIN =================
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await _supabase
          .from('users')
          .select()
          .eq('username', username.trim())
          .maybeSingle();

      if (user == null) {
        return "Invalid username or password";
      }

      final hashedPassword = _hashPassword(password);

      if (user['password'] != hashedPassword) {
        return "Invalid username or password";
      }

      _currentUser = AppUser.fromMap(user);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    _currentUser = null;
  }
}