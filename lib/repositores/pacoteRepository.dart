import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rural_delivery/models/pacoteModel.dart';

class PacoteRepository {
  // 1. Muda a coleção para 'pacotes'
  final _col = FirebaseFirestore.instance.collection('pacotes');

  // Cria um novo pacote no Firestore
  Future<PacoteModel> createPacoteInFirestore(PacoteModel pacote) async {
    try {
      // 1. Gera um novo ID de documento
      final docRef = _col.doc();
      
      // 2. Atualiza o ID no modelo ANTES de salvar
      pacote.firestoreId = docRef.id;

      // 3. Salva no Firestore
      await docRef.set(pacote.toFirestore());

      // 4. Retorna o modelo completo (com o ID)
      return pacote;
    } catch (e) {
      print("Erro ao criar pacote no Firestore: $e");
      rethrow;
    }
  }

  // Busca todos os pacotes que estão PENDENTES
  Future<List<PacoteModel>> getAllPacotesPendentes() async {
    try {
      final query = await _col
          .where('status', isEqualTo: 'pendente')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => PacoteModel.fromFirestoreSnapshot(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar pacotes pendentes: $e");
      return [];
    }
  }

  // ATUALIZA o status e define o motorista
  Future<void> aceitarFrete(String pacoteId, String motoristaId) async {
    await _col.doc(pacoteId).update({
      'status': 'aceito', // Muda o status
      'motoristaId': motoristaId, // Define o "dono" do frete
    });
  }

  // BUSCA os fretes aceitos pelo usuário logado
  Future<List<PacoteModel>> getMeusFretesAceitos(String motoristaId) async {
    try {
      final query = await _col
          .where('motoristaId', isEqualTo: motoristaId)
          .orderBy('createdAt', descending: true)
          .get(); // NOTA: Isso pode exigir um novo índice do Firebase!

      return query.docs
          .map((doc) => PacoteModel.fromFirestoreSnapshot(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar fretes aceitos: $e");
      // Se der erro de índice, o Firebase lhe dará o link no console.
      return [];
    }
  }

}