import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as _auth;
import 'package:rural_delivery/controller/authController.dart';
import 'package:rural_delivery/controller/enderecoController.dart';
import 'package:rural_delivery/controller/pacoteController.dart';
import 'package:rural_delivery/models/enderecoModel.dart'; // Precisamos do modelo

class SolicitaFreteScreen extends StatefulWidget {
  const SolicitaFreteScreen({super.key});

  @override
  State<SolicitaFreteScreen> createState() => _SolicitarFreteScreenState();
}

class _SolicitarFreteScreenState extends State<SolicitaFreteScreen> {
  // Chave para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // --- Controladores dos Campos de Texto ---
  // 1. Detalhes do Item
  final _itemDescCtrl = TextEditingController();
  final _itemPesoCtrl = TextEditingController(); // Peso (ex: "2kg")
  final _itemTamCtrl = TextEditingController(); // Tamanho (ex: "Caixa Média")

  // 2. Endereço de RETIRADA (manual)
  final _retiradaRuaCtrl = TextEditingController();
  final _retiradaNumCtrl = TextEditingController();
  final _retiradaBairroCtrl = TextEditingController();
  final _retiradaCidadeCtrl = TextEditingController();
  final _retiradaCepCtrl = TextEditingController();

  // 3. Endereço de ENTREGA (puxado do controller)
  EnderecoModel? _selectedEndereco; // Armazena o endereço selecionado no dropdown
  final AuthController _auth = Get.find<AuthController>(); // <-- ADICIONE ESTA LINHA
  final PacoteController _pacoteCtrl = Get.find<PacoteController>(); // <-- ADICIONE ESTA LINHA

  // --- Controladores Globais ---
  // Não precisamos do AuthController aqui, *ainda*.
  // Vamos pegar o EnderecoController para carregar a lista.
  final EnderecoController _enderecoCtrl = Get.find<EnderecoController>();

  @override
  void dispose() {
    // Limpeza de todos os controladores de texto
    _itemDescCtrl.dispose();
    _itemPesoCtrl.dispose();
    _itemTamCtrl.dispose();
    _retiradaRuaCtrl.dispose();
    _retiradaNumCtrl.dispose();
    _retiradaBairroCtrl.dispose();
    _retiradaCidadeCtrl.dispose();
    _retiradaCepCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // 1. Valida todos os campos do formulário
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Campos inválidos', 'Por favor, preencha todos os dados.');
      return;
    }

    // 1. Pegue o ID do usuário
  final String? userId = _auth.current.value?.firebaseUid;
  if (userId == null) { /* ... mostre erro ... */ return; }

  // 2. Crie os mapas de endereço
  final Map<String, dynamic> retiradaMap = {
    'rua': _retiradaRuaCtrl.text,
    'numero': _retiradaNumCtrl.text,
    'bairro': _retiradaBairroCtrl.text,
    'cidade': _retiradaCidadeCtrl.text,
    'cep': _retiradaCepCtrl.text,
  };

  final Map<String, dynamic> entregaMap = {
    'rua': _selectedEndereco!.rua,
    'numero': _selectedEndereco!.numero,
    'cidade': _selectedEndereco!.cidade,
    // ... (etc, para duplicar os dados)
  };

  // 3. Chame o controller (ele cuida do Get.back e snackbar)
  try {
    await _pacoteCtrl.registerPacote(
      itemDesc: _itemDescCtrl.text,
      itemPeso: _itemPesoCtrl.text,
      itemTam: _itemTamCtrl.text,
      enderecoRetirada: retiradaMap,
      enderecoEntregaId: _selectedEndereco!.firestoreId!,
      enderecoEntrega: entregaMap,
      userId: userId,
    );
  } catch (e) {
    // O controller já mostra o snackbar de erro
  }
}

  @override
  Widget build(BuildContext context) {
    // Cores do Tema
    const primaryGreen = Color(0xFF6B8E23);
    const earthyBrown = Color(0xFF8B4513);
    const lightBackgroundGreen = Color(0xFFE0E6C8);

    return Scaffold(
      backgroundColor: lightBackgroundGreen,
      appBar: AppBar(
        title: const Text('Solicitar Frete'),
        backgroundColor: primaryGreen,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- 1. SEÇÃO DO ITEM ---
            _buildSectionTitle('Sobre o Pacote'),
            _buildTextField(_itemDescCtrl, 'Descrição do item', 'Ex: Peças de trator'),
            _buildTextField(_itemPesoCtrl, 'Peso aproximado', 'Ex: 5kg'),
            _buildTextField(_itemTamCtrl, 'Tamanho aproximado', 'Ex: Caixa de sapatos'),
            
            const Divider(height: 30, thickness: 1),

            // --- 2. SEÇÃO DE RETIRADA ---
            _buildSectionTitle('Endereço de Retirada'),
            _buildTextField(_retiradaRuaCtrl, 'Rua / Avenida', 'Ex: Rua da Fazenda'),
            _buildTextField(_retiradaNumCtrl, 'Número', 'Ex: S/N'),
            _buildTextField(_retiradaBairroCtrl, 'Bairro / Localidade', 'Ex: Zona Rural'),
            _buildTextField(_retiradaCidadeCtrl, 'Cidade', 'Ex: Pirenópolis'),
            _buildTextField(_retiradaCepCtrl, 'CEP (Opcional)', '', isRequired: false),
            
            const Divider(height: 30, thickness: 1),

            // --- 3. SEÇÃO DE ENTREGA (A PARTE INTELIGENTE) ---
            _buildSectionTitle('Endereço de Entrega'),
            // Usamos Obx para "ouvir" a lista de endereços do EnderecoController
            Obx(() {
              // Se a lista estiver vazia, mostramos um aviso
              if (_enderecoCtrl.enderecos.isEmpty) {
                return Text(
                  'Você ainda não cadastrou nenhum endereço. '
                  'Por favor, cadastre um endereço na tela principal primeiro.',
                  style: TextStyle(color: Colors.red.shade700),
                );
              }

              // Se a lista tiver endereços, mostramos o Dropdown
              return DropdownButtonFormField<EnderecoModel>(
                value: _selectedEndereco,
                hint: const Text('Selecione um endereço cadastrado'),
                isExpanded: true,
                decoration: _buildInputDecoration(''), // (InputDecoration auxiliar)
                items: _enderecoCtrl.enderecos.map((endereco) {
                  return DropdownMenuItem<EnderecoModel>(
                    value: endereco,
                    // Mostra a rua e o número no item do dropdown
                    child: Text('${endereco.rua}, ${endereco.numero}'), 
                  );
                }).toList(),
                onChanged: (EnderecoModel? newValue) {
                  setState(() {
                    _selectedEndereco = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um endereço de entrega.';
                  }
                  return null;
                },
              );
            }),

            const SizedBox(height: 32),

            // --- BOTÃO DE SUBMISSÃO ---
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: earthyBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Solicitar Transporte'),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA LIMPEZA ---
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.bold, 
          color: Color(0xFF6B8E23), // primaryGreen
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, 
      {bool isRequired = true, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _buildInputDecoration(label, hintText: hint),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return '$label é obrigatório(a).';
          }
          return null;
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, {String? hintText}) {
     return InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6B8E23), width: 2), // primaryGreen
        ),
      );
  }
}