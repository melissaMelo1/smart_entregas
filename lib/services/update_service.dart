import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/material.dart';

class UpdateService extends GetxController {
  // Singleton
  static UpdateService get to => Get.find<UpdateService>();

  final RxBool isUpdateAvailable = false.obs;
  final Rx<AppUpdateInfo?> _updateInfo = Rx<AppUpdateInfo?>(null);

  @override
  void onReady() {
    super.onReady();
    checkForUpdate();
  }

  /// Verifica se há atualizações disponíveis na Play Store
  Future<void> checkForUpdate() async {
    print('Verificando atualizações...');
    try {
      final info = await InAppUpdate.checkForUpdate();
      _updateInfo.value = info;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        print('Atualização disponível!');
        isUpdateAvailable.value = true;
        
        // Tenta realizar a atualização imediata se disponível
        if (info.immediateUpdateAllowed) {
          print('Iniciando atualização imediata...');
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Se preferir flexível, descomente abaixo ou implemente lógica de escolha
          // await InAppUpdate.startFlexibleUpdate();
          // await InAppUpdate.completeFlexibleUpdate(); 
          print('Atualização flexível disponível, mas priorizando imediata neste fluxo.');
        }
      } else {
        print('Nenhuma atualização disponível.');
        isUpdateAvailable.value = false;
      }
    } catch (e) {
      print('Erro ao verificar atualização: $e');
      // O erro pode ocorrer em emuladores ou builds não publicados
    }
  }
}
