import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_user.dart';
import '../../domain/usecases/auth/register_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _user != null && _status == AuthStatus.authenticated;

  AuthProvider({
    required this.loginUser,
    required this.registerUser,
    required this.authRepository,
  }) {
    _checkInitialAuthStatus();
  }

  Future<void> _checkInitialAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();
    final result = await authRepository.getLoggedInUser();
    result.fold(
      (failure) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        _errorMessage = failure.message;
      },
      (user) {
        _user = user;
        _status = user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
      },
    );
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result =
        await loginUser(LoginParams(email: email, password: password));

    _handleAuthResult(result);
  }

  Future<void> register(String name, String email, String password,
      {String? profileImagePath}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await registerUser(RegisterParams(
        name: name,
        email: email,
        password: password,
        profileImagePath: profileImagePath));

    _handleAuthResult(result);
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await authRepository.logout();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = AuthStatus.error;
      },
      (_) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      },
    );
    notifyListeners();
  }

  void _handleAuthResult(Either<Failure, User> result) {
    result.fold(
      (failure) {
        _user = null;
        _status = AuthStatus.error;
        _errorMessage = failure.message;
      },
      (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
      },
    );
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String email,
      {String? profileImagePath}) async {
    if (_user == null) {
      _errorMessage = 'Utilisateur non connecté';
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.updateProfile(_user!.id, name, email,
        profileImagePath: profileImagePath);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = AuthStatus.authenticated; // Garder l'état authentifié
        notifyListeners();
        return false;
      },
      (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }
}
