import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rural_delivery/models/enderecoModel.dart';

class EnderecoRepository {
  final _col = FirebaseFirestore.instance.collection('enderecos');

  // Método para criar (ou atualizar) um endereço
  Future<void> createEnderecoInFirestore(EnderecoModel endereco) async {
    // Se o endereço já tiver um ID do Firestore, ele atualiza.
    // Se não, o .doc() cria um novo ID.
    await _col.doc(endereco.firestoreId).set(endereco.toFirestoreMap());
  }

  // Método para buscar todos os endereços de um usuário
  Future<List<EnderecoModel>> getAllEnderecosFromFirestore(String userId) async {
    final query = await _col.where('userId', isEqualTo: userId).get();
    
    return query.docs.map((doc) => 
        EnderecoModel.fromFirestoreSnapshot(doc)
    ).toList();
  }
}