import 'package:flutter/material.dart';
import '../services/login_repository.dart';

class LoginController {
  final LoginRepository _repository = LoginRepository();

  Future<bool> login(String email, String password) async {
    try {
      // Futuramente aqui usaremos Firebase Auth
      final result = await _repository.login(email, password);
      debugPrint('Login realizado com sucesso: $result');
      return true;
    } catch (e) {
      debugPrint('Erro ao realizar login: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      // Futuramente aqui usaremos Firebase Auth para reset de senha
      final result = await _repository.resetPassword(email);
      debugPrint('Solicitação de reset de senha enviada: $result');
      return true;
    } catch (e) {
      debugPrint('Erro ao solicitar reset de senha: $e');
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      // Futuramente aqui usaremos Firebase Auth para logout
      final result = await _repository.signOut();
      debugPrint('Logout realizado com sucesso: $result');
      return true;
    } catch (e) {
      debugPrint('Erro ao realizar logout: $e');
      return false;
    }
  }
}
