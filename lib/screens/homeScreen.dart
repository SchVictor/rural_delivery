import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rural_delivery/controller/authController.dart';
import 'package:rural_delivery/screens/cadastroEnderecoScreen.dart';
import 'package:rural_delivery/screens/solicitaFreteScreen.dart';
// 1. --- IMPORTE OS CONTROLADORES E MODELOS NOVOS ---
import 'package:rural_delivery/controller/pacoteController.dart';
import 'package:rural_delivery/models/pacoteModel.dart';
// ... (outros imports)
import 'package:rural_delivery/screens/pacote_detalhes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthController _auth = Get.find<AuthController>();
  // 2. --- ENCONTRE O PACOTE CONTROLLER ---
  final PacoteController _pacoteCtrl = Get.find<PacoteController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (Suas constantes de cores)
    const primaryGreen = Color(0xFF6B8E23);
    const earthyBrown = Color(0xFF8B4513);
    // ...

    return Scaffold(
      // ... (Seu Scaffold, AppBar, e Botão de Endereço)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CadastroEnderecoScreen ());
        },
        backgroundColor: earthyBrown,
        tooltip: 'Cadastrar Novo Endereço',
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
      ),
      
      body: Column(
        children: [
          // --- SEÇÃO DE SAUDAÇÃO ---
          Container(
            // ... (Seu container de saudação)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final String nome = _auth.current.value?.name ?? 'Usuário';
                  return Text(
                    'Olá, $nome!',
                    style: TextStyle(
                      // ... (seu textstyle)
                    ),
                  );
                }),
                // ... (O resto da sua saudação e botões de ação)
                 Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.local_shipping_outlined,
                        title: 'Enviar Pacote',
                        subtitle: 'Solicite uma entrega',
                        color: primaryGreen,
                        onTap: () {
                          // Navega para a tela de solicitar frete
                          Get.to(() => const SolicitaFreteScreen());
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.search_rounded, // Ícone "Realizar Frete"
                        title: 'Realizar Frete',
                        subtitle: 'Ver pacotes pendentes',
                        color: earthyBrown,
                        onTap: () {
                          // Anima para a primeira aba
                          _tabController.animateTo(0);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- ABAS ---
          TabBar(
            controller: _tabController, // <-- ADICIONE ESTA LINHA
             tabs: const [
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Entregas Pendentes',
              ),
              Tab(
                icon: Icon(Icons.check_circle_outline),
                text: 'Fretes Aceitos/Concluidos',
              ),
            ],
          ),

          // --- CONTEÚDO DAS ABAS ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
              
                _buildDeliveriesList(), 

                // Aba 2: Lista de Viajantes (ainda com dados falsos)
                _buildTravelersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }




  // Widget para construir a lista de entregas REAIS
  Widget _buildDeliveriesList() {
    // Envolvemos tudo em um Obx para "ouvir" o _pacoteCtrl
    return Obx(() {
      // Caso 1: Carregando
      if (_pacoteCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
      }

      // Caso 2: Sem pacotes
      if (_pacoteCtrl.pacotes.isEmpty) {
        return const Center(
          child: Text(
            'Nenhuma solicitação de frete pendente.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
      }

      // Caso 3: Lista de pacotes
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        // Usa o tamanho da lista real do controller
        itemCount: _pacoteCtrl.pacotes.length, 
        itemBuilder: (context, index) {
          // Pega o pacote real
          final pacote = _pacoteCtrl.pacotes[index]; 
          
          // Formata os dados para exibição
          String retirada = pacote.enderecoRetirada['rua'] ?? 'Endereço de retirada';
          String entrega = pacote.enderecoEntrega['rua'] ?? 'Endereço de entrega';

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF6B8E23), // primaryGreen
                child: Icon(Icons.archive_outlined, color: Colors.white),
              ),
              // Mostra os dados reais do pacote
              title: Text(
                pacote.itemDesc,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('De: $retirada\nPara: $entrega'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              
              // ======================================================
              // ==               MODIFICAÇÃO FEITA AQUI             ==
              // ======================================================
              onTap: () {
                // Pega o pacote específico que foi clicado
                final pacote = _pacoteCtrl.pacotes[index];
                // Navega para a tela de detalhes, passando o pacote
                Get.to(() => PacoteDetalhesScreen(pacote: pacote));
              },
              // ======================================================
            ),
          );
        },
      );
    });
  }

  // Widget para construir a lista de viajantes (mantém dados falsos por enquanto)
  // Mude o _buildTravelersList (Aba 2)
  Widget _buildTravelersList() {
    // "Ouve" o PacoteController
    return Obx(() {
      // Caso 1: Carregando
      if (_pacoteCtrl.isLoadingAceitos.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF8B4513)));
      }

      // Caso 2: Sem pacotes
      if (_pacoteCtrl.pacotesAceitos.isEmpty) {
        return const Center(
          child: Text(
            'Você ainda não aceitou nenhum frete.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
      }

      // Caso 3: Lista de pacotes aceitos
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pacoteCtrl.pacotesAceitos.length,
        itemBuilder: (context, index) {
          final pacote = _pacoteCtrl.pacotesAceitos[index];
          // Formata os dados
          String retirada = pacote.enderecoRetirada['rua'] ?? 'Retirada';
          String entrega = pacote.enderecoEntrega['rua'] ?? 'Entrega';

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF8B4513), // earthyBrown
                child: Icon(Icons.check, color: Colors.white), // Ícone de check
              ),
              title: Text(
                pacote.itemDesc,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('De: $retirada\nPara: $entrega'),
              trailing: Text(
                pacote.status.toUpperCase(), // Mostra "ACEITO"
                style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Você pode reutilizar a mesma tela de detalhes
                Get.to(() => PacoteDetalhesScreen(pacote: pacote));
              },
            ),
          );
        },
      );
    });
  }

  // Widget auxiliar para criar os botões de ação (sem mudanças)
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    // ... (seu código do _buildActionButton)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}