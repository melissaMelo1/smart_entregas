import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:smart_entregas/routes/app_pages.dart';
import 'package:smart_entregas/services/user_session.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:smart_entregas/views/login/phone_page.dart';
import 'package:smart_entregas/widgets/app_scaffold.dart';
import 'package:smart_entregas/widgets/version_badge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o Firebase
  await Firebase.initializeApp();

  // Inicializar o GetStorage para persistência
  await GetStorage.init();

  // Registrar o serviço UserSession
  final userSession = Get.put(UserSession(), permanent: true);

  // Aguardar a inicialização dos dados do usuário
  await userSession.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      useDefaultLoading: false,
      overlayWidgetBuilder:
          (_) => Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
      child: GetMaterialApp(
        title: 'Smart Entregas',
        theme: AppTheme.lightTheme,
        initialRoute: _getInitialRoute(),
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Material(
            child: Stack(
              children: [
                child ?? const SizedBox.shrink(),
                const VersionBadge(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Determinar a rota inicial com base no estado de autenticação
  String _getInitialRoute() {
    final userSession = Get.find<UserSession>();

    // Verificar se o usuário está logado
    if (userSession.checkIsLoggedIn()) {
      print('Usuário logado. Verificando tipo...');

      // Verificar se o tipo está definido
      if (userSession.hasDefinedUserType()) {
        final userType = userSession.getUserType();
        print('Tipo de usuário encontrado: $userType');

        // Redirecionar com base no tipo
        switch (userType) {
          case 'commercial':
            return AppPages.COMMERCIAL;
          case 'logistic':
            return AppPages.LOGISTIC;
          case 'delivery':
            return AppPages.DELIVERY;
          default:
            return AppPages.REGISTER;
        }
      } else {
        print('Tipo de usuário não definido. Redirecionando para registro.');
        return AppPages.REGISTER;
      }
    }

    print('Usuário não logado. Redirecionando para tela de login.');
    return AppPages.PHONE;
  }
}
