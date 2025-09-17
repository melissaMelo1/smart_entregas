import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_entregas/models/delivery.dart';
import 'package:smart_entregas/services/delivery_service.dart';
import 'package:smart_entregas/services/user_session.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterDeliveryPage extends StatefulWidget {
  const RegisterDeliveryPage({super.key});

  @override
  State<RegisterDeliveryPage> createState() => _RegisterDeliveryPageState();
}

class _RegisterDeliveryPageState extends State<RegisterDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nfController = TextEditingController();
  final _clienteController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _dataController = TextEditingController();
  final _entregadorController = TextEditingController();
  final _comercianteController = TextEditingController();
  final _transportadoraController = TextEditingController();

  final DeliveryService _deliveryService = Get.put(DeliveryService());
  final UserSession _userSession = Get.find<UserSession>();
  final RxBool _isLoading = false.obs;

  // Listas para comerciantes e entregadores
  final RxList<Map<String, dynamic>> _comerciantes =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _comerciantesFiltrados =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _entregadores =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _entregadoresFiltrados =
      <Map<String, dynamic>>[].obs;

  final TextEditingController _searchController = TextEditingController();

  String? _comercianteId;
  String? _comercianteNome;
  String? _entregadorId;

  // Opções de tipo de entrega
  final RxString _tipoEntrega = 'Motorista'.obs;
  final List<String> _tipoEntregaOptions = ['Motorista', 'Transportadora'];

  // Status da entrega (agora modificável)
  final RxString _statusEntrega = 'Em trânsito'.obs;
  final List<String> _statusOptions = ['Pendente', 'Em trânsito', 'Entregue'];

  final _dateFormat = DateFormat('dd/MM/yyyy');
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dataController.text = _dateFormat.format(_selectedDate);

    _carregarComerciantes();
    _carregarEntregadores();

    // Debug: Verificar o estado inicial do userData
    _verificarDadosUsuario();
  }

  // Método para verificar e garantir que os dados do usuário estão carregados
  void _verificarDadosUsuario() async {
    print('DEBUG initState: userData atual: ${_userSession.userData}');
    print(
      'DEBUG initState: Nome no userData: ${_userSession.userData['nome']}',
    );

    // Se não tiver nome, tentar atualizar os dados
    if (_userSession.userData['nome'] == null ||
        _userSession.userData['nome'].toString().trim().isEmpty) {
      print('DEBUG: Nome não encontrado, forçando atualização dos dados...');
      try {
        await _userSession.refreshUserData();
        print('DEBUG após refresh: userData: ${_userSession.userData}');
        print('DEBUG após refresh: Nome: ${_userSession.userData['nome']}');
      } catch (e) {
        print('DEBUG: Erro ao atualizar dados do usuário: $e');
      }
    }
  }

  @override
  void dispose() {
    _nfController.dispose();
    _clienteController.dispose();
    _enderecoController.dispose();
    _dataController.dispose();
    _entregadorController.dispose();
    _comercianteController.dispose();
    _transportadoraController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarComerciantes() async {
    _isLoading.value = true;
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('userType', isEqualTo: 'commercial')
              .get();

      final List<Map<String, dynamic>> comerciantesTemp = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        comerciantesTemp.add({
          'id': doc.id,
          'nome': data['nome'] ?? 'Sem nome',
          'telefone': data['phoneNumber'] ?? '',
        });
      }

      _comerciantes.value = comerciantesTemp;
      _comerciantesFiltrados.value = comerciantesTemp;
    } catch (e) {
      print('Erro ao carregar comerciantes: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar a lista de comerciantes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    _isLoading.value = false;
  }

  Future<void> _carregarEntregadores() async {
    _isLoading.value = true;
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('userType', isEqualTo: 'delivery')
              .get();

      final List<Map<String, dynamic>> entregadoresTemp = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        entregadoresTemp.add({
          'id': doc.id,
          'nome': data['nome'] ?? 'Sem nome',
          'telefone': data['phoneNumber'] ?? '',
        });
      }

      _entregadores.value = entregadoresTemp;
      _entregadoresFiltrados.value = entregadoresTemp;
    } catch (e) {
      print('Erro ao carregar entregadores: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar a lista de entregadores',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    _isLoading.value = false;
  }

  void _filtrarComerciantes(String query) {
    if (query.isEmpty) {
      _comerciantesFiltrados.value = _comerciantes;
      return;
    }

    final queryLower = query.toLowerCase();
    _comerciantesFiltrados.value =
        _comerciantes.where((comerciante) {
          final nome = comerciante['nome'].toString().toLowerCase();
          final telefone = comerciante['telefone'].toString().toLowerCase();
          return nome.contains(queryLower) || telefone.contains(queryLower);
        }).toList();
  }

  void _filtrarEntregadores(String query) {
    if (query.isEmpty) {
      _entregadoresFiltrados.value = _entregadores;
      return;
    }

    final queryLower = query.toLowerCase();
    _entregadoresFiltrados.value =
        _entregadores.where((entregador) {
          final nome = entregador['nome'].toString().toLowerCase();
          final telefone = entregador['telefone'].toString().toLowerCase();
          return nome.contains(queryLower) || telefone.contains(queryLower);
        }).toList();
  }

  // Função para mascarar o número de telefone
  String _mascaraTelefone(String telefone) {
    if (telefone.isEmpty) return '';
    if (telefone.length <= 4) return telefone;

    // Mantém os últimos 4 dígitos visíveis
    String ultimosDigitos = telefone.substring(telefone.length - 4);
    String asteriscos = '*' * (telefone.length - 4);

    return '$asteriscos$ultimosDigitos';
  }

  void _mostrarSeletorComerciante() {
    _searchController.clear();
    _comerciantesFiltrados.value = _comerciantes;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecione um Smarter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.loginPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou telefone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filtrarComerciantes,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (_isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_comerciantesFiltrados.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum comerciante encontrado',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _comerciantesFiltrados.length,
                  itemBuilder: (context, index) {
                    final comerciante = _comerciantesFiltrados[index];
                    return ListTile(
                      title: Text(comerciante['nome']),
                      subtitle: Text(_mascaraTelefone(comerciante['telefone'])),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _comercianteId = comerciante['id'];
                        _comercianteNome = comerciante['nome'];
                        _comercianteController.text = comerciante['nome'];
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _mostrarSeletorEntregador() {
    _searchController.clear();
    _entregadoresFiltrados.value = _entregadores;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecione um Entregador',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.loginPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou telefone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filtrarEntregadores,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (_isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_entregadoresFiltrados.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum entregador encontrado',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _entregadoresFiltrados.length,
                  itemBuilder: (context, index) {
                    final entregador = _entregadoresFiltrados[index];
                    return ListTile(
                      title: Text(entregador['nome']),
                      subtitle: Text(_mascaraTelefone(entregador['telefone'])),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _entregadorId = entregador['id'];
                        _entregadorController.text = entregador['nome'];
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _registrarEntrega() async {
    if (_formKey.currentState!.validate()) {
      if (_comercianteId == null) {
        Get.snackbar(
          'Atenção',
          'Selecione um comerciante para esta entrega',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.amber,
          colorText: Colors.white,
        );
        return;
      }

      if (_entregadorId == null) {
        Get.snackbar(
          'Atenção',
          'Selecione um entregador para esta entrega',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.amber,
          colorText: Colors.white,
        );
        return;
      }

      _isLoading.value = true;

      try {
        final userId = _userSession.currentUser.value?.uid ?? '';

        if (userId.isEmpty) {
          Get.snackbar(
            'Erro',
            'Usuário não identificado. Faça login novamente.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          _isLoading.value = false;
          return;
        }

        // Debug: Verificar o estado do userData
        print('DEBUG: userData completo: ${_userSession.userData}');
        print('DEBUG: Nome no userData: ${_userSession.userData['nome']}');

        // Usar o método mais robusto para obter o nome do usuário
        final nomeLogistico = await _deliveryService.getCurrentUserName();
        print('DEBUG: Nome do logístico que será salvo: $nomeLogistico');

        final delivery = Delivery(
          id: '',
          nf: _nfController.text.trim(),
          cliente: _clienteController.text.trim(),
          data: _dataController.text.trim(),
          status: _statusEntrega.value, // Usa o status selecionado
          endereco: _enderecoController.text.trim(),
          entregador: _entregadorController.text.trim(),
          userId: userId, // ID do usuário logístico que cadastrou
          nomeUsuarioLogistico: nomeLogistico, // Nome do logístico
          comercianteId:
              _comercianteId, // ID do comerciante que vai receber a entrega
          comercianteNome: _comercianteNome,
          entregadorId:
              _entregadorId, // ID do entregador responsável pela entrega
          tipoEntrega: _tipoEntrega.value, // Adiciona o tipo de entrega
          transportadora:
              _tipoEntrega.value == 'Transportadora'
                  ? _transportadoraController.text.trim()
                  : null, // Adiciona o nome da transportadora se aplicável
        );

        await _deliveryService.addDelivery(delivery);

        _isLoading.value = false;

        Get.back();

        Get.snackbar(
          'Sucesso',
          'Entrega registrada com sucesso!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        _isLoading.value = false;
        print('Erro ao registrar entrega: $e');

        Get.snackbar(
          'Erro',
          'Não foi possível registrar a entrega: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.loginPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.loginPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dataController.text = _dateFormat.format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registrar Nova Entrega',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.loginPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações da Entrega',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.loginPurple,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de seleção de comerciante
                      TextFormField(
                        controller: _comercianteController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Smarter',
                          hintText: 'Selecione um Smarter',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.store),
                            onPressed: _mostrarSeletorComerciante,
                          ),
                          labelStyle: TextStyle(color: Colors.black87),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onTap: _mostrarSeletorComerciante,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione um Smarter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Campo de seleção de entregador
                      TextFormField(
                        controller: _entregadorController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Entregador',
                          hintText: 'Selecione um entregador',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.delivery_dining),
                            onPressed: _mostrarSeletorEntregador,
                          ),
                          labelStyle: TextStyle(color: Colors.black87),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onTap: _mostrarSeletorEntregador,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecione um entregador';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _nfController,
                        decoration: const InputDecoration(
                          labelText: 'Número da NF',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o número da NF';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _clienteController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Cliente',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o nome do cliente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço de Entrega',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe o endereço';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _dataController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Data da Entrega',
                          border: const OutlineInputBorder(),
                          hintText: 'DD/MM/AAAA',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                          labelStyle: TextStyle(color: Colors.black87),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe a data';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Dropdown para tipo de entrega
                      Obx(
                        () => DropdownButtonFormField<String>(
                          value: _tipoEntrega.value,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Entrega',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_shipping),
                            labelStyle: TextStyle(color: Colors.black87),
                          ),
                          items:
                              _tipoEntregaOptions
                                  .map(
                                    (tipo) => DropdownMenuItem(
                                      value: tipo,
                                      child: Text(
                                        tipo,
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _tipoEntrega.value = value;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, selecione o tipo de entrega';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo de nome da transportadora (aparece apenas quando tipo é "Transportadora")
                      Obx(
                        () =>
                            _tipoEntrega.value == 'Transportadora'
                                ? Column(
                                  children: [
                                    TextFormField(
                                      controller: _transportadoraController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome da Transportadora',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.business),
                                        labelStyle: TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (_tipoEntrega.value ==
                                                'Transportadora' &&
                                            (value == null || value.isEmpty)) {
                                          return 'Por favor, informe o nome da transportadora';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                )
                                : const SizedBox.shrink(),
                      ),

                      // Dropdown para status da entrega
                      Obx(
                        () => DropdownButtonFormField<String>(
                          value: _statusEntrega.value,
                          decoration: const InputDecoration(
                            labelText: 'Status Inicial',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.assignment_turned_in),
                            labelStyle: TextStyle(color: Colors.black87),
                          ),
                          items:
                              _statusOptions
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status,
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _statusEntrega.value = value;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, selecione o status inicial';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Container de upload de comprovante removido temporariamente
                      // Inserir de volta quando a funcionalidade for necessária
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading.value ? null : _registrarEntrega,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.loginPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            'Registrar Entrega',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
