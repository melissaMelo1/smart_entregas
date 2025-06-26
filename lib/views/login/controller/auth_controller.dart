import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_entregas/services/user_session.dart';
import 'package:smart_entregas/utils/firebase_error_handler.dart';
import '../models/auth_model.dart';
import '../services/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final UserSession _userSession = Get.find<UserSession>();

  final Rx<AuthModel> authData = AuthModel(phoneNumber: '').obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Envia o código de verificação para o número de telefone
  Future<bool> sendVerificationCode(String phoneNumber) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Formatar o número de telefone se necessário
      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

      // Salvar o número de telefone no modelo
      authData.value = AuthModel(phoneNumber: formattedPhoneNumber);

      // Enviar o código de verificação
      final verificationId = await _repository.sendVerificationCode(
        formattedPhoneNumber,
      );

      // Atualizar o modelo com o ID de verificação
      authData.value = authData.value.copyWith(verificationId: verificationId);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      FirebaseErrorHandler.showErrorMessage(e);
      return false;
    }
  }

  // Verifica o código OTP inserido pelo usuário
  Future<bool> verifyOtp(String smsCode) async {
    if (authData.value.verificationId == null) {
      errorMessage.value = 'ID de verificação não encontrado. Tente novamente.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Verificar o código OTP
      final UserCredential userCredential = await _repository.verifyOtp(
        authData.value.verificationId!,
        smsCode,
      );

      // Atualizar o modelo com o UID do usuário
      authData.value = authData.value.copyWith(uid: userCredential.user?.uid);

      // Atualizar o UserSession com os dados do usuário
      if (userCredential.user != null) {
        try {
          final userData = {
            'uid': userCredential.user?.uid,
            'phoneNumber': userCredential.user?.phoneNumber,
            'lastLogin': DateTime.now().toIso8601String(),
          };

          await _userSession.updateUserData(userData);

          // Forçar a inicialização para carregar dados do Firestore
          await _userSession.initialize();

          // Verificar e imprimir informações para debug
          print('Login bem-sucedido. UID: ${userCredential.user?.uid}');
          print('UserSession dados: ${_userSession.userData}');
          print(
            'UserSession tem tipo definido: ${_userSession.hasDefinedUserType()}',
          );
          print('UserSession tipo: ${_userSession.getUserType()}');
        } catch (e) {
          print('Erro ao atualizar dados do usuário após OTP: $e');
          // Continuar mesmo com erro na atualização dos dados
        }
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      FirebaseErrorHandler.showErrorMessage(e);
      return false;
    }
  }

  // Desconecta o usuário atual
  Future<bool> signOut() async {
    isLoading.value = true;

    try {
      await _userSession.signOut();
      authData.value = AuthModel(phoneNumber: '');
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      FirebaseErrorHandler.showErrorMessage(e);
      return false;
    }
  }

  // Verifica se o usuário está autenticado
  bool isUserLoggedIn() {
    return _userSession.checkIsLoggedIn();
  }

  // Formata o número de telefone conforme necessário
  String _formatPhoneNumber(String phoneNumber) {
    // Remover espaços, parênteses, traços e outros caracteres não numéricos
    var formatted = phoneNumber.replaceAll(RegExp(r'[\s\(\)\-]'), '');

    // Se o número começar com 0, removê-lo
    if (formatted.startsWith('0')) {
      formatted = formatted.substring(1);
    }

    // Garantir que o número tenha o código do país
    if (!formatted.startsWith('+')) {
      // Adicionar +55 (Brasil) como padrão se não tiver código do país
      formatted = '+55$formatted';
    }

    debugPrint('Número formatado: $formatted');
    return formatted;
  }
}
