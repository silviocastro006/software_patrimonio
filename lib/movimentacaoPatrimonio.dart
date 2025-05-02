import 'dart:convert';        // Para json.decode
import 'dart:math';          // Para min() nos logs
import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:http/http.dart' as http; // Requisições HTTP

// --- Imports das Telas (GARANTA QUE ESTÃO CORRETOS) ---
import 'main.dart';                  // Para Sair e ir pro Login
import 'menuAdm.dart';               // Para Voltar ao Dashboard
import 'busca.dart';                 // Para item de menu Patrimônios/Consulta
import 'inserir.dart';               // Para item de menu Inserir Item
import 'excluir.dart';               // Para item de menu Excluir Item
import 'inserirFuncionario.dart';    // Para item de menu Cadastro de Usuários
// A importação de 'movimentacaoPatrimonio.dart' abaixo é para a tela de Inserir, não para ela mesma
import 'movimentacaoPatrimonio.dart';  // TELA NOVA - Para o FAB

// --- Fim dos Imports ---


// Definição do StatefulWidget
class Movimentacaopatrimonio extends StatefulWidget {
  const Movimentacaopatrimonio({Key? key}) : super(key: key);

  @override
  _MovimentacaopatrimonioState createState() => _MovimentacaopatrimonioState();
}

// Classe State
class _MovimentacaopatrimonioState extends State<Movimentacaopatrimonio> {
  // --- Controladores e Variáveis de Estado ---
  final TextEditingController _filterController = TextEditingController();
  List<Map<String, dynamic>> _patrimonios = [];
  List<Map<String, dynamic>> _filteredPatrimonios = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // --- Variáveis para o Drawer (copiadas/adaptadas de MenuAdm) ---
  String nomeUsuario = "Usuário"; // TODO: Obter nome real do usuário logado
  String privilegioUsuario = "Admin"; // TODO: Obter privilégio real

  @override
  void initState() {
    super.initState();
    print("initState: Carregando Patrimônios/Movimentações...");
    _fetchPatrimonios();
    // TODO: Obter nomeUsuario e privilegioUsuario se vierem do login/estado global
  }

  @override
  void dispose() {
    _filterController.dispose();
    print("dispose: Filtro controller limpo (Movimentacoes).");
    super.dispose();
  }

  // --- Funções Lógicas (fetch, filter, atualizarStatus - Mantidas como antes) ---
  Future<void> _fetchPatrimonios() async {
    // ... (código _fetchPatrimonios idêntico à resposta anterior) ...
     setState(() { _isLoading = true; _errorMessage = ''; });
    print("Executando _fetchPatrimonios (Movimentacoes)...");
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, String> data = {'acao': 'listar'};
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 20));
      print("Resposta Listar/Movimentações (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 300))}...");
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success' && responseBody['produtos'] != null && responseBody['produtos'] is List) {
           print("Dados recebidos com sucesso.");
          setState(() {
            _patrimonios = List<Map<String, dynamic>>.from(responseBody['produtos'])
                .where((p) => p is Map).map((p) => Map<String, dynamic>.from(p)).toList();
            _filteredPatrimonios = List.from(_patrimonios);
            _isLoading = false;
            print("Dados atualizados no estado: ${_patrimonios.length} itens");
          });
        } else {
           print("Erro backend (listar/mov): ${responseBody['message'] ?? 'Formato inválido.'}");
          setState(() { _errorMessage = 'Erro ao buscar: ${responseBody['message'] ?? 'Formato inválido.'}'; _isLoading = false; });
        }
      } else {
         print("Erro HTTP (listar/mov): ${response.statusCode}");
         setState(() { _errorMessage = 'Erro de comunicação (${response.statusCode}).'; _isLoading = false; });
      }
    } catch (error, stackTrace) {
      print("Erro CATCH (listar/mov): $error");
      print("StackTrace Listar/Mov: $stackTrace");
       setState(() { _errorMessage = 'Erro durante a requisição: $error'; _isLoading = false; });
    }
  }

  void _filterPatrimonios(String query) {
    // ... (código _filterPatrimonios idêntico à resposta anterior) ...
      print("Filtrando movimentações com query: '$query'");
    setState(() {
      if (query.isEmpty) {
        _filteredPatrimonios = List.from(_patrimonios);
        print("Filtro vazio, mostrando todos: ${_filteredPatrimonios.length} itens");
      } else {
        _filteredPatrimonios = _patrimonios.where((patrimonio) {
          final codigoLower = patrimonio['codigo']?.toString().toLowerCase() ?? '';
          final setorLower = patrimonio['setor']?.toString().toLowerCase() ?? '';
          final statusLower = patrimonio['status']?.toString().toLowerCase() ?? '';
          final queryLower = query.toLowerCase();
          return codigoLower.contains(queryLower) || setorLower.contains(queryLower) || statusLower.contains(queryLower);
        }).toList();
        print("Filtro aplicado, encontrados: ${_filteredPatrimonios.length} itens");
      }
    });
  }

   Future<void> _atualizarStatus(String id, String novoStatus) async {
     // ... (código _atualizarStatus idêntico à resposta anterior) ...
     print("Executando _atualizarStatus ID: $id, Novo Status: $novoStatus");
     const String url = "http://localhost/server/processa_bdCeet.php";
     final Map<String, dynamic> data = {'acao': 'atualizarStatus', 'id': id, 'status': novoStatus};
     try {
       final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json; charset=UTF-8'}, body: json.encode(data));
        print("Resposta Atualizar Status (${response.statusCode}): ${response.body}");
       if (response.statusCode == 200) {
         final responseBody = json.decode(response.body);
         if (responseBody['status'] == 'success') {
            print("Status atualizado com sucesso.");
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status atualizado para $novoStatus!'), backgroundColor: Colors.green));
           _fetchPatrimonios();
         } else {
            print("Erro backend (atualizar status): ${responseBody['message']}");
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar: ${responseBody['message']}'), backgroundColor: Colors.red));
         }
       } else {
          print("Erro HTTP (atualizar status): ${response.statusCode}");
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro de comunicação (${response.statusCode}).'), backgroundColor: Colors.red));
       }
     } catch (error, stackTrace) {
       print("Erro CATCH (atualizar status): $error");
       print("StackTrace Atualizar Status: $stackTrace");
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao atualizar status.'), backgroundColor: Colors.red));
     }
   }


  // ===========================================================
  //     FUNÇÃO _buildDrawer COPIADA/ADAPTADA DE MenuAdm
  // ===========================================================
  Widget _buildDrawer(BuildContext context) {
    const Color drawerHeaderColor = Color(0xFF2C3E50); // Cor padrão do header

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Cabeçalho Personalizado
          Container(
            height: 220,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: const BoxDecoration(color: drawerHeaderColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container( // Ícone de Usuário
                  width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.0)),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 60),
                ),
                const SizedBox(height: 15),
                Text(nomeUsuario, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), // Usa variável de estado
                const SizedBox(height: 5),
                Text(privilegioUsuario, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)), // Usa variável de estado
              ],
            ),
          ),

          // Itens de Menu (copiados de MenuAdm, navegação ajustada)
          _buildDrawerItem(
             iconData: Icons.inventory_2_outlined, // Ícone de caixa/patrimônio
             text: 'Cadastro de Patrimônio',
             showPlusIcon: true, // Mostrar o '+' sobreposto
             onTap: () {
               Navigator.pop(context); // Fecha drawer
               Navigator.push(context, MaterialPageRoute(builder: (context) => const Inserir())); // Vai para Inserir
             }),
           _buildDrawerItem(
             iconData: Icons.handshake_outlined, // Ícone de aperto de mão
             text: 'Cadastro de Fornecedor',
             showPlusIcon: true,
             onTap: () {
               Navigator.pop(context);
               // TODO: Navegar para tela de Cadastro de Fornecedor (se existir)
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Cadastro Fornecedor (Não implementada)')));
             }),
           _buildDrawerItem(
             iconData: Icons.sync_alt, // Ícone de setas circulares
             text: 'Movimentações', // Item da tela atual
             onTap: () {
               Navigator.pop(context); // Apenas fecha o drawer se já está na tela
             }),
            _buildDrawerItem(
             iconData: Icons.bar_chart_outlined, // Ícone de gráfico de barras
             text: 'Relatórios',
             onTap: () {
                Navigator.pop(context);
                // TODO: Navegar para tela de Relatórios (se existir)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Relatórios (Não implementada)')));
             }),
            _buildDrawerItem(
             iconData: Icons.person_add_alt_1_outlined, // Ícone de pessoa com '+'
             text: 'Cadastro de Usuários',
             showPlusIcon: false,
             onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => InserirFuncionario())); // Vai para InserirFuncionario
             }),
            _buildDrawerItem(
              iconData: Icons.search_outlined, // Ícone de busca
              text: 'Consultar Patrimônio',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar para tela de Consulta (se for diferente de Busca)
                // Assumindo que Busca é a tela de consulta:
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const Busca()));
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Consulta Patrimônio (Não implementada ou é a tela Busca?)')));
              },
            ),
             _buildDrawerItem(
              iconData: Icons.delete_outline,
              text: 'Excluir Patrimônio',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar para tela de Excluir
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Excluir Patrimônio (Não implementada)')));
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const Excluir()));
              },
            ),

           // --- Divisor e Itens Adicionais ---
           const Divider(thickness: 1, height: 1),
           ListTile( // Recarregar dados da tela atual
             leading: const Icon(Icons.refresh, color: Colors.blueGrey),
             title: const Text('Recarregar Movimentações'),
             onTap: () { Navigator.pop(context); _fetchPatrimonios(); },
           ),
           ListTile( // Voltar ao Dashboard
             leading: const Icon(Icons.dashboard_outlined, color: Colors.blueGrey),
             title: const Text('Dashboard'),
             onTap: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuAdm())); },
           ),
           ListTile( // Sair
             leading: const Icon(Icons.exit_to_app, color: Colors.red),
             title: const Text('Sair', style: TextStyle(color: Colors.red)),
             onTap: () {
               Navigator.pop(context);
               Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MyApp()), (Route<dynamic> route) => false);
             },
           ),
        ],
      ),
    );
  }

  // ===========================================================
  //     HELPER _buildDrawerItem COPIADO DE MenuAdm
  // ===========================================================
  Widget _buildDrawerItem({
    required IconData iconData,
    required String text,
    required VoidCallback onTap,
    bool showPlusIcon = false,
  }) {
    final Color iconColor = Colors.grey[700]!;
    Widget leadingIcon = Icon(iconData, color: iconColor, size: 26);

    if (showPlusIcon) {
      leadingIcon = Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(padding: const EdgeInsets.all(4.0), child: Icon(iconData, color: iconColor, size: 28)),
          Positioned(
            bottom: -2, right: -2,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: SizedBox(width: 40, height: 40, child: Center(child: leadingIcon)),
          title: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
          onTap: onTap,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
      ],
    );
  }


  // --- Método build() (Restante do código permanece igual) ---
  @override
  Widget build(BuildContext context) {
     print("Executando build() de MovimentacaopatrimonioState...");

    final Color backgroundColor = Colors.grey[100]!;
    final Color headerColor = Colors.white;
    final Color textColor = Colors.grey[800]!;
    final Color labelColor = Colors.grey[600]!;
    final Color iconColor = Colors.grey[700]!;
    final Color fabColor = Colors.grey[850]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentações', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        centerTitle: true,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      // Chama o Drawer modificado
      drawer: _buildDrawer(context),
      backgroundColor: backgroundColor,
      body: Padding(
         padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
         child: Column(
            children: [
              _buildSearchBar(iconColor, labelColor), // Barra de busca
              const SizedBox(height: 16),
              // Tabela ou indicadores
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(_errorMessage, style: TextStyle(color: Colors.red[700], fontSize: 16), textAlign: TextAlign.center)))
                        : _filteredPatrimonios.isEmpty
                            ? Center(child: Text('Nenhuma movimentação encontrada${_filterController.text.isNotEmpty ? ' para "${_filterController.text}"' : ''}.', style: TextStyle(fontSize: 16, color: labelColor), textAlign: TextAlign.center))
                            : _buildDataTableContainer(headerColor, textColor, labelColor),
              ),
            ],
          ),
        ),
       floatingActionButton: FloatingActionButton( // FAB
         onPressed: () {
            print("FAB pressionado - Abrir tela de nova movimentação");
             Navigator.push(context, MaterialPageRoute(builder: (context) => const InserirMovimentacao()))
             .then((_) => _fetchPatrimonios());
         },
         backgroundColor: fabColor,
         foregroundColor: Colors.white,
         tooltip: 'Nova Movimentação',
         child: const Icon(Icons.add),
       ),
    );
  }


  // --- Helper Widgets (_buildSearchBar, _buildDataTableContainer, _buildDataColumn, _buildDataCell - Mantidos como antes) ---
  Widget _buildSearchBar(Color iconColor, Color hintColor) {
    // ... (código _buildSearchBar idêntico) ...
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2)) ],
      ),
      child: TextField(
        controller: _filterController,
        onChanged: _filterPatrimonios,
        style: TextStyle(color: Colors.grey[800], fontSize: 15),
        decoration: InputDecoration(
          icon: Padding(padding: const EdgeInsets.only(left: 8.0), child: Icon(Icons.tune, color: iconColor, size: 20)),
          hintText: 'Digite o nome ou código do patrimônio',
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: Padding(padding: const EdgeInsets.only(right: 8.0), child: Icon(Icons.search, color: iconColor, size: 22)),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  Widget _buildDataTableContainer(Color headerColor, Color textColor, Color labelColor) {
    // ... (código _buildDataTableContainer idêntico, incluindo ordenação) ...
     List<Map<String, dynamic>> sortedList = List.from(_filteredPatrimonios);
     try {
       sortedList.sort((a, b) {
         final dateA = DateTime.tryParse(a['data']?.toString() ?? '');
         final dateB = DateTime.tryParse(b['data']?.toString() ?? '');
         if (dateA == null && dateB == null) return 0;
         if (dateA == null) return 1; if (dateB == null) return -1;
         return dateB.compareTo(dateA);
       });
     } catch (e) { print("Erro ao ordenar por data: $e. Usando ordem original."); sortedList = _filteredPatrimonios; }

    return Container(
      child: Card(
         margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
         elevation: 1.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
         clipBehavior: Clip.antiAlias,
         child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView( scrollDirection: Axis.vertical,
               child: SingleChildScrollView( scrollDirection: Axis.horizontal,
                  child: DataTable(
                     headingRowHeight: 48.0, dataRowHeight: 48.0, columnSpacing: 16.0,
                     headingRowColor: MaterialStateProperty.all(headerColor),
                     columns: [
                        _buildDataColumn('Código', labelColor), _buildDataColumn('Setor', labelColor),
                        _buildDataColumn('Data', labelColor), _buildDataColumn('Movimentação', labelColor),
                        _buildDataColumn('Usuário', labelColor),
                     ],
                     rows: sortedList.map((patrimonio) => DataRow(
                        cells: [
                           DataCell(_buildDataCell(patrimonio['codigo'], textColor)), DataCell(_buildDataCell(patrimonio['setor'], textColor)),
                           DataCell(_buildDataCell(patrimonio['data'], textColor)), DataCell(_buildDataCell(patrimonio['status'], textColor)),
                           DataCell(_buildDataCell("ADM", textColor)), // Usuário Placeholder
                        ],
                      )).toList(),
                   ),
               ),
            ),
         ),
       ),
    );
  }

  DataColumn _buildDataColumn(String label, Color labelColor) {
    // ... (código _buildDataColumn idêntico) ...
     return DataColumn(label: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: labelColor), textAlign: TextAlign.center));
  }

  Widget _buildDataCell(dynamic value, Color textColor) {
    // ... (código _buildDataCell idêntico) ...
      String displayValue = value?.toString() ?? 'N/D';
     return Container( padding: const EdgeInsets.symmetric(horizontal: 4.0), alignment: Alignment.centerLeft,
        child: Text(displayValue, style: TextStyle(fontSize: 12, color: textColor), overflow: TextOverflow.ellipsis));
  }

} // Fim da classe _MovimentacaopatrimonioState


// --- Tela Placeholder InserirMovimentacao (Mantida como antes) ---
class InserirMovimentacao extends StatelessWidget {
  const InserirMovimentacao({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // ... (código InserirMovimentacao idêntico) ...
     return Scaffold(
      appBar: AppBar(title: const Text('Nova Movimentação'), backgroundColor: Colors.white, foregroundColor: Colors.black87, iconTheme: const IconThemeData(color: Colors.black87)),
      backgroundColor: Colors.grey[100],
      body: const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Formulário para Nova Movimentação\n(Ainda não implementado)', textAlign: TextAlign.center)))
    );
  }
}