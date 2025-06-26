import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_entregas/routes/app_pages.dart';
import 'package:smart_entregas/theme/app_assets.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_entregas/services/user_session.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Lista de tipos de usuário disponíveis
  final List<Map<String, dynamic>> _userTypes = [
    {'type': 'commercial', 'label': 'Comercial'},
    {'type': 'logistic', 'label': 'Logística'},
    {'type': 'delivery', 'label': 'Entregador'},
  ];

  // Controle da seleção de tipo de usuário
  int _selectedUserTypeIndex = 0;

  final UserSession _userSession = Get.find<UserSession>();
  final TextEditingController _nomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
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
                      const SizedBox(height: 20),
                      // Logo e imagem no topo
                      Center(
                        child: SvgPicture.asset(
                          AppAssets.logoHome,
                          height: 180,
                        ),
                      ),
                      const SizedBox(height: 8),

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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título com opções de seleção
                              Text(
                                'Selecione seu perfil:',
                                style: TextStyle(
                                  color: AppTheme.loginPurple,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Seleção de tipo de usuário
                              Column(
                                children:
                                    _userTypes.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      Map<String, dynamic> userType =
                                          entry.value;
                                      bool isSelected =
                                          _selectedUserTypeIndex == index;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedUserTypeIndex = index;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? AppTheme.loginPurple
                                                      : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? AppTheme.loginPurple
                                                        : Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  _getIconForUserType(
                                                    userType['type'],
                                                  ),
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : AppTheme
                                                              .loginPurple,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  userType['label'],
                                                  style: TextStyle(
                                                    color:
                                                        isSelected
                                                            ? Colors.white
                                                            : Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),

                              // Campo nome
                              TextFormField(
                                controller: _nomeController,
                                decoration: InputDecoration(
                                  labelText: 'Nome',
                                  hintText: 'Digite seu nome completo',
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 0.0,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.grey,
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
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, digite seu nome';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Botão de cadastro
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _registerUserType,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.loginPurple,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cadastrar',
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
                                'Preencha seus dados para completar o cadastro no aplicativo.',
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

  IconData _getIconForUserType(String userType) {
    switch (userType) {
      case 'commercial':
        return Icons.store;
      case 'logistic':
        return Icons.manage_accounts;
      case 'delivery':
        return Icons.delivery_dining;
      default:
        return Icons.person;
    }
  }

  // Atualizar o onPressed do botão de cadastro para salvar o tipo de usuário
  void _registerUserType() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userType = _userTypes[_selectedUserTypeIndex]['type'];
    final nome = _nomeController.text.trim();

    try {
      // Mostrar indicador de carregamento
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // Criar o mapa de dados a serem salvos
      final userData = {
        'userType': userType,
        'nome': nome,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Salvar dados do usuário no Firestore
      await _userSession.updateUserData(userData);

      // Fechar o diálogo de carregamento
      Get.back();

      // Redirecionar para a tela apropriada
      _redirectToProperScreen(userType);
    } catch (e) {
      // Fechar o diálogo de carregamento em caso de erro
      Get.back();

      // Mostrar erro
      Get.snackbar(
        'Erro',
        'Não foi possível registrar seu perfil: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _redirectToProperScreen(String userType) {
    switch (userType) {
      case 'commercial':
        Get.offAllNamed(AppPages.COMMERCIAL);
        break;
      case 'logistic':
        Get.offAllNamed(AppPages.LOGISTIC);
        break;
      case 'delivery':
        Get.offAllNamed(AppPages.DELIVERY); // Nova rota para entregador
        break;
      default:
        Get.offAllNamed(AppPages.REGISTER);
    }
  }
}
