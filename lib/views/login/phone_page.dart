import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:smart_entregas/theme/app_assets.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:smart_entregas/views/login/controller/auth_controller.dart';
import 'package:smart_entregas/views/login/otp_page.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.put(AuthController());

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendVerificationCode() async {
    print('🎯 _sendVerificationCode chamado no PhonePage');
    if (_formKey.currentState!.validate()) {
      print('✅ Formulário validado');
      print('📞 Número sem máscara: ${_phoneMaskFormatter.getUnmaskedText()}');
      
      print('⏳ Abrindo diálogo de loading...');
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      print('📡 Chamando authController.sendVerificationCode...');
      final result = await _authController.sendVerificationCode(
        _phoneMaskFormatter.getUnmaskedText(),
      );
      print('📥 Resultado recebido: $result');

      print('❌ Fechando diálogo de loading...');
      Get.back(); // Fecha o diálogo de carregamento
      print('✅ Diálogo fechado');

      if (result) {
        print('✅ Resultado true - navegando para OtpPage');
        Get.to(() => OtpPage());
      } else {
        print('❌ Resultado false - exibindo mensagem de erro');
        // Exibir o erro DEPOIS de fechar o loading
        Get.snackbar(
          'Acesso Negado',
          _authController.errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      print('❌ Formulário não validado');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo e imagem no topo
                      SvgPicture.asset(AppAssets.logoHome, height: 180),
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
                              // Título do app
                              Text(
                                'Digite um número de telefone para login',
                                style: TextStyle(
                                  color: AppTheme.loginPurple,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),

                              // Campo de telefone com underline
                              TextFormField(
                                controller: _phoneController,
                                inputFormatters: [_phoneMaskFormatter],
                                decoration: InputDecoration(
                                  hintText: '(11) 98765-4321',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.loginPurple.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppTheme.loginPurple,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 4,
                                    ),
                                  ),
                                  focusedErrorBorder:
                                      const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                          width: 4,
                                        ),
                                      ),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextStyle(fontSize: 16),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite seu telefone';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Botão de login
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _sendVerificationCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.loginPurple,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Texto informativo
                              Text(
                                'Certifique-se de inserir um número válido com DDD. Enviaremos um código por SMS.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}
