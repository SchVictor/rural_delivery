// lib/controller/enderecoController.dart

import 'package:get/get.dart';
import 'package:rural_delivery/models/enderecoModel.dart';
import 'package:rural_delivery/repositores/enderecoRepository.dart';
import 'package:rural_delivery/controller/authController.dart';
import 'package:rural_delivery/models/userModel.dart'; // <-- Importe o UserModel

class EnderecoController extends GetxController {
  
  final AuthController authController = Get.find<AuthController>();
  final EnderecoRepository repo = Get.find<EnderecoRepository>(); 

  var enderecos = <EnderecoModel>[].obs; 
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    ever(authController.current, (UserModel? user) {
      if (user != null) {
        // Se o usuário mudou (para logado)
        // AGORA é seguro carregar os endereços dele.
        loadEnderecosDoFirestore(user.firebaseUid);
      } else {
        // Se o usuário mudou (para deslogado)
        // Limpe a lista de endereços da memória.
        enderecos.clear();
      }
    });
    // ======================================================
  }

  // A função agora recebe o userId, não precisa mais procurar
  Future<void> loadEnderecosDoFirestore(String userId) async {

    isLoading(true);
    // Limpa a lista antiga antes de carregar a nova
    enderecos.clear(); 
    enderecos.value = await repo.getAllEnderecosFromFirestore(userId);
    isLoading(false);
    print("Endereços carregados do Firestore: ${enderecos.length}");
  }

  // Ação de Salvar (agora muito mais simples)
 Future<void> registerEndereco({
    required String rua,
    required String numero,
    required String bairro,
    required String cidade,
    required String estado,
    required String cep,
    required String userId, 
  }) async {
    isLoading(true);

    final newEndereco = EnderecoModel(
      rua: rua,
      numero: numero,
      bairro: bairro,
      cidade: cidade,
      estado: estado,
      cep: cep,
      userId: userId,
      whatsApp: rua, //corrigir
      // (Não precisamos de 'status' nem 'id' local)
    );

    try {
      // 1. Tenta salvar direto no Firebase
      // (Esta linha não retorna nada, por isso o 'await' puro)
      await repo.createEnderecoInFirestore(newEndereco);

      // 2. Atualiza a lista local na UI
      // (Nós adicionamos o 'newEndereco' que criamos acima)
      enderecos.add(newEndereco);
      
      Get.back(); // Volta
      Get.snackbar("Sucesso", "Endereço salvo no servidor!"); // Mostra na Home
      
    } catch (e) {
      Get.snackbar("Erro", "Falha ao salvar no servidor: $e");
      // O 'throw' é importante para a tela saber que deu erro
      throw Exception('Falha ao salvar no Firestore'); 
    } finally {
      isLoading(false);
    }
  }
}
 