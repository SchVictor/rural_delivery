import 'package:cloud_firestore/cloud_firestore.dart';

class EnderecoModel {
  int? id;
  String? firestoreId;

  String userId; // O "link" com o usuário (firebaseUid)

  String rua;
  String numero;
  String bairro;
  String cidade;
  String estado;
  String cep;
  String? complemento;
  String? whatsApp;

  String status;

  EnderecoModel({
    this.id,
    this.firestoreId,
    required this.userId, // <-- Adicione aqui
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.whatsApp,

    this.complemento,
    

    this.status = 'pending',
  });


  // --- Para o SQFLite (Local) ---
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'userId': userId, // <-- Adicione aqui
      'rua': rua,
      'numero': numero,
      'status': status,
    };
  }

  factory EnderecoModel.fromLocalMap(Map<String, dynamic> map) {
    return EnderecoModel(
      id: map['id'],
      firestoreId: map['firestoreId'],
      userId: map['userId'], // <-- Adicione aqui
      rua: map['rua'],
      numero: map['numero'],
      bairro: map['bairro'],
      cidade: map['cidade'],
      estado: map['estado'],
      cep: map['cep'],
      complemento: map['complemento'],
      whatsApp: map['whatsApp'],


      status: map['status'],
    );
  }

  // --- Para o Firestore (Remoto) ---
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId, // <-- Adicione aqui
      'rua': rua,
      'numero': numero,
      // ...
    };
  }

factory EnderecoModel.fromFirestoreSnapshot(DocumentSnapshot snap) {
    // Adiciona '?? {}' para segurança extra
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>? ?? {}; 
    
    return EnderecoModel(
      firestoreId: snap.id,
      // Fornece um valor padrão ('') caso o campo não exista no Firestore
      userId: data['userId'] ?? '', 
      rua: data['rua'] ?? '',
      numero: data['numero'] ?? '',
      bairro: data['bairro'] ?? '',
      cidade: data['cidade'] ?? '',
      estado: data['estado'] ?? '',
      cep: data['cep'] ?? '',


      status: 'synced', // Correto, pois veio do Firestore
    );
  }
}
