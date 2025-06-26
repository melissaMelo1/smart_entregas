import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/delivery.dart';
import '../services/user_session.dart';

class DeliveryService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserSession _userSession = UserSession.to;

  // Coleção de entregas no Firestore
  CollectionReference get _deliveriesCollection =>
      _firestore.collection('deliveries');

  // Buscar todas as entregas (para usuários comerciais)
  Stream<List<Delivery>> getAllDeliveries() {
    return _deliveriesCollection
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Delivery.fromSnapshot(doc))
              .toList();
        });
  }

  // Buscar entregas do usuário logado (para usuários logísticos)
  Stream<List<Delivery>> getUserDeliveries() {
    String userId = _userSession.currentUser.value?.uid ?? '';
    return _deliveriesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Delivery.fromSnapshot(doc))
              .toList();
        });
  }

  // Filtrar entregas por NF, cliente ou data
  Stream<List<Delivery>> getFilteredDeliveries({
    String? nf,
    String? cliente,
    String? data,
    bool onlyUserDeliveries = false,
  }) {
    // Começar com a query básica
    Query query = _deliveriesCollection;

    // Filtrar por usuário se solicitado (para usuários logísticos)
    if (onlyUserDeliveries) {
      String userId = _userSession.currentUser.value?.uid ?? '';
      query = query.where('userId', isEqualTo: userId);
    }

    // Ordenar por data, mais recentes primeiro
    query = query.orderBy('data', descending: true);

    // Retornar o stream com os dados filtrados
    return query.snapshots().map((snapshot) {
      List<Delivery> deliveries =
          snapshot.docs.map((doc) => Delivery.fromSnapshot(doc)).toList();

      // Aplicar filtros adicionais no cliente
      if (nf != null && nf.isNotEmpty) {
        deliveries =
            deliveries
                .where((d) => d.nf.toLowerCase().contains(nf.toLowerCase()))
                .toList();
      }

      if (cliente != null && cliente.isNotEmpty) {
        deliveries =
            deliveries
                .where(
                  (d) =>
                      d.cliente.toLowerCase().contains(cliente.toLowerCase()),
                )
                .toList();
      }

      if (data != null && data.isNotEmpty) {
        deliveries = deliveries.where((d) => d.data.contains(data)).toList();
      }

      return deliveries;
    });
  }

  // Adicionar nova entrega
  Future<DocumentReference> addDelivery(Delivery delivery) {
    Map<String, dynamic> data = delivery.toMap();
    // Adicionar timestamp de criação
    data['createdAt'] = DateTime.now().toIso8601String();
    return _deliveriesCollection.add(data);
  }

  // Atualizar entrega existente
  Future<void> updateDelivery(Delivery delivery) {
    Map<String, dynamic> data = delivery.toMap();
    // Adicionar timestamp de atualização
    data['updatedAt'] = DateTime.now().toIso8601String();
    return _deliveriesCollection.doc(delivery.id).update(data);
  }

  // Atualizar status da entrega
  Future<void> updateDeliveryStatus(
    String deliveryId,
    String newStatus, {
    String? horarioEntrega,
    String? imagem,
  }) {
    Map<String, dynamic> updateData = {
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (horarioEntrega != null) {
      updateData['horarioEntrega'] = horarioEntrega;
    }

    if (imagem != null) {
      updateData['imagem'] = imagem;
    }

    return _deliveriesCollection.doc(deliveryId).update(updateData);
  }

  // Excluir entrega
  Future<void> deleteDelivery(String deliveryId) {
    return _deliveriesCollection.doc(deliveryId).delete();
  }

  // Obter entrega pelo ID
  Future<Delivery?> getDeliveryById(String deliveryId) async {
    DocumentSnapshot doc = await _deliveriesCollection.doc(deliveryId).get();
    if (doc.exists) {
      return Delivery.fromSnapshot(doc);
    }
    return null;
  }

  // Método para obter entregas do comerciante logado
  Stream<List<Delivery>> getCommercialDeliveries() {
    final userId = _userSession.currentUser.value?.uid;

    if (userId == null) {
      // Retornar stream vazio se não houver usuário logado
      return Stream.value([]);
    }

    // Obter entregas onde o comercianteId é igual ao ID do usuário logado
    return _firestore
        .collection('deliveries')
        .where('comercianteId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Delivery.fromSnapshot(doc)).toList(),
        );
  }

  // Método para obter entregas do entregador logado
  Stream<List<Delivery>> getDeliveryPersonDeliveries() {
    final userId = _userSession.currentUser.value?.uid;

    if (userId == null) {
      // Retornar stream vazio se não houver usuário logado
      return Stream.value([]);
    }

    // Obter entregas onde o entregadorId é igual ao ID do usuário logado
    return _firestore
        .collection('deliveries')
        .where('entregadorId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Delivery.fromSnapshot(doc)).toList(),
        );
  }
}
