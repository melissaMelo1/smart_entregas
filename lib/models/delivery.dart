import 'package:cloud_firestore/cloud_firestore.dart';

class Delivery {
  final String id;
  final String nf;
  final String cliente;
  final String data;
  final String status;
  final String endereco;
  final String? imagem;
  final String entregador;
  final String? horarioEntrega;
  final String userId; // ID do usuário que criou a entrega (logístico)
  final String? nomeUsuarioLogistico; // Nome do usuário logístico que cadastrou
  final String? comercianteId; // ID do comerciante associado à entrega
  final String? comercianteNome; // Nome do comerciante para exibição
  final String? entregadorId; // ID do entregador associado à entrega
  final String tipoEntrega; // 'Motorista' ou 'Transportadora'
  final String?
  transportadora; // Nome da transportadora (quando tipoEntrega = 'Transportadora')

  Delivery({
    required this.id,
    required this.nf,
    required this.cliente,
    required this.data,
    required this.status,
    required this.endereco,
    this.imagem,
    required this.entregador,
    this.horarioEntrega,
    required this.userId,
    this.nomeUsuarioLogistico,
    this.comercianteId,
    this.comercianteNome,
    this.entregadorId,
    this.tipoEntrega = 'Motorista', // Valor padrão
    this.transportadora,
  });

  // Converter objeto Delivery para Map
  Map<String, dynamic> toMap() {
    return {
      'nf': nf,
      'cliente': cliente,
      'data': data,
      'status': status,
      'endereco': endereco,
      'imagem': imagem,
      'entregador': entregador,
      'horarioEntrega': horarioEntrega,
      'userId': userId,
      'nomeUsuarioLogistico': nomeUsuarioLogistico,
      'comercianteId': comercianteId,
      'comercianteNome': comercianteNome,
      'entregadorId': entregadorId,
      'tipoEntrega': tipoEntrega,
      'transportadora': transportadora,
    };
  }

  // Criar objeto Delivery a partir de um DocumentSnapshot
  factory Delivery.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Delivery(
      id: doc.id,
      nf: data['nf'] ?? '',
      cliente: data['cliente'] ?? '',
      data: data['data'] ?? '',
      status: data['status'] ?? 'Pendente',
      endereco: data['endereco'] ?? '',
      imagem: data['imagem'],
      entregador: data['entregador'] ?? '',
      horarioEntrega: data['horarioEntrega'],
      userId: data['userId'] ?? '',
      nomeUsuarioLogistico: data['nomeUsuarioLogistico'],
      comercianteId: data['comercianteId'],
      comercianteNome: data['comercianteNome'],
      entregadorId: data['entregadorId'],
      tipoEntrega: data['tipoEntrega'] ?? 'Motorista',
      transportadora: data['transportadora'],
    );
  }

  // Criar uma cópia do objeto com modificações
  Delivery copyWith({
    String? id,
    String? nf,
    String? cliente,
    String? data,
    String? status,
    String? endereco,
    String? imagem,
    String? entregador,
    String? horarioEntrega,
    String? userId,
    String? nomeUsuarioLogistico,
    String? comercianteId,
    String? comercianteNome,
    String? entregadorId,
    String? tipoEntrega,
    String? transportadora,
  }) {
    return Delivery(
      id: id ?? this.id,
      nf: nf ?? this.nf,
      cliente: cliente ?? this.cliente,
      data: data ?? this.data,
      status: status ?? this.status,
      endereco: endereco ?? this.endereco,
      imagem: imagem ?? this.imagem,
      entregador: entregador ?? this.entregador,
      horarioEntrega: horarioEntrega ?? this.horarioEntrega,
      userId: userId ?? this.userId,
      nomeUsuarioLogistico: nomeUsuarioLogistico ?? this.nomeUsuarioLogistico,
      comercianteId: comercianteId ?? this.comercianteId,
      comercianteNome: comercianteNome ?? this.comercianteNome,
      entregadorId: entregadorId ?? this.entregadorId,
      tipoEntrega: tipoEntrega ?? this.tipoEntrega,
      transportadora: transportadora ?? this.transportadora,
    );
  }
}
