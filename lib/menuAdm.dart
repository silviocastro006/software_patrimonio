import 'dart:convert';
import 'package:ceetpatrimonio/cadastroModelo.dart';
import 'package:flutter/material.dart';
// Removido import 'package:flutter/services.dart'; // Não usado
import 'package:http/http.dart' as http;
import 'dart:math'; // Importado para DottedBackgroundPainter (se usado)

// ===== Imports das Telas (Verifique se os caminhos estão corretos) =====
import 'main.dart'; // Import da tela de login
import 'busca.dart';
import 'inserir.dart';
import 'excluir.dart';
import 'inserirFuncionario.dart';
import 'movimentacaoPatrimonio.dart';
// Adicione imports para telas de Fornecedores, Relatórios se existirem
// =======================================================================

// MenuAdm StatefulWidget
class MenuAdm extends StatefulWidget {
  const MenuAdm({Key? key}) : super(key: key);

  @override
  _MenuAdmState createState() => _MenuAdmState();
}

class _MenuAdmState extends State<MenuAdm> {
  // Variáveis de estado para dados do resumo
  String alocados = '-';
  String realocados = '-';
  String descartados = '-';
  bool isLoading = true;
  String errorMessage = '';
  String nomeUsuario = "Usuario"; // Nome de usuário (pode vir do login)
  String privilegioUsuario = "Administrador"; // Privilégio (pode vir do login)


  @override
  void initState() {
    super.initState();
    _fetchResumoPatrimonio(); // Busca os dados ao iniciar a tela
    // TODO: Buscar nome e privilégio do usuário se necessário
  }

  // Função para buscar os dados do resumo do backend
  Future<void> _fetchResumoPatrimonio() async {
    // ... (código fetchResumoPatrimonio permanece o mesmo da resposta anterior) ...
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, dynamic> data = {'acao': 'buscaResumoPatrimonio'};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          setState(() {
            alocados = (responseData['data']['Usando'] ?? 0).toString();
            realocados = (responseData['data']['Emprestado'] ?? 0).toString();
            descartados = (responseData['data']['descartado'] ?? 0).toString();
            isLoading = false;
          });
        } else {
          throw Exception(responseData['message'] ?? 'Resposta inválida');
        }
      } else {
        throw Exception('Erro (${response.statusCode})');
      }
    } catch (e) {
      print('Erro ao buscar resumo: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao carregar dados: $e';
        alocados = '0';
        realocados = '0';
        descartados = '0';
      });
    }
  }

  // ===========================================================
  //     FUNÇÃO _buildDrawer MODIFICADA PARA NOVO LAYOUT
  // ===========================================================
  Widget _buildDrawer(BuildContext context) {
    // Cor de fundo do cabeçalho do Drawer
    const Color drawerHeaderColor = Color(0xFF2C3E50); // Azul-escuro acinzentado

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove padding padrão do ListView
        children: <Widget>[
          // --- Cabeçalho Personalizado ---
          Container(
            height: 220, // Altura ajustada para o conteúdo
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: const BoxDecoration(
              color: drawerHeaderColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Ícone de Usuário Grande com Contorno
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0), // Contorno branco
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 60, // Tamanho do ícone interno
                  ),
                ),
                const SizedBox(height: 15),
                // Nome do Usuário
                Text(
                  nomeUsuario, // Use a variável com o nome real
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // Privilégio/Tipo de Usuário
                Text(
                  privilegioUsuario, // Use a variável com o privilégio real
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7), // Cor branca semi-transparente
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // --- Itens de Menu ---
           _buildDrawerItem(
             iconData: Icons.inventory_2_outlined, // Ícone de caixa
             text: 'Cadastro de Patrimônio',
             showPlusIcon: true, // Mostrar o '+' sobreposto
             onTap: () {
               Navigator.pop(context); // Fecha o drawer
               Navigator.push(context, MaterialPageRoute(builder: (context) => const Inserir()));
             }),
          _buildDrawerItem(
             iconData: Icons.handshake_outlined, // Ícone de aperto de mão
             text: 'Cadastro de Fornecedor',
             showPlusIcon: true,
             onTap: () {
               Navigator.pop(context);
               // TODO: Navegar para tela de Cadastro de Fornecedor
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Tela de Cadastro de Fornecedor (Não implementada)'))
               );
             }),
          _buildDrawerItem(
             iconData: Icons.sync_alt, // Ícone de setas circulares
             text: 'Movimentações',
             onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => const Movimentacaopatrimonio()));
             }),
           _buildDrawerItem(
             iconData: Icons.bar_chart_outlined, // Ícone de gráfico de barras
             text: 'Relatórios',
             onTap: () {
                Navigator.pop(context);
                // TODO: Navegar para tela de Relatórios
                ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Tela de Relatórios (Não implementada)'))
               );
             }),
           _buildDrawerItem(
             iconData: Icons.person_add_alt_1_outlined, // Ícone de pessoa com '+'
             text: 'Cadastro de Usuários',
             showPlusIcon: false, // O ícone já tem um '+' visualmente, não precisa sobrepor
             // ou se o ícone base fosse só pessoa: showPlusIcon: true,
             onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => InserirFuncionario()));
             }),

           // --- Divisor e Itens Adicionais (Opcional) ---
           const Divider(thickness: 1, height: 1), // Divisor antes de itens extras
           ListTile(
             leading: const Icon(Icons.refresh, color: Colors.blueGrey),
             title: const Text('Recarregar Dashboard'),
             onTap: () {
               Navigator.pop(context);
               _fetchResumoPatrimonio(); // Recarrega os dados do dashboard
             },
           ),
           ListTile(
             leading: const Icon(Icons.exit_to_app, color: Colors.red),
             title: const Text('Sair', style: TextStyle(color: Colors.red)),
             onTap: () {
               Navigator.pop(context);
               // Navega para a tela de login e remove todas as rotas anteriores
               Navigator.pushAndRemoveUntil(
                 context,
                 MaterialPageRoute(builder: (context) => const MyApp()), // Volta para Login
                 (Route<dynamic> route) => false, // Limpa a pilha de navegação
               );
             },
           ),
        ],
      ),
    );
  }

  // Helper Widget para construir itens do Drawer (com ou sem '+')
  Widget _buildDrawerItem({
    required IconData iconData,
    required String text,
    required VoidCallback onTap,
    bool showPlusIcon = false, // Parâmetro para controlar o '+'
  }) {
    // Cor dos ícones na lista
    final Color iconColor = Colors.grey[700]!;
    // Widget do ícone principal
    Widget leadingIcon = Icon(iconData, color: iconColor, size: 26);

    // Se precisar mostrar o '+', usa um Stack
    if (showPlusIcon) {
      leadingIcon = Stack(
        clipBehavior: Clip.none, // Permite que o '+' fique um pouco fora
        children: [
          // Ícone Base
          Padding(
            padding: const EdgeInsets.all(4.0), // Adiciona espaço para o '+' não colar
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          // Ícone '+' sobreposto
          Positioned(
            bottom: -2, // Ajuste a posição vertical
            right: -2,  // Ajuste a posição horizontal
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.black87, // Fundo do '+'
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5) // Contorno branco opcional
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white, // Cor do '+'
                size: 12, // Tamanho do '+'
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Para o Divider colar no ListTile
      children: [
        ListTile(
          leading: SizedBox(width: 40, height: 40, child: Center(child: leadingIcon)), // Container para alinhar/centralizar o Stack
          title: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          onTap: onTap,
          dense: true, // Torna o ListTile um pouco mais compacto
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Ajuste de padding
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16), // Divisor abaixo de cada item
      ],
    );
  }
  // ===========================================================
  //          FIM DA FUNÇÃO _buildDrawer MODIFICADA
  // ===========================================================


  // --- Restante do código da tela (Build, StatsSection, StatCard, MenuItemsGrid, MenuItem) ---
  // --- Permanece exatamente igual à resposta anterior                                    ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        centerTitle: true,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      // Chama a NOVA função _buildDrawer
      drawer: _buildDrawer(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsSection(),
              const SizedBox(height: 24),
              const Divider(thickness: 1, height: 1),
              const SizedBox(height: 24),
              _buildMenuItemsGrid(context), // A grade de itens no corpo permanece
              if (errorMessage.isNotEmpty && !isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    // ... (código _buildStatsSection permanece o mesmo) ...
     return Stack(
      children: [
        // Fundo de pontos (opcional)
        Positioned.fill(
          child: CustomPaint(
            painter: DottedBackgroundPainter(dotColor: Colors.grey[300]!),
          ),
        ),
        Column(
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
                _buildStatCard(alocados, 'ALOCADOS', const Color(0xFF8BC34A)),
                const SizedBox(height: 16),
                _buildStatCard(realocados, 'REALOCADOS', const Color(0xFFFFCA28)),
                const SizedBox(height: 16),
                _buildStatCard(descartados, 'DESCARTADOS', const Color(0xFFEF5350)),
             ]
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String number, String label, Color backgroundColor) {
    // ... (código _buildStatCard permanece o mesmo) ...
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsGrid(BuildContext context) {
    // ... (código _buildMenuItemsGrid permanece o mesmo, incluindo a lista menuItems) ...
    final List<MenuItemData> menuItems = [
       MenuItemData(
        icon: Icons.storage_outlined,
        title: 'Backup',
        subtitle: 'Último feito em 11/04/2025 às 12:08',
        onTap: () {
          print('Backup Tapped');
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegar para Backup')));
        },
      ),
      /*MenuItemData(
        icon: Icons.people_alt_outlined, // Ícone ajustado para Usuários gerais
        title: 'Usuários',
        subtitle: 'Gerenciar usuários', // Subtítulo ajustado
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => InserirFuncionario())); // Mantido
           print('Usuários Tapped');
        },
      ),*/
      MenuItemData(
        icon: Icons.inventory_2_outlined,
        title: 'Consulta Patrimônios',
        subtitle: '$alocados Alocados, $realocados Realocados', // Subtítulo dinâmico
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => const Busca())); // Mantido
           print('Patrimônios Tapped');
        },
      ),
      MenuItemData(
        icon: Icons.handshake_outlined,
        title: 'Fornecedores',
        subtitle: 'Gerenciar fornecedores', // Subtítulo ajustado
        onTap: () {
          print('Fornecedores Tapped');
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegar para Fornecedores')));
        },
      ),
      MenuItemData(
        icon: Icons.add_box_outlined,
        title: 'Inserir modelo',
        subtitle: 'Adicionar novo modelo',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroModelo())),
      ),
       MenuItemData(
        icon: Icons.sync_alt, // Ícone igual ao do drawer
        title: 'Movimentar',
        subtitle: 'Realocar ou descartar item',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Movimentacaopatrimonio())),
      ),
      /*MenuItemData(
        icon: Icons.delete_outline,
        title: 'Excluir Item',
        subtitle: 'Remover patrimônio',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Excluir())),
      ),*/
       MenuItemData( // Item de relatório adicionado à grade também (opcional)
        icon: Icons.bar_chart_outlined,
        title: 'Relatórios',
        subtitle: 'Visualizar dados',
        onTap: () {
          print('Relatórios Tapped');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navegar para Relatórios')));
        },
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem( // Reutiliza o helper da grade
          icon: menuItems[index].icon,
          title: menuItems[index].title,
          subtitle: menuItems[index].subtitle,
          onTap: menuItems[index].onTap,
        );
      },
    );
  }

  Widget _buildMenuItem({ required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    // ... (código _buildMenuItem para a GRADE permanece o mesmo) ...
     return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
         decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!), // Adicionando uma borda sutil à grade
            borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blueGrey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe auxiliar MenuItemData (permanece a mesma)
class MenuItemData {
  // ... (código MenuItemData permanece o mesmo) ...
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

// Classe DottedBackgroundPainter (permanece a mesma)
class DottedBackgroundPainter extends CustomPainter {
  // ... (código DottedBackgroundPainter permanece o mesmo) ...
   final Color dotColor;
 final double dotSize;
 final double spacing;

 DottedBackgroundPainter({
    this.dotColor = Colors.grey,
    this.dotSize = 1.5,
    this.spacing = 12.0,
 });

 @override
 void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final double endX = size.width * 0.6;
    final double endY = size.height;

    for (double x = spacing / 2; x < endX; x += spacing) {
      for (double y = spacing / 2; y < endY; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
 }

 @override
 bool shouldRepaint(CustomPainter oldDelegate) => false;
}