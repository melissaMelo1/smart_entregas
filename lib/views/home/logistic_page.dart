import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_entregas/models/delivery.dart';
import 'package:smart_entregas/services/delivery_service.dart';
import 'package:smart_entregas/services/user_session.dart';
import 'package:smart_entregas/theme/app_theme.dart';
import 'package:smart_entregas/widgets/profile_button.dart';
import 'package:share_plus/share_plus.dart';

class LogisticPage extends StatefulWidget {
  const LogisticPage({super.key});

  @override
  State<LogisticPage> createState() => _LogisticPageState();
}

class _LogisticPageState extends State<LogisticPage> {
  final DeliveryService _deliveryService = Get.put(DeliveryService());
  final UserSession _userSession = Get.find<UserSession>();
  final RxList<Delivery> _entregas = <Delivery>[].obs;
  final RxBool _isLoading = true.obs;
  final RxList<String> _statusFiltro = <String>['Todos'].obs;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  void _loadDeliveries() {
    print('Carregando entregas');
    _isLoading.value = true;

    // Inscreve-se no stream de TODAS as entregas (perfil logística vê tudo)
    _deliveryService.getUserDeliveries().listen(
      (deliveries) {
        _entregas.value = deliveries;
        _isLoading.value = false;
      },
      onError: (error) {
        _isLoading.value = false;
        Get.snackbar(
          'Erro',
          'Não foi possível carregar as entregas ${error.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('Erro ao carregar entregas: ${error.toString()}');
      },
    );
  }

  void _verDetalhes(Delivery entrega) {
    // Passar o objeto de entrega sem a flag de somente leitura para logístico
    Get.toNamed(
      '/delivery_details',
      arguments: {'entrega': entrega, 'readOnly': false},
    );
  }

  void _registrarNovaEntrega() {
    // Navegar para página de registro de nova entrega
    Get.toNamed('/register_delivery');
  }

  void _visualizarImagem(Delivery entrega) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Imagem em tela cheia
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  entrega.imagem!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Botões de ação
            Positioned(
              top: 40,
              right: 16,
              child: Row(
                children: [
                  // Botão de compartilhar
                  IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () async {
                      try {
                        await Share.share(
                          'Comprovante de Entrega - NF: ${entrega.nf}\n\n${entrega.imagem}',
                          subject: 'Comprovante de Entrega',
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Erro',
                          'Não foi possível compartilhar a imagem',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    tooltip: 'Compartilhar',
                  ),
                  const SizedBox(width: 8),
                  // Botão de fechar
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Get.back(),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
            ),
            // Informações da entrega na parte inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NF: ${entrega.nf}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cliente: ${entrega.cliente}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    if (entrega.horarioEntrega != null)
                      Text(
                        'Horário de Entrega: ${entrega.horarioEntrega}',
                        style: const TextStyle(
                          color: Colors.white,
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
    );
  }

  Widget _buildStatusChip(String status) {
    bool isSelected = _statusFiltro.contains(status);

    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        if (status == 'Todos') {
          // Se selecionou "Todos", limpa outros filtros
          _statusFiltro.value = ['Todos'];
        } else {
          // Remove "Todos" se selecionar algum status específico
          _statusFiltro.remove('Todos');

          if (selected) {
            _statusFiltro.add(status);
          } else {
            _statusFiltro.remove(status);
            // Se não sobrou nenhum filtro, volta para "Todos"
            if (_statusFiltro.isEmpty) {
              _statusFiltro.value = ['Todos'];
            }
          }
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.loginPurple.withOpacity(0.2),
      checkmarkColor: AppTheme.loginPurple,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.loginPurple : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  List<Delivery> get _entregasFiltradas {
    if (_statusFiltro.contains('Todos')) {
      return _entregas;
    }

    return _entregas.where((e) => _statusFiltro.contains(e.status)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Gerenciar Entregas',
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
          // Cabeçalho com total de entregas e filtros
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total de entregas do sistema: ${_entregas.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.loginPurple,
                        ),
                      ),
                      // Status de entregas
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.loginPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Obx(
                          () => Text(
                            'Exibindo: ${_entregasFiltradas.length}',
                            style: const TextStyle(
                              color: AppTheme.loginPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Chips de filtro por status
                Wrap(
                  spacing: 8,
                  children: [
                    _buildStatusChip('Todos'),
                    _buildStatusChip('Pendente'),
                    _buildStatusChip('Em trânsito'),
                    _buildStatusChip('Entregue'),
                  ],
                ),
              ],
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

              final entregas = _entregasFiltradas;

              if (entregas.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma entrega registrada no sistema',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: entregas.length,
                itemBuilder: (context, index) {
                  final entrega = entregas[index];
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
                          Row(
                            children: [
                              Text('Status: '),
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
                            'Smarter: ${entrega.comercianteNome ?? 'Não atribuído'}',
                          ),
                          Text('Tipo: ${entrega.tipoEntrega}'),
                          if (entrega.nomeUsuarioLogistico != null)
                            Text(
                              'Cadastrado por: ${entrega.nomeUsuarioLogistico}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (entrega.imagem != null)
                            IconButton(
                              icon: const Icon(
                                Icons.image,
                                color: AppTheme.loginPurple,
                              ),
                              onPressed: () => _visualizarImagem(entrega),
                              tooltip: 'Ver Foto',
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrarNovaEntrega,
        backgroundColor: AppTheme.loginPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Entrega'),
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
}
