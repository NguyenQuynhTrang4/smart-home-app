import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  User? user;

  Future<void> login(String email, String password) async {
    user = await _authService.login(email, password);
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    user = await _authService.register(email, password);
    notifyListeners();
  }

  void logout() {
    _authService.logout();
    user = null;
    notifyListeners();
  }
}