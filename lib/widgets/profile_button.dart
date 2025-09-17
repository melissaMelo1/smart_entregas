import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_entregas/services/user_session.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:smart_entregas/routes/app_pages.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final userSession = Get.find<UserSession>();

    return IconButton(
      icon: const Icon(Icons.account_circle, color: Colors.white),
      onPressed: () {
        _showProfileOptions(context, userSession);
      },
    );
  }

  void _showProfileOptions(BuildContext context, UserSession userSession) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.loginPurple,
                  ),
                ),
              ),
              const Divider(),

              // Informações do usuário
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.loginPurple,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 15),

                    // Nome do usuário
                    Obx(
                      () => Text(
                        '${userSession.userData['nome'] ?? 'Nome não informado'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.loginPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Telefone do usuário
                    Obx(
                      () => Text(
                        'Telefone: ${userSession.userData['phoneNumber'] ?? 'Não disponível'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Tipo de usuário
                    Obx(
                      () => Text(
                        'Tipo: ${_formatUserType(userSession.getUserType())}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botão de sair
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmLogout(context, userSession),
                        icon: const Icon(Icons.logout),
                        label: const Text('Sair'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Formatar tipo de usuário para exibição
  String _formatUserType(String type) {
    if (type == 'commercial') {
      return 'Comercial';
    } else if (type == 'logistic') {
      return 'Logística';
    } else if (type == 'delivery') {
      return 'Entregador';
    } else {
      return 'Desconhecido';
    }
  }

  // Confirmar logout
  void _confirmLogout(BuildContext context, UserSession userSession) {
    Navigator.pop(context); // Fecha o modal

    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Tem certeza que deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Fecha o diálogo

              // Exibe loading
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              try {
                await userSession.signOut();
                Get.back(); // Fecha o loading
                Get.offAllNamed(AppPages.PHONE);
              } catch (e) {
                Get.back(); // Fecha o loading
                Get.snackbar(
                  'Erro',
                  'Não foi possível sair do aplicativo. Tente novamente.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
