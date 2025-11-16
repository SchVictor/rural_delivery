import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rural_delivery/controller/pacoteController.dart';
import 'package:rural_delivery/models/pacoteModel.dart';

class PacoteDetalhesScreen extends StatelessWidget {
  // 1. Recebe o PacoteModel da tela anterior
  final PacoteModel pacote;
  const PacoteDetalhesScreen({super.key, required this.pacote});
  


  @override
  Widget build(BuildContext context) {
    // Cores do Tema
    const primaryGreen = Color(0xFF6B8E23);
    const earthyBrown = Color(0xFF8B4513);
    const lightBackgroundGreen = Color(0xFFE0E6C8);
    const textDark = Color(0xFF36454F);
    final PacoteController _pacoteCtrl = Get.find<PacoteController>();

    return Scaffold(
      backgroundColor: lightBackgroundGreen,
      appBar: AppBar(
        title: const Text('Detalhes da Entrega'),
        backgroundColor: primaryGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SEÇÃO DO PACOTE ---
          _buildSectionTitle('Pacote', textDark),
          _buildDetailCard(earthyBrown, [
            _buildDetailRow('Descrição:', pacote.itemDesc),
            _buildDetailRow('Peso Aprox.:', pacote.itemPeso),
            _buildDetailRow('Tamanho Aprox.:', pacote.itemTam),
          ]),

          // --- SEÇÃO DE RETIRADA ---
          _buildSectionTitle('Endereço de Retirada', textDark),
          _buildDetailCard(earthyBrown, [
            _buildDetailRow('Rua:', pacote.enderecoRetirada['rua'] ?? 'N/A'),
            _buildDetailRow('Número:', pacote.enderecoRetirada['numero'] ?? 'N/A'),
            _buildDetailRow('Bairro:', pacote.enderecoRetirada['bairro'] ?? 'N/A'),
            _buildDetailRow('Cidade:', pacote.enderecoRetirada['cidade'] ?? 'N/A'),
            _buildDetailRow('CEP:', pacote.enderecoRetirada['cep'] ?? 'N/A'),
          ]),

          // --- SEÇÃO DE ENTREGA ---
          _buildSectionTitle('Endereço de Entrega', textDark),
          _buildDetailCard(earthyBrown, [
            _buildDetailRow('Rua:', pacote.enderecoEntrega['rua'] ?? 'N/A'),
            _buildDetailRow('Número:', pacote.enderecoEntrega['numero'] ?? 'N/A'),
            _buildDetailRow('Cidade:', pacote.enderecoEntrega['cidade'] ?? 'N/A'),
          ]),

          const SizedBox(height: 32),

          // --- BOTÃO DE AÇÃO ---
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Aceitar Frete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              
              Get.back(); // Fecha a tela de detalhes
              Get.snackbar(
                'Sucesso!',
                'Você aceitou o frete de ${pacote.itemDesc}!',
                backgroundColor: primaryGreen,
                colorText: Colors.white,
              );
              _pacoteCtrl.aceitarFrete(pacote);
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE UI ---

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailCard(Color borderColor, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: borderColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
