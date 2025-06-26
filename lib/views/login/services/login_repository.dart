import 'package:flutter/material.dart';

class LoginRepository {
  // Simulação de login - será substituída por Firebase Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulando um atraso na resposta da API
    await Future.delayed(const Duration(seconds: 1));

    // Simulação de validação básica
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email e senha são obrigatórios');
    }

    if (!email.contains('@')) {
      throw Exception('Email inválido');
    }

    if (password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    // Simula resposta de um servidor
    return {
      'success': true,
      'user': {'id': '123456', 'name': 'Usuário Teste', 'email': email},
      'token': 'token_simulado_123456789',
    };
  }

  // Simulação de reset de senha - será substituída por Firebase Auth
  Future<Map<String, dynamic>> resetPassword(String email) async {
    // Simulando um atraso na resposta da API
    await Future.delayed(const Duration(seconds: 1));

    // Simulação de validação básica
    if (email.isEmpty) {
      throw Exception('Email é obrigatório');
    }

    if (!email.contains('@')) {
      throw Exception('Email inválido');
    }

    // Simula resposta de um servidor
    return {
      'success': true,
      'message': 'Email de recuperação enviado para $email',
    };
  }

  // Simulação de logout - será substituída por Firebase Auth
  Future<Map<String, dynamic>> signOut() async {
    // Simulando um atraso na resposta da API
    await Future.delayed(const Duration(milliseconds: 500));

    // Simula resposta de um servidor
    return {'success': true, 'message': 'Logout realizado com sucesso'};
  }
}
