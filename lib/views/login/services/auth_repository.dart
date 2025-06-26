import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Envia o código de verificação para o número de telefone fornecido
  Future<String> sendVerificationCode(String phoneNumber) async {
    try {
      final completer = Completer<String>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verificação em alguns dispositivos Android
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Erro na verificação: ${e.message}');
          completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      debugPrint('Erro ao enviar o código: $e');
      throw Exception('Falha ao enviar o código de verificação: $e');
    }
  }

  // Verifica o código enviado pelo usuário
  Future<UserCredential> verifyOtp(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Erro ao verificar OTP: $e');
      throw Exception('Código de verificação inválido: $e');
    }
  }

  // Desconecta o usuário atual
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erro ao desconectar: $e');
      throw Exception('Falha ao desconectar: $e');
    }
  }

  // Verifica se o usuário está autenticado
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Obtém o usuário atual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
