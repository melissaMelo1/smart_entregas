import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseErrorHandler {
  static void showErrorMessage(dynamic error) {
    String message = 'Ocorreu um erro inesperado';

    if (error is FirebaseAuthException) {
      message = _getFirebaseAuthErrorMessage(error);
    } else if (error is Exception) {
      message = error.toString().replaceAll('Exception: ', '');
    }

    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  static String _getFirebaseAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'O número de telefone fornecido é inválido.';
      case 'invalid-verification-code':
        return 'O código de verificação é inválido. Tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'session-expired':
        return 'A sessão de verificação expirou. Solicite um novo código.';
      case 'quota-exceeded':
        return 'Limite de verificações excedido. Tente novamente mais tarde.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Entre em contato com o suporte.';
      case 'operation-not-allowed':
        return 'A autenticação por telefone não está habilitada.';
      default:
        return error.message ?? 'Erro desconhecido: ${error.code}';
    }
  }
}
