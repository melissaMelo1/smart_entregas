import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Verifica se o usuário está cadastrado na collection preRegister
  Future<Map<String, dynamic>> _checkPreRegister(String phoneNumber) async {
    try {
      debugPrint('🔍 Iniciando verificação de preRegister para: $phoneNumber');
      final firestore = FirebaseFirestore.instance;

      // Buscar na collection preRegister pelo telefone
      debugPrint('📞 Buscando no Firestore...');
      final querySnapshot =
          await firestore
              .collection('preRegister')
              .where('telefone', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      debugPrint('📊 Documentos encontrados: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        debugPrint('❌ Usuário não encontrado na collection preRegister');
        return {'exists': false, 'active': false};
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final isActive = data['ativo'] ?? false;

      debugPrint('✅ Usuário encontrado! Ativo: $isActive');
      debugPrint('📄 Dados do documento: $data');

      return {'exists': true, 'active': isActive};
    } catch (e) {
      debugPrint('💥 Erro ao verificar preRegister: $e');
      throw Exception('Erro ao verificar cadastro: $e');
    }
  }

  // Envia o código de verificação para o número de telefone
  Future<bool> sendVerificationCode(String phoneNumber) async {
    debugPrint('🚀 Iniciando sendVerificationCode');
    debugPrint('📱 Número recebido: $phoneNumber');

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Formatar o número de telefone se necessário
      debugPrint('🔧 Formatando número de telefone...');
      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);
      debugPrint('✅ Número formatado: $formattedPhoneNumber');

      // Verificar se o usuário está cadastrado na collection preRegister
      debugPrint('🔐 Verificando preRegister...');
      final preRegisterCheck = await _checkPreRegister(formattedPhoneNumber);
      debugPrint('📋 Resultado da verificação: $preRegisterCheck');

      // Se não existe na collection preRegister
      if (!preRegisterCheck['exists']) {
        debugPrint('⛔ Usuário não existe na collection preRegister');
        isLoading.value = false;
        errorMessage.value = 'Usuário não cadastrado';
        debugPrint('❌ Retornando false - usuário não cadastrado');
        return false;
      }

      // Se existe mas está desativado
      if (!preRegisterCheck['active']) {
        debugPrint('⛔ Usuário existe mas está desativado');
        isLoading.value = false;
        errorMessage.value = 'Usuário desativado';
        debugPrint('❌ Retornando false - usuário desativado');
        return false;
      }

      // Se chegou aqui, o usuário está cadastrado e ativo - prosseguir com o envio do código
      debugPrint('✅ Usuário autorizado! Prosseguindo com envio do código...');

      // Salvar o número de telefone no modelo
      authData.value = AuthModel(phoneNumber: formattedPhoneNumber);
      debugPrint('💾 Número salvo no modelo');

      // Enviar o código de verificação
      debugPrint('📤 Enviando código de verificação via Firebase Auth...');
      final verificationId = await _repository.sendVerificationCode(
        formattedPhoneNumber,
      );
      debugPrint('✅ Código enviado! VerificationId: $verificationId');

      // Atualizar o modelo com o ID de verificação
      authData.value = authData.value.copyWith(verificationId: verificationId);
      debugPrint('💾 VerificationId salvo no modelo');

      isLoading.value = false;
      debugPrint('✅ Loading finalizado - retornando true');
      return true;
    } catch (e) {
      debugPrint('💥 ERRO capturado no sendVerificationCode: $e');
      debugPrint('📍 Stack trace: ${StackTrace.current}');
      isLoading.value = false;
      errorMessage.value = e.toString();
      FirebaseErrorHandler.showErrorMessage(e);
      debugPrint('❌ Retornando false - erro na execução');
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
