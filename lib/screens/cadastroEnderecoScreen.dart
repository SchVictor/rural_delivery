import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rural_delivery/controller/authController.dart';
import 'package:rural_delivery/controller/enderecoController.dart';

class CadastroEnderecoScreen extends StatefulWidget {
  // Se você quiser editar um endereço, você passaria ele aqui
  // final EnderecoModel? endereco; 
  // const EnderecoFormScreen({super.key, this.endereco});
  
  // Por enquanto, só cadastro:
  const CadastroEnderecoScreen({super.key});

  @override
  State<CadastroEnderecoScreen> createState() => _CadastroEnderecoScreen();
}

class _CadastroEnderecoScreen extends State<CadastroEnderecoScreen> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  final _ruaCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _complementoCtrl = TextEditingController();
  final _whatsAppCtrl = TextEditingController();

  // Controladores globais (que já "vivem" na memória)
  final AuthController _auth = Get.find<AuthController>();
  final EnderecoController _enderecoCtrl = Get.find<EnderecoController>();

  @override
  void dispose() {
    _ruaCtrl.dispose();
    _numeroCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _cepCtrl.dispose();
    _complementoCtrl.dispose();
    _whatsAppCtrl.dispose();

    super.dispose();
  }

  // Função principal de salvar
  Future<void> _saveForm() async {
    // 1. Valida o formulário
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Erro', 'Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    // 2. Pega o ID do usuário logado (O "LINK"!)
    final String? userId = _auth.current.value?.firebaseUid;

    if (userId == null) {
      Get.snackbar('Erro Fatal', 'Você não está logado.');
      return;
    }

    // 3. Chama o EnderecoController para fazer a lógica
    try {
      await _enderecoCtrl.registerEndereco(
        rua: _ruaCtrl.text,
        numero: _numeroCtrl.text,
        bairro: _bairroCtrl.text,
        cidade: _cidadeCtrl.text,
        estado: _estadoCtrl.text,
        cep: _cepCtrl.text,
        
        complemento: _complementoCtrl.text, 
        whatsApp: _whatsAppCtrl.text , 

        userId: userId,
      );

      // 4. Sucesso!
      Get.snackbar('Sucesso!', 'Endereço salvo localmente e pronto para sincronizar.');
      Get.back(); // Volta para a HomeScreen

    } catch (e) {
      Get.snackbar('Erro ao Salvar', 'Não foi possível salvar o endereço: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cores (para manter o tema)
    const primaryGreen = Color(0xFF6B8E23);
    const earthyBrown = Color(0xFF8B4513);
    const lightBackgroundGreen = Color(0xFFE0E6C8);
    
    return Scaffold(
      backgroundColor: lightBackgroundGreen,
      appBar: AppBar(
        title: const Text('Cadastrar Endereço'),
        backgroundColor: primaryGreen,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_ruaCtrl, 'Rua / Avenida', 'Ex: Av. Principal'),
            _buildTextField(_numeroCtrl, 'Número', 'Ex: 123'),
            _buildTextField(_bairroCtrl, 'Bairro', 'Ex: Centro'),
            _buildTextField(_cidadeCtrl, 'Cidade', 'Ex: Anápolis'),
            _buildTextField(_estadoCtrl, 'Estado', 'Ex: GO'),
            _buildTextField(_cepCtrl, 'CEP', 'Ex: 75000-000', keyboardType: TextInputType.number),
            
            const SizedBox(height: 32),
            
            // Botão Salvar (ouvindo o estado de loading do controller)
            Obx(() {
              // Pega o estado de 'isLoading' do EnderecoController
              final bool isLoading = _enderecoCtrl.isLoading.value; 
              
              return ElevatedButton.icon(
                icon: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(isLoading ? 'Salvando...' : 'Salvar Endereço'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: earthyBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Desabilita o botão se estiver carregando
                onPressed: isLoading ? null : _saveForm, 
              );
            }),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar os campos de texto
  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF6B8E23), width: 2), // primaryGreen
          ),
        ),
        // Validação simples
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label é obrigatório(a).';
          }
          return null;
        },
      ),
    );
  }
}