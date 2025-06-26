import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_entregas/routes/app_pages.dart';

class UserSession extends GetxController {
  // Instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Instância do GetStorage para persistência
  final GetStorage _storage = GetStorage();

  // Chave para salvar os dados do usuário no GetStorage
  static const String _userKey = 'user_data';

  // Dados observáveis do usuário
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxMap<String, dynamic> userData = RxMap<String, dynamic>({});
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;

  // Singleton pattern para garantir uma única instância
  static UserSession get to => Get.find<UserSession>();

  // Flag para rastrear a inicialização
  final RxBool _initialized = false.obs;

  // Método para inicializar os dados do usuário
  Future<void> initialize() async {
    try {
      // Se já inicializado, retornar
      if (_initialized.value) return;

      print('Inicializando UserSession...');

      // Carregar dados do armazenamento local
      _loadUserData();

      // Verificar se existe um usuário logado no Firebase
      final user = _auth.currentUser;
      if (user != null) {
        print('Usuário do Firebase encontrado: ${user.uid}');
        // Atualizar o usuário atual
        currentUser.value = user;

        // Verificar se temos os dados básicos do usuário
        if (!userData.containsKey('uid') || userData['uid'] != user.uid) {
          print('Atualizando dados básicos do usuário');
          // Atualizar informações básicas
          userData.value = {
            'uid': user.uid,
            'phoneNumber': user.phoneNumber,
            'lastLogin': DateTime.now().toIso8601String(),
          };
          _saveUserData();
        }

        // Carregar dados do Firestore
        print('Carregando dados do Firestore');
        try {
          await _loadAdditionalUserData(user.uid);
        } catch (e) {
          print(
            'Erro ao carregar dados do Firestore durante inicialização: $e',
          );
          // Continuar mesmo com erro
        }

        // Marcar como logado
        isLoggedIn.value = true;
      } else {
        print('Nenhum usuário do Firebase encontrado');
        isLoggedIn.value = false;
      }

      // Marcar como inicializado independentemente de erros
      _initialized.value = true;
      print('UserSession inicializado com sucesso.');
      print('Dados do usuário: $userData');
      print('Usuário está logado: ${isLoggedIn.value}');
      print('Tipo de usuário: ${getUserType()}');
    } catch (e) {
      print('Erro ao inicializar UserSession: $e');
      // Marcar como inicializado mesmo com erro para não bloquear o app
      _initialized.value = true;

      // Garantir que temos um estado consistente
      final user = _auth.currentUser;
      if (user != null) {
        isLoggedIn.value = true;
      } else {
        isLoggedIn.value = false;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Escutar mudanças de estado de autenticação
    _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  // Carregar dados do usuário do armazenamento
  void _loadUserData() {
    try {
      final savedData = _storage.read(_userKey);
      if (savedData != null) {
        userData.value = Map<String, dynamic>.from(savedData);
        isLoggedIn.value = true;
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  // Lidar com mudanças no estado de autenticação
  void _handleAuthStateChange(User? user) async {
    try {
      currentUser.value = user;

      if (user != null) {
        // Usuário autenticado
        isLoggedIn.value = true;

        // Atualizar informações básicas do usuário
        userData.value = {
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'lastLogin': DateTime.now().toIso8601String(),
        };

        // Persistir dados
        _saveUserData();

        // Carregar dados adicionais do usuário do Firestore
        try {
          await _loadAdditionalUserData(user.uid);
        } catch (e) {
          print('Erro ao carregar dados adicionais do Firestore: $e');
          // Continuar mesmo com erro, usando apenas os dados básicos
        }
      } else {
        // Usuário deslogado
        isLoggedIn.value = false;
        userData.clear();
        _storage.remove(_userKey);
      }
    } catch (e) {
      print('Erro no _handleAuthStateChange: $e');
      // Garantir que o estado seja consistente mesmo em caso de erro
      if (user == null) {
        isLoggedIn.value = false;
        userData.clear();
      }
    }
  }

  // Salvar dados do usuário no armazenamento local
  void _saveUserData() {
    try {
      _storage.write(_userKey, userData.value);
    } catch (e) {
      print('Erro ao salvar dados do usuário: $e');
    }
  }

  // Carregar dados adicionais do usuário do Firestore
  Future<void> _loadAdditionalUserData(String uid) async {
    try {
      print(
        'Iniciando carregamento de dados adicionais do Firestore para UID: $uid',
      );

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Se o documento existir, pegar os dados adicionais
        final additionalData = userDoc.data() ?? {};
        print(
          'Documento do usuário encontrado no Firestore. Dados: $additionalData',
        );

        // Verificar especificamente o userType
        if (additionalData.containsKey('userType')) {
          print(
            'Tipo de usuário encontrado no Firestore: ${additionalData['userType']}',
          );
        } else {
          print('Documento existe mas não tem tipo de usuário definido');
        }

        // Adicionar aos dados do usuário
        userData.addAll(additionalData);
        _saveUserData();
      } else {
        // Se o documento não existir, criar um documento vazio para o usuário
        print('Documento do usuário não encontrado. Criando novo documento.');
        await _firestore.collection('users').doc(uid).set({
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      print(
        'Carregamento de dados adicionais do Firestore concluído. Dados atuais: $userData',
      );
    } catch (e) {
      print('Erro ao carregar dados adicionais do usuário: $e');
      if (e is Error) {
        print('Stack trace: ${e.stackTrace}');
      }
    }
  }

  // Verificar se o tipo de usuário já foi definido
  bool hasDefinedUserType() {
    print('Verificando tipo do usuário no UserSession. Dados: $userData');
    return userData.containsKey('userType') &&
        userData['userType'] != null &&
        userData['userType'] != 'unknown';
  }

  // Verificar se o nome do usuário já foi definido
  bool hasDefinedName() {
    print('Verificando nome do usuário no UserSession. Dados: $userData');
    return userData.containsKey('nome') &&
        userData['nome'] != null &&
        userData['nome'].toString().trim().isNotEmpty;
  }

  // Verificar se o perfil do usuário está completo (tipo e nome definidos)
  bool hasCompleteProfile() {
    return hasDefinedUserType() && hasDefinedName();
  }

  // Atualizar os dados do usuário
  Future<void> updateUserData(Map<String, dynamic> newData) async {
    try {
      // Atualizar dados locais
      userData.addAll(newData);

      // Persistir dados
      _saveUserData();

      // Atualizar dados no Firestore
      if (currentUser.value?.uid != null) {
        // Usar set com merge: true em vez de update
        // Isso funciona tanto para documentos novos quanto existentes
        await _firestore
            .collection('users')
            .doc(currentUser.value!.uid)
            .set(newData, SetOptions(merge: true));
      }
    } catch (e) {
      print('Erro ao atualizar dados do usuário: $e');
      throw Exception('Falha ao atualizar perfil: $e');
    }
  }

  // Definir o tipo de usuário (comercial ou logística)
  Future<void> setUserType(String userType) async {
    try {
      // Atualizar tipo de usuário localmente
      userData['userType'] = userType;
      _saveUserData();

      // Atualizar tipo de usuário no Firestore
      if (currentUser.value?.uid != null) {
        // Usar set com merge: true em vez de update
        await _firestore.collection('users').doc(currentUser.value!.uid).set({
          'userType': userType,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Erro ao definir tipo de usuário: $e');
      throw Exception('Falha ao definir tipo de usuário: $e');
    }
  }

  // Obter o tipo de usuário
  String getUserType() {
    return userData['userType'] ?? 'unknown';
  }

  // Forçar atualização dos dados do usuário a partir do Firestore
  Future<void> refreshUserData() async {
    try {
      if (currentUser.value?.uid != null) {
        print('Forçando atualização de dados do usuário do Firestore...');
        await _loadAdditionalUserData(currentUser.value!.uid);
        print('Dados atualizados com sucesso: $userData');
      } else {
        print('Impossível atualizar dados: usuário não autenticado');
      }
    } catch (e) {
      print('Erro ao atualizar dados do usuário: $e');
    }
  }

  // Verificar se o usuário está logado
  bool checkIsLoggedIn() {
    return isLoggedIn.value;
  }

  // Redirecionar com base no tipo de usuário
  void redirectBasedOnUserType() {
    if (!hasDefinedUserType()) {
      // Se o tipo de usuário não estiver definido, redirecione para a tela de registro
      Get.offAllNamed(AppPages.REGISTER);
      return;
    }

    final userType = getUserType();

    if (userType == 'commercial') {
      Get.offAllNamed(AppPages.COMMERCIAL);
    } else if (userType == 'logistic') {
      Get.offAllNamed(AppPages.LOGISTIC);
    } else {
      // Caso de fallback para tipos desconhecidos
      Get.offAllNamed(AppPages.REGISTER);
    }
  }

  // Fazer logout do usuário
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      isLoggedIn.value = false;
      userData.clear();
      _storage.remove(_userKey);
      Get.offAllNamed(AppPages.LOGIN);
    } catch (e) {
      print('Erro ao fazer logout: $e');
      throw Exception('Falha ao fazer logout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
