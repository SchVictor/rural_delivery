import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rural_delivery/controller/authController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Usamos o 'SingleTickerProviderStateMixin' para a animação do TabController
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthController _auth =
      Get.find<AuthController>(); // Encontra a instância já criada

  @override
  void initState() {
    super.initState();
    // Inicializa o TabController com 2 abas
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reutilizando a paleta de cores da LoginScreen para consistência
    const primaryGreen = Color(0xFF6B8E23);
    const earthyBrown = Color(0xFF8B4513);
    const lightBackgroundGreen = Color(0xFFE0E6C8);
    const textDark = Color(0xFF36454F);
    const offWhite = Color(0xFFFDFDFD);

    return Scaffold(
      backgroundColor: lightBackgroundGreen,
      appBar: AppBar(
        title: const Text(
          'Logística Inclusiva',
          style: TextStyle(
            color: offWhite,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: offWhite),
            tooltip: 'Sair',
            onPressed: () {
              // Adicione uma caixa de diálogo de confirmação se desejar
              _auth.logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- SEÇÃO DE SAUDAÇÃO E AÇÕES PRINCIPAIS ---
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: offWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Você precisará carregar o nome do usuário no seu AuthController
                  'Olá, Usuário!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O que você precisa hoje?',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                // --- BOTÕES DE AÇÃO ---
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.local_shipping_outlined,
                        title: 'Enviar Pacote',
                        subtitle: 'Solicite uma entrega',
                        color: primaryGreen,
                        onTap: () {
                          // TODO: Navegar para a tela de solicitar entrega
                          Get.snackbar(
                            'Ação',
                            'Navegando para a tela de envio de pacote...',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.directions_car_filled_outlined,
                        title: 'Oferecer Carona',
                        subtitle: 'Transporte um pacote',
                        color: earthyBrown,
                        onTap: () {
                          // TODO: Navegar para a tela de oferecer carona
                          Get.snackbar(
                            'Ação',
                            'Navegando para a tela de oferecer carona...',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- ABAS PARA VER ATIVIDADES ---
          TabBar(
            controller: _tabController,
            indicatorColor: earthyBrown,
            labelColor: textDark,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.inventory_2_outlined),
                text: 'Entregas Pendentes',
              ),
              Tab(
                icon: Icon(Icons.people_alt_outlined),
                text: 'Viajantes Disponíveis',
              ),
            ],
          ),

          // --- CONTEÚDO DAS ABAS ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba 1: Lista de Entregas
                _buildDeliveriesList(),
                // Aba 2: Lista de Viajantes
                _buildTravelersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar os botões de ação
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  // DADOS DE EXEMPLO - Substitua por dados do Firestore
  final List<Map<String, String>> pendingDeliveries = [
    {
      'from': 'Zona Rural de Pirenópolis, GO',
      'to': 'Centro, Anápolis, GO',
      'package': 'Caixa de Ferramentas',
    },
    {
      'from': 'Distrito de Souzânia, GO',
      'to': 'Rodoviária, Goiânia, GO',
      'package': 'Peças de Trator',
    },
    {
      'from': 'Fazenda Santa Brígida, GO',
      'to': 'Correios, Alexânia, GO',
      'package': 'Documentos Importantes',
    },
  ];

  final List<Map<String, String>> availableTravelers = [
    {
      'name': 'João da Silva',
      'route': 'Pirenópolis > Anápolis',
      'date': '10/11/2025',
    },
    {
      'name': 'Maria Oliveira',
      'route': 'Corumbá de Goiás > Goiânia',
      'date': '12/11/2025',
    },
  ];

  // Widget para construir a lista de entregas
  Widget _buildDeliveriesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingDeliveries.length,
      itemBuilder: (context, index) {
        final delivery = pendingDeliveries[index];
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
            title: Text(
              delivery['package']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('De: ${delivery['from']}\nPara: ${delivery['to']}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }

  // Widget para construir a lista de viajantes
  Widget _buildTravelersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableTravelers.length,
      itemBuilder: (context, index) {
        final traveler = availableTravelers[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF8B4513), // earthyBrown
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            title: Text(
              traveler['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Rota: ${traveler['route']}\nData: ${traveler['date']}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }
}
