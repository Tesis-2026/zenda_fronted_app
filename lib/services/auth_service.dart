import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  String? _userId;
  String? _name;
  String? _email;

  bool get isLoggedIn => _userId != null;
  String? get userId => _userId;
  String? get name => _name;
  String? get email => _email;

  Future<bool> login(String email, String password) async {
    // fake delay
    await Future.delayed(const Duration(milliseconds: 400));
    // Accept any non-empty credentials for MVP
    if (email.isNotEmpty && password.isNotEmpty) {
      _userId = 'user-1';
      _name = 'Usuario Zenda';
      _email = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _userId = 'user-1';
      _name = name;
      _email = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _userId = null;
    _name = null;
    _email = null;
    notifyListeners();
  }
}

