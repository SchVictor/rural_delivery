import 'package:cloud_firestore/cloud_firestore.dart';

class PacoteModel {
  String? firestoreId; // ID do documento no Firestore
  final String userId; // "Link" para o usuário que criou
  final String status; // Ex: 'pendente', 'em_transito', 'concluido'

  String? motoristaId;

  // 1. Detalhes do Item
  final String itemDesc;
  final String itemPeso;
  final String itemTam;

  // 2. Endereço de Retirada (Salvamos como um mapa)
  final Map<String, dynamic> enderecoRetirada;

  // 3. Endereço de Entrega (Salvamos o ID do endereço cadastrado)
  final String enderecoEntregaId;
  // (Opcional: podemos duplicar os dados para facilitar a leitura)
  final Map<String, dynamic> enderecoEntrega;

  final Timestamp createdAt; // Para ordenar

  PacoteModel({
    this.firestoreId,
    required this.userId,
    this.status = 'pendente',
    required this.itemDesc,
    required this.itemPeso,
    required this.itemTam,
    required this.enderecoRetirada,
    this.motoristaId,
    required this.enderecoEntregaId,
    required this.enderecoEntrega,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();
  
  PacoteModel copyWith({
    String? status,
    String? motoristaId,
  }) {
    return PacoteModel(
      firestoreId: this.firestoreId,
      userId: this.userId,
      status: status ?? this.status, // Usa o novo status se fornecido
      motoristaId: motoristaId ?? this.motoristaId, // Usa o novo motoristaId
      itemDesc: this.itemDesc,
      itemPeso: this.itemPeso,
      itemTam: this.itemTam,
      enderecoRetirada: this.enderecoRetirada,
      enderecoEntregaId: this.enderecoEntregaId,
      enderecoEntrega: this.enderecoEntrega,
      createdAt: this.createdAt,
    );
  }


  // Converte o objeto para um Mapa para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'status': status,
      'itemDesc': itemDesc,
      'itemPeso': itemPeso,
      'itemTam': itemTam,
      'enderecoRetirada': enderecoRetirada,
      'enderecoEntregaId': enderecoEntregaId,
      'enderecoEntrega': enderecoEntrega,
      'motoristaId': motoristaId,
      'createdAt': createdAt,
    };
  }

  // Cria um objeto PacoteModel a partir de um documento do Firestore
  factory PacoteModel.fromFirestoreSnapshot(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>? ?? {};

    return PacoteModel(
      firestoreId: snap.id,
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'pendente',
      itemDesc: data['itemDesc'] ?? '',
      itemPeso: data['itemPeso'] ?? '',
      itemTam: data['itemTam'] ?? '',
      // Usamos '?? {}' para garantir que não quebre se o mapa for nulo
      enderecoRetirada: data['enderecoRetirada'] as Map<String, dynamic>? ?? {},
      enderecoEntregaId: data['enderecoEntregaId'] ?? '',
      enderecoEntrega: data['enderecoEntrega'] as Map<String, dynamic>? ?? {},
      motoristaId: data['motoristaId'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
