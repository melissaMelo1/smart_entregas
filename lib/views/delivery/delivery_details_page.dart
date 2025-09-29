import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_entregas/models/delivery.dart';
import 'package:smart_entregas/services/delivery_service.dart';
import 'package:smart_entregas/services/user_session.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class DeliveryDetailsPage extends StatefulWidget {
  const DeliveryDetailsPage({super.key});

  @override
  State<DeliveryDetailsPage> createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  final DeliveryService _deliveryService = Get.find<DeliveryService>();
  final UserSession _userSession = Get.find<UserSession>();
  final RxBool _isLoading = false.obs;
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final ImagePicker _picker = ImagePicker();

  late Delivery _entrega;
  late bool _readOnly;
  final RxString _imagemUrl = RxString('');
  final RxBool _uploading = false.obs;

  @override
  void initState() {
    super.initState();
    // Processar argumentos recebidos
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      // Novo formato de argumentos (mapa com entrega e flag readOnly)
      _entrega = args['entrega'] as Delivery;
      _readOnly = args['readOnly'] ?? false;
    } else {
      // Formato antigo (apenas o objeto entrega)
      _entrega = args as Delivery;
      _readOnly = false;
    }

    if (_entrega.imagem != null) {
      _imagemUrl.value = _entrega.imagem!;
    }
  }

  void _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    // Converter a data atual do controller para DateTime
    DateTime initialDate;
    try {
      initialDate = _dateFormat.parse(controller.text);
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    if (picked != null) {
      controller.text = _dateFormat.format(picked);
    }
  }

  Future<void> _capturarEEnviarImagem() async {
    try {
      final XFile? imagem = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (imagem == null) return;

      _uploading.value = true;

      // Fazer upload da imagem para o Firebase Storage
      final String nomeArquivo =
          'entrega_${_entrega.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('comprovantes')
          .child(nomeArquivo);

      final File imagemFile = File(imagem.path);
      final UploadTask uploadTask = ref.putFile(imagemFile);

      // Esperar upload terminar e obter URL
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(
        () => null,
      );
      final String url = await taskSnapshot.ref.getDownloadURL();

      // Atualizar URL da imagem e status da entrega
      _imagemUrl.value = url;

      // Atualizar no Firebase
      String horarioEntrega = DateTime.now().toString().substring(
        11,
        16,
      ); // Formato HH:MM

      await _deliveryService.updateDeliveryStatus(
        _entrega.id,
        'Entregue',
        horarioEntrega: horarioEntrega,
        imagem: url,
      );

      // Atualizar objeto local
      setState(() {
        _entrega = _entrega.copyWith(
          status: 'Entregue',
          horarioEntrega: horarioEntrega,
          imagem: url,
        );
      });

      _uploading.value = false;

      Get.snackbar(
        'Sucesso',
        'Comprovante enviado e entrega finalizada',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _uploading.value = false;
      Get.snackbar(
        'Erro',
        'Não foi possível enviar o comprovante: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showEditDialog(BuildContext context, Delivery entrega) {
    final TextEditingController clienteController = TextEditingController(
      text: entrega.cliente,
    );
    final TextEditingController enderecoController = TextEditingController(
      text: entrega.endereco,
    );
    final TextEditingController dataController = TextEditingController(
      text: entrega.data,
    );
    final TextEditingController nfController = TextEditingController(
      text: entrega.nf,
    );
    final TextEditingController entregadorController = TextEditingController(
      text: entrega.entregador,
    );
    final TextEditingController transportadoraController =
        TextEditingController(text: entrega.transportadora ?? '');

    // Variáveis para os dropdowns
    String selectedTipoEntrega = entrega.tipoEntrega;
    String selectedStatus = entrega.status;
    final List<String> tipoEntregaOptions = ['Motorista', 'Transportadora'];
    final List<String> statusOptions = ['Pendente', 'Em trânsito', 'Entregue'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Entrega'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nfController,
                    decoration: const InputDecoration(
                      labelText: 'Nota Fiscal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: clienteController,
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de data com seletor de calendário
                  TextField(
                    controller: dataController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, dataController),
                      ),
                    ),
                    onTap: () => _selectDate(context, dataController),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: entregadorController,
                    decoration: const InputDecoration(
                      labelText: 'Entregador',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de transportadora (aparece apenas quando tipo é "Transportadora")
                  StatefulBuilder(
                    builder:
                        (context, setState) =>
                            selectedTipoEntrega == 'Transportadora'
                                ? Column(
                                  children: [
                                    TextField(
                                      controller: transportadoraController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome da Transportadora',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                )
                                : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  // Dropdown para tipo de entrega
                  StatefulBuilder(
                    builder:
                        (context, setState) => DropdownButtonFormField<String>(
                          value: selectedTipoEntrega,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Entrega',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              tipoEntregaOptions
                                  .map(
                                    (tipo) => DropdownMenuItem(
                                      value: tipo,
                                      child: Text(tipo),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedTipoEntrega = value;
                              });
                            }
                          },
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Dropdown para status
                  StatefulBuilder(
                    builder:
                        (context, setState) => DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              statusOptions
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedStatus = value;
                              });
                            }
                          },
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _isLoading.value = true;

                  try {
                    // Criar objeto atualizado
                    final updatedDelivery = entrega.copyWith(
                      nf: nfController.text.trim(),
                      cliente: clienteController.text.trim(),
                      endereco: enderecoController.text.trim(),
                      data: dataController.text.trim(),
                      entregador: entregadorController.text.trim(),
                      transportadora: transportadoraController.text.trim(),
                      tipoEntrega: selectedTipoEntrega,
                      status: selectedStatus,
                    );

                    // Atualizar no Firebase
                    await _deliveryService.updateDelivery(updatedDelivery);

                    // Atualizar objeto local
                    setState(() {
                      _entrega = updatedDelivery;
                    });

                    _isLoading.value = false;

                    Get.snackbar(
                      'Sucesso',
                      'Dados atualizados com sucesso',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    _isLoading.value = false;
                    Get.snackbar(
                      'Erro',
                      'Não foi possível atualizar os dados: ${e.toString()}',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.loginPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Entregue':
        return Colors.green;
      case 'Pendente':
        return Colors.orange;
      case 'Em trânsito':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar o tipo de usuário
    final String userType = _userSession.getUserType();

    // Verificar se é o entregador atribuído a esta entrega
    bool isAssignedDeliveryPerson =
        userType == 'delivery' &&
        _userSession.currentUser.value?.uid == _entrega.entregadorId;

    // Verificar se é o logístico que criou a entrega
    bool isLogisticCreator =
        userType == 'logistic' &&
        _userSession.currentUser.value?.uid == _entrega.userId;

    // Verificar se é uma entrega de transportadora
    bool isTransportadoraDelivery = _entrega.tipoEntrega == 'Transportadora';

    // Logístico tem controle total em entregas de transportadora
    bool logisticCanControlTransportadora =
        userType == 'logistic' && isTransportadoraDelivery;
    // Determinar se pode editar
    // - Logístico criador (sempre)
    // - Qualquer logístico para entregas de Transportadora
    bool canEdit =
        !_readOnly && (isLogisticCreator || logisticCanControlTransportadora);

    // Verificar se pode enviar comprovante
    // - Entregador atribuído (modo normal)
    // - Qualquer logístico para entregas de Transportadora
    bool podeEnviarComprovante =
        (isAssignedDeliveryPerson || logisticCanControlTransportadora) &&
        _entrega.status != 'Entregue';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalhes da Entrega',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.loginPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, _entrega),
              tooltip: 'Editar',
            ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho com informações principais
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.loginPurple.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NF: ${_entrega.nf}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.loginPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_entrega.status),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                _entrega.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Detalhes da entrega
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Caixa de Informações do Cliente
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informações do Cliente',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.loginPurple,
                                ),
                              ),
                              _buildInfoItem('Cliente', _entrega.cliente),
                              _buildInfoItem('Endereço', _entrega.endereco),
                              _buildInfoItem('Data', _entrega.data),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Caixa de Informações da Entrega
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                              _buildInfoItem('Entregador', _entrega.entregador),
                              _buildInfoItem('Tipo', _entrega.tipoEntrega),
                              if (_entrega.tipoEntrega == 'Transportadora' &&
                                  _entrega.transportadora != null)
                                _buildInfoItem(
                                  'Transportadora',
                                  _entrega.transportadora!,
                                ),
                              if (userType != 'delivery')
                                _buildInfoItem(
                                  'Smarter',
                                  _entrega.comercianteNome ?? 'Não atribuído',
                                ),
                              if (_entrega.horarioEntrega != null)
                                _buildInfoItem(
                                  'Horário',
                                  _entrega.horarioEntrega!,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Imagem da entrega
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Comprovante de Entrega',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.loginPurple,
                              ),
                            ),
                            if (podeEnviarComprovante)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Enviar'),
                                onPressed: _capturarEEnviarImagem,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.loginPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (_uploading.value) {
                            return const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Enviando comprovante...'),
                                ],
                              ),
                            );
                          } else if (_imagemUrl.value.isNotEmpty) {
                            return Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(_imagemUrl.value),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Nenhum comprovante enviado',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                  ),
                ],
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
