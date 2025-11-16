import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rural_delivery/models/pacoteModel.dart';

import 'package:rural_delivery/repositores/pacoteRepository.dart';
import 'package:rural_delivery/controller/authController.dart';
import 'package:rural_delivery/models/userModel.dart'; 

class PacoteController extends GetxController {
  
  final AuthController authController = Get.find<AuthController>();
  final PacoteRepository repo = Get.find<PacoteRepository>(); 

  // 1. Muda a lista de 'enderecos' para 'pacotes'
  var pacotes = <PacoteModel>[].obs; 
  var pacotesAceitos = <PacoteModel>[].obs; // (Para a Aba 2)
  var isLoading = false.obs;
  var isLoadingAceitos = false.obs; // Loading separado para a Aba 2

  @override
  void onInit() {
    super.onInit();
    // Usa a mesma lógica "ouvinte" do EnderecoController
    // Carrega os pacotes assim que o usuário é confirmado
    ever(authController.current, (UserModel? user) {
      if (user != null) {
        loadPacotesPendentes(); // Carrega a lista
        loadPacotesAceitos(user.firebaseUid);
      } else {
        pacotes.clear(); // Limpa a lista no logout
        pacotesAceitos.clear();
      }
    });
  }

  // Busca os pacotes do repositório
  Future<void> loadPacotesPendentes() async {
    isLoading(true);
    pacotes.clear(); 
    pacotes.value = await repo.getAllPacotesPendentes();
    isLoading(false);
    print("Pacotes pendentes carregados: ${pacotes.length}");
  }
  Future<void> loadPacotesAceitos(String motoristaId) async {
    isLoadingAceitos(true);
    pacotesAceitos.clear();
    pacotesAceitos.value = await repo.getMeusFretesAceitos(motoristaId);
    isLoadingAceitos(false);
  }

  // Ação de Salvar (chamada pela SolicitarFreteScreen)
  Future<void> registerPacote({
    // Dados do Item
    required String itemDesc,
    required String itemPeso,
    required String itemTam,
    // Dados da Retirada
    required Map<String, dynamic> enderecoRetirada,
    // Dados da Entrega
    required String enderecoEntregaId,
    required Map<String, dynamic> enderecoEntrega,
    // Dados do Usuário
    required String userId, 
  }) async {
    isLoading(true);

    final newPacote = PacoteModel(
      userId: userId,
      itemDesc: itemDesc,
      itemPeso: itemPeso,
      itemTam: itemTam,
      enderecoRetirada: enderecoRetirada,
      enderecoEntregaId: enderecoEntregaId,
      enderecoEntrega: enderecoEntrega,
      createdAt: Timestamp.now(), 
      // status já é 'pendente' por padrão
    );

    try {
      // 1. Tenta salvar no Firebase
      final savedPacote = await repo.createPacoteInFirestore(newPacote);

      // 2. Atualiza a lista local na UI (para a HomeScreen ver)
      pacotes.add(savedPacote);
      
      Get.back(); // Volta
      Get.snackbar("Sucesso!", "Sua solicitação de frete foi registrada.");
      
    } catch (e) {
      Get.snackbar("Erro", "Falha ao salvar pacote: $e");
      throw Exception('Falha ao salvar no Firestore');
    } finally {
      isLoading(false);
    }

  }

  Future<void> aceitarFrete(PacoteModel pacote) async {
    // Pega o ID do motorista
    final String? motoristaId = authController.current.value?.firebaseUid;
    if (motoristaId == null) {
      Get.snackbar("Erro", "Você não está logado.");
      return;
    }

    try {
      // 1. Chama o Repositório para atualizar o Firebase
      await repo.aceitarFrete(pacote.firestoreId!, motoristaId);

      // 2. Atualiza as listas locais (A MÁGICA)
      pacotes.remove(pacote); // Remove da Aba 1
      
      // Adiciona na Aba 2 (com o status e motoristaId atualizados)
      pacotesAceitos.add(pacote.copyWith(
        status: 'aceito',
        motoristaId: motoristaId,
      ));

      // 3. Feedback visual (igual ao simulado)
      Get.back(); // Fecha a tela de detalhes
      Get.snackbar(
        'Sucesso!',
        'Você aceitou o frete de ${pacote.itemDesc}!',
        backgroundColor: const Color(0xFF6B8E23), // primaryGreen
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar("Erro", "Falha ao aceitar frete: $e");
    }
  }
}