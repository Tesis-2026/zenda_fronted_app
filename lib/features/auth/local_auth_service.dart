import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/user.dart';
import 'package:crypto/crypto.dart';

class LocalAuthService {
  static const String _currentUserEmailKey = 'current_user_email';
  static const String _usersJsonKey = 'users_json';

  /// Simple hash function for password (demo purposes)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get all users from local storage
  Future<Map<String, Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersJsonKey);
    
    if (usersJson == null || usersJson.isEmpty) {
      return {};
    }
    
    try {
      final decoded = json.decode(usersJson) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
    } catch (e) {
      return {};
    }
  }

  /// Save users to local storage
  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(users);
    await prefs.setString(_usersJsonKey, usersJson);
  }

  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      return AuthResult.error('El nombre no puede estar vacío');
    }
    
    if (!_isValidEmail(email)) {
      return AuthResult.error('Email inválido');
    }
    
    if (password.length < 6) {
      return AuthResult.error('La contraseña debe tener al menos 6 caracteres');
    }

    final users = await _getUsers();
    final normalizedEmail = email.trim().toLowerCase();

    // Check if user already exists
    if (users.containsKey(normalizedEmail)) {
      return AuthResult.error('Este email ya está registrado');
    }

    // Create new user
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = User(
      id: userId,
      name: name.trim(),
      email: normalizedEmail,
    );

    // Save user with hashed password
    users[normalizedEmail] = {
      ...user.toJson(),
      'passwordHash': _hashPassword(password),
    };

    await _saveUsers(users);

    // Set as current user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserEmailKey, normalizedEmail);

    return AuthResult.success(user);
  }

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    final normalizedEmail = email.trim().toLowerCase();

    // Check if user exists
    if (!users.containsKey(normalizedEmail)) {
      return AuthResult.error('Usuario no existe');
    }

    final userData = users[normalizedEmail]!;
    final storedHash = userData['passwordHash'] as String;
    final inputHash = _hashPassword(password);

    // Verify password
    if (storedHash != inputHash) {
      return AuthResult.error('Contraseña incorrecta');
    }

    // Set as current user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserEmailKey, normalizedEmail);

    final user = User.fromJson(userData);
    return AuthResult.success(user);
  }

  /// Get current logged in user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentUserEmailKey);

    if (currentEmail == null) {
      return null;
    }

    final users = await _getUsers();
    if (!users.containsKey(currentEmail)) {
      // User was deleted, clear session
      await logout();
      return null;
    }

    return User.fromJson(users[currentEmail]!);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Logout current user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
  }

  /// Email validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }
}

/// Result class for auth operations
class AuthResult {
  final User? user;
  final String? error;
  final bool isSuccess;

  AuthResult._({this.user, this.error, required this.isSuccess});

  factory AuthResult.success(User user) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(error: message, isSuccess: false);
  }
}
