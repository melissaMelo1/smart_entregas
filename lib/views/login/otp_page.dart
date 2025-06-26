import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_entregas/routes/app_pages.dart';
import 'package:smart_entregas/services/user_session.dart';
import 'package:smart_entregas/theme/app_assets.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:smart_entregas/views/login/controller/auth_controller.dart';

class OtpPage extends StatelessWidget {
  final _pinController = TextEditingController();
  final _authController = Get.find<AuthController>();
  final _userSession = Get.find<UserSession>();
  final _formKey = GlobalKey<FormState>();

  OtpPage({super.key});

  void _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      final result = await _authController.verifyOtp(
        _pinController.text.trim(),
      );

      Get.back(); // Fecha o diálogo de carregamento

      if (result) {
        print('OTP verificado com sucesso');

        // Garantir que o UserSession tenha dados atualizados
        // Carregar explicitamente os dados completos do usuário
        await _userSession.refreshUserData();

        // Aguardar um momento adicional para garantir que os dados foram atualizados
        await Future.delayed(Duration(milliseconds: 1000));

        // Verificar se o usuário tem perfil completo (tipo e nome definidos)
        final hasCompleteProfile = _userSession.hasCompleteProfile();
        final hasType = _userSession.hasDefinedUserType();
        final hasName = _userSession.hasDefinedName();
        final userType = _userSession.getUserType();

        print(
          'Verificação de perfil após OTP: hasCompleteProfile=$hasCompleteProfile, '
          'hasType=$hasType, hasName=$hasName, userType=$userType',
        );

        if (hasCompleteProfile) {
          print(
            'Usuário tem perfil completo. Redirecionando para a tela apropriada.',
          );
          // Se já tem tipo e nome, redirecionar para a tela correspondente
          switch (userType) {
            case 'commercial':
              Get.offAllNamed(AppPages.COMMERCIAL);
              break;
            case 'logistic':
              Get.offAllNamed(AppPages.LOGISTIC);
              break;
            case 'delivery':
              Get.offAllNamed(AppPages.DELIVERY);
              break;
            default:
              // Tipo desconhecido
              Get.offAllNamed(AppPages.REGISTER);
          }
        } else {
          print(
            'Usuário não tem perfil completo. Redirecionando para registro.',
          );
          // Se não tem perfil completo (tipo e nome), redirecionar para a tela de registro
          Get.offAllNamed(AppPages.REGISTER);
        }
      } else {
        Get.snackbar(
          'Erro',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppTheme.loginPurple.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.loginPurple, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Forma circular roxa superior esquerda
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.loginPurple.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Forma circular roxa escura superior esquerda (mais pequena)
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.loginPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Forma circular roxa inferior direita
          Positioned(
            bottom: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.loginPurple.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Forma circular roxa escura inferior direita (mais pequena)
          Positioned(
            bottom: -80,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.loginPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Conteúdo principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Botão voltar
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.loginPurple,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo no topo
                            SvgPicture.asset(AppAssets.logoHome, height: 120),
                            const SizedBox(height: 15),

                            // Card branco com formulário
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Título
                                    Text(
                                      'Verificação de Código',
                                      style: TextStyle(
                                        color: AppTheme.loginPurple,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Número de telefone
                                    Obx(
                                      () => Text(
                                        'Código enviado para ${_authController.authData.value.phoneNumber}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Campo para digitar o código
                                    Pinput(
                                      controller: _pinController,
                                      length: 6,
                                      defaultPinTheme: defaultPinTheme,
                                      focusedPinTheme: focusedPinTheme,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Digite o código de verificação';
                                        }
                                        if (value.length != 6) {
                                          return 'O código deve ter 6 dígitos';
                                        }
                                        return null;
                                      },
                                      onCompleted: (_) => _verifyOtp(),
                                    ),
                                    const SizedBox(height: 10),

                                    // Botão de verificação
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _verifyOtp,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.loginPurple,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Verificar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Texto informativo e reenviar
                                    Text(
                                      'Não recebeu o código?',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Reenviar código
                                        _authController.sendVerificationCode(
                                          _authController
                                              .authData
                                              .value
                                              .phoneNumber,
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.loginPurple,
                                      ),
                                      child: const Text(
                                        'Reenviar código',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
