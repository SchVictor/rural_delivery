import 'package:get/get.dart';
import 'package:rural_delivery/models/enderecoModel.dart';
import 'package:rural_delivery/repositores/enderecoRepository.dart';
import 'package:rural_delivery/controller/authController.dart';

class EnderecoController extends GetxController {
  
  final AuthController authController = Get.find<AuthController>();
  final EnderecoRepository repo = Get.find<EnderecoRepository>(); 

  var enderecos = <EnderecoModel>[].obs; 
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Carrega os endereços do Firestore quando o app inicia
    loadEnderecosDoFirestore(); 
  }

  // Carrega os endereços do Firestore
  Future<void> loadEnderecosDoFirestore() async {
    final userId = authController.current.value?.firebaseUid;
    if (userId == null) return;

    isLoading(true);
    enderecos.value = await repo.getAllEnderecosFromFirestore(userId);
    isLoading(false);
  }

  // Ação de Salvar (agora muito mais simples)
  Future<void> registerEndereco({
    required String rua,
    required String numero,
    required String bairro,
    required String cidade,
    required String estado,
    required String cep,
    required String complemento,
    required String whatsApp,



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
      complemento: complemento,
      whatsApp: whatsApp,

      userId: userId,
      // (Não precisamos de 'status' nem 'id' local)
    );

    try {
      // 1. Tenta salvar direto no Firebase
      await repo.createEnderecoInFirestore(newEndereco);

      // 2. Atualiza a lista local na UI
      enderecos.add(newEndereco);
      
      Get.snackbar("Sucesso", "Endereço salvo no servidor!");
      
    } catch (e) {
      Get.snackbar("Erro", "Falha ao salvar no servidor: $e");
      throw Exception('Falha ao salvar no Firestore');
    } finally {
      isLoading(false);
    }
  }
}