import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_entregas/models/delivery.dart';
import 'package:smart_entregas/services/delivery_service.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:smart_entregas/widgets/profile_button.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final TextEditingController _nfController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  final DeliveryService _deliveryService = Get.put(DeliveryService());
  final RxList<Delivery> _entregas = <Delivery>[].obs;
  final RxList<Delivery> _entregasFiltradas = <Delivery>[].obs;
  final RxBool _isLoading = true.obs;

  // Controle do painel de busca expandido/retraído
  final RxBool _isSearchExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  void _loadDeliveries() {
    _isLoading.value = true;

    // Inscreve-se no stream de entregas atribuídas ao entregador
    _deliveryService.getDeliveryPersonDeliveries().listen(
      (deliveries) {
        _entregas.value = deliveries;
        _entregasFiltradas.value = deliveries;
        _isLoading.value = false;
      },
      onError: (error) {
        print('Erro ao carregar entregas: $error');
        _isLoading.value = false;
        Get.snackbar(
          'Erro',
          'Não foi possível carregar as entregas',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  @override
  void dispose() {
    _nfController.dispose();
    _clienteController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _filtrarEntregas() {
    final nf = _nfController.text.toLowerCase();
    final cliente = _clienteController.text.toLowerCase();
    final data = _dataController.text;

    _entregasFiltradas.value =
        _entregas.where((entrega) {
          final nfMatch = nf.isEmpty || entrega.nf.toLowerCase().contains(nf);
          final clienteMatch =
              cliente.isEmpty ||
              entrega.cliente.toLowerCase().contains(cliente);
          final dataMatch = data.isEmpty || entrega.data.contains(data);

          return nfMatch && clienteMatch && dataMatch;
        }).toList();

    // Recolher o painel de busca após a pesquisa
    _isSearchExpanded.value = false;
  }

  void _limparFiltros() {
    _nfController.clear();
    _clienteController.clear();
    _dataController.clear();
    _entregasFiltradas.value = _entregas;
  }

  void _verDetalhes(Delivery entrega) {
    Get.toNamed(
      '/delivery_details',
      arguments: {
        'entrega': entrega,
        'readOnly': false,
      }, // Entregador pode enviar foto
    );
  }

  // Adicionar método para definir a cor com base no status
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Minhas Entregas (Entregador)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.loginPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          // Botão de perfil
          ProfileButton(),
        ],
      ),
      body: Column(
        children: [
          // Barra com os botões de pesquisa e contagem de resultados
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contagem de resultados
                Obx(
                  () => Text(
                    'Exibindo ${_entregasFiltradas.length} entregas',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.loginPurple,
                    ),
                  ),
                ),

                // Botões de ação
                Row(
                  children: [
                    // Botão de limpar filtros (visível apenas se houver filtro aplicado)
                    Obx(
                      () => Visibility(
                        visible: _entregasFiltradas.length != _entregas.length,
                        child: TextButton.icon(
                          onPressed: _limparFiltros,
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Limpar'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.loginPurple,
                          ),
                        ),
                      ),
                    ),

                    // Botão para expandir/retrair painel de pesquisa
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          _isSearchExpanded.value
                              ? Icons.arrow_upward
                              : Icons.search,
                          color: AppTheme.loginPurple,
                        ),
                        onPressed: () {
                          _isSearchExpanded.value = !_isSearchExpanded.value;
                        },
                        tooltip:
                            _isSearchExpanded.value
                                ? 'Retrair pesquisa'
                                : 'Expandir pesquisa',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Área de busca (expansível)
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isSearchExpanded.value ? null : 0,
              color: Colors.white,
              child: Visibility(
                visible: _isSearchExpanded.value,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campos de busca:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.loginPurple,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Campo Número da NF
                      TextField(
                        controller: _nfController,
                        decoration: const InputDecoration(
                          labelText: 'Número da NF',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Campo Nome do Cliente
                      TextField(
                        controller: _clienteController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Cliente',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Campo Data
                      TextField(
                        controller: _dataController,
                        decoration: const InputDecoration(
                          labelText: 'Data (opcional)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Botão de pesquisa
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _filtrarEntregas,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.loginPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Pesquisar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Lista de entregas
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.loginPurple),
                );
              }

              if (_entregasFiltradas.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma entrega encontrada',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: _entregasFiltradas.length,
                itemBuilder: (context, index) {
                  final entrega = _entregasFiltradas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        'NF: ${entrega.nf} - ${entrega.cliente}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data: ${entrega.data}'),
                          // Status com cor
                          Row(
                            children: [
                              const Text('Status: '),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(entrega.status),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  entrega.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Smarter: ${entrega.comercianteNome ?? 'Não informado'}',
                          ),
                          Text('Tipo: ${entrega.tipoEntrega}'),
                          Text('Endereço: ${entrega.endereco}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (entrega.status != 'Entregue')
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.loginPurple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: AppTheme.loginPurple,
                                ),
                                onPressed: () => _verDetalhes(entrega),
                                tooltip: 'Enviar foto',
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: () => _verDetalhes(entrega),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
