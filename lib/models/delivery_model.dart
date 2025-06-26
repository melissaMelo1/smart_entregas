class DeliveryModel {
  final String id;
  final String nf;
  final String cliente;
  final String data;
  final String status;
  final String endereco;
  final String imagem;
  final String criadoPor;

  DeliveryModel({
    required this.id,
    required this.nf,
    required this.cliente,
    required this.data,
    required this.status,
    required this.endereco,
    this.imagem = '',
    required this.criadoPor,
  });

  // Converter de Map para DeliveryModel
  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] ?? '',
      nf: json['nf'] ?? '',
      cliente: json['cliente'] ?? '',
      data: json['data'] ?? '',
      status: json['status'] ?? '',
      endereco: json['endereco'] ?? '',
      imagem: json['imagem'] ?? '',
      criadoPor: json['criadoPor'] ?? '',
    );
  }

  // Converter de DeliveryModel para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nf': nf,
      'cliente': cliente,
      'data': data,
      'status': status,
      'endereco': endereco,
      'imagem': imagem,
      'criadoPor': criadoPor,
    };
  }

  // Criar uma cópia com alterações
  DeliveryModel copyWith({
    String? id,
    String? nf,
    String? cliente,
    String? data,
    String? status,
    String? endereco,
    String? imagem,
    String? criadoPor,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      nf: nf ?? this.nf,
      cliente: cliente ?? this.cliente,
      data: data ?? this.data,
      status: status ?? this.status,
      endereco: endereco ?? this.endereco,
      imagem: imagem ?? this.imagem,
      criadoPor: criadoPor ?? this.criadoPor,
    );
  }
}
