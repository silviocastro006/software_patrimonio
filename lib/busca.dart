import 'dart:convert'; // Para json.decode
import 'dart:math';   // Para min() nos logs
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Para requisições HTTP

// --- Imports das Telas (GARANTA QUE ESTÃO CORRETOS E COMPLETOS) ---
import 'main.dart';                  // Para Sair e ir pro Login
import 'menuAdm.dart';               // Para Voltar ao Dashboard
// Import da própria tela não é necessário: import 'busca.dart';
import 'inserir.dart';               // Para Cadastro de Patrimônio
import 'alterar.dart';               // Usado na função _goToAlterarPage
import 'movimentacaoPatrimonio.dart';// Para Movimentações
import 'inserirFuncionario.dart';    // Para Cadastro de Usuários
import 'excluir.dart';               // Para Excluir Patrimônio (se existir tela)
// --- Fim dos Imports ---


// Definição do StatefulWidget
class Busca extends StatefulWidget {
  const Busca({Key? key}) : super(key: key);

  @override
  _BuscaState createState() => _BuscaState();
}

// Classe State
class _BuscaState extends State<Busca> {
  // --- Controladores e Variáveis de Estado ---
  final TextEditingController _filterController = TextEditingController();
  List<Map<String, dynamic>> _patrimonios = [];
  List<Map<String, dynamic>> _filteredPatrimonios = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // --- Variáveis para o Drawer ---
  String nomeUsuario = "Usuário"; // TODO: Obter nome real
  String privilegioUsuario = "Admin"; // TODO: Obter privilégio real

  // --- initState e dispose ---
  @override
  void initState() {
    super.initState();
    print("initState: Carregando patrimônios (Busca)...");
    _fetchPatrimonios();
    // TODO: Obter nomeUsuario e privilegioUsuario
  }

  @override
  void dispose() {
    _filterController.dispose();
    print("dispose: Filtro controller limpo (Busca).");
    super.dispose();
  }


  // --- Funções Lógicas (fetch, filter, goToAlterar - Mantidas como antes) ---
  Future<void> _fetchPatrimonios() async {
    // ... (código _fetchPatrimonios idêntico à resposta anterior) ...
     setState(() { _isLoading = true; _errorMessage = ''; }); print("Executando _fetchPatrimonios (Busca)..."); const String url = "http://localhost/server/processa_bdCeet.php"; final Map<String, String> data = {'acao': 'listar'}; try { final response = await http.post( Uri.parse(url), headers: {'Content-Type': 'application/json; charset=UTF-8'}, body: json.encode(data), ).timeout(const Duration(seconds: 20)); print("Resposta Listar (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 300))}..."); if (response.statusCode == 200) { final responseBody = json.decode(response.body); if (responseBody['status'] == 'success' && responseBody['produtos'] != null && responseBody['produtos'] is List) { print("Patrimônios recebidos com sucesso."); setState(() { _patrimonios = List<Map<String, dynamic>>.from(responseBody['produtos']) .where((p) => p is Map && p['status'] != 'descartado') .map((p) => Map<String, dynamic>.from(p)) .toList(); _filteredPatrimonios = List.from(_patrimonios); _isLoading = false; print("Patrimônios atualizados no estado: ${_patrimonios.length} itens"); }); } else { print("Erro backend (listar): ${responseBody['message'] ?? 'Formato inválido.'}"); setState(() { _errorMessage = 'Erro ao buscar: ${responseBody['message'] ?? 'Formato inválido.'}'; _isLoading = false; }); } } else { print("Erro HTTP (listar): ${response.statusCode}"); setState(() { _errorMessage = 'Erro de comunicação (${response.statusCode}).'; _isLoading = false; }); } } catch (error, stackTrace) { print("Erro CATCH (listar): $error"); print("StackTrace Listar: $stackTrace"); setState(() { _errorMessage = 'Erro durante a requisição: $error'; _isLoading = false; }); }
  }

  void _filterPatrimonios(String query) {
    // ... (código _filterPatrimonios idêntico à resposta anterior) ...
     print("Filtrando com query: '$query'"); setState(() { if (query.isEmpty) { _filteredPatrimonios = List.from(_patrimonios); print("Filtro vazio, mostrando todos: ${_filteredPatrimonios.length} itens"); } else { _filteredPatrimonios = _patrimonios.where((patrimonio) { final marcaLower = patrimonio['marca']?.toString().toLowerCase() ?? ''; final modeloLower = patrimonio['modelo']?.toString().toLowerCase() ?? ''; final codigoLower = patrimonio['codigo']?.toString().toLowerCase() ?? ''; final queryLower = query.toLowerCase(); bool matchesQuery = marcaLower.contains(queryLower) || modeloLower.contains(queryLower) || codigoLower.contains(queryLower); bool isNotDescartado = patrimonio['status'] != 'descartado'; return matchesQuery && isNotDescartado; }).toList(); print("Filtro aplicado, encontrados: ${_filteredPatrimonios.length} itens"); } });
  }

  void _goToAlterarPage(Map<String, dynamic> patrimonio) {
    // ... (código _goToAlterarPage idêntico à resposta anterior) ...
     print("Navegando para Alterar com dados: $patrimonio"); if (patrimonio['id'] == null) { print("Erro: ID do patrimônio está nulo."); ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text('Não é possível editar: ID do patrimônio não encontrado.'), backgroundColor: Colors.red, ), ); return; } Navigator.push( context, MaterialPageRoute( builder: (context) => Alterar( patrimonio: patrimonio, ), ), ).then((result) { if (result == true) { print("Retornou da tela Alterar com sucesso, recarregando lista..."); _fetchPatrimonios(); } else { print("Retornou da tela Alterar sem indicação de alteração."); } });
  }

  // ===========================================================
  //     FUNÇÃO _buildDrawer COPIADA/ADAPTADA DE Telas Anteriores
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
                Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.0)), child: const Icon(Icons.person_outline, color: Colors.white, size: 60)),
                const SizedBox(height: 15),
                Text(nomeUsuario, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(privilegioUsuario, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),

          // Itens de Menu (Navegação ajustada para esta tela)
          _buildDrawerItem(iconData: Icons.inventory_2_outlined, text: 'Cadastro de Patrimônio', showPlusIcon: true, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const Inserir())); }),
          _buildDrawerItem(iconData: Icons.handshake_outlined, text: 'Cadastro de Fornecedor', showPlusIcon: true, onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Cadastro Fornecedor (NI)'))); }),
          _buildDrawerItem(iconData: Icons.sync_alt, text: 'Movimentações', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const Movimentacaopatrimonio())); }),
          _buildDrawerItem(iconData: Icons.bar_chart_outlined, text: 'Relatórios', onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Relatórios (NI)'))); }),
          _buildDrawerItem(iconData: Icons.person_add_alt_1_outlined, text: 'Cadastro de Usuários', showPlusIcon: false, onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const InserirFuncionario())); }),
          _buildDrawerItem(
              iconData: Icons.search_outlined,
              text: 'Consultar Patrimônio', // Item da tela atual
              onTap: () {
                Navigator.pop(context); // Apenas fecha o drawer
              },
            ),
             _buildDrawerItem(
              iconData: Icons.delete_outline,
              text: 'Excluir Patrimônio',
              onTap: () {
                Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Excluir Patrimônio (NI)')));
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const Excluir()));
              },
            ),

           // --- Divisor e Itens Adicionais ---
           const Divider(thickness: 1, height: 1),
            ListTile( // Recarregar dados da tela atual
             leading: const Icon(Icons.refresh, color: Colors.blueGrey),
             title: const Text('Recarregar Lista'),
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
  //     HELPER _buildDrawerItem COPIADO DE Telas Anteriores
  // ===========================================================
  Widget _buildDrawerItem({ required IconData iconData, required String text, required VoidCallback onTap, bool showPlusIcon = false }) {
    // ... (código _buildDrawerItem idêntico) ...
     final Color iconColor = Colors.grey[700]!; Widget leadingIcon = Icon(iconData, color: iconColor, size: 26); if (showPlusIcon) { leadingIcon = Stack( clipBehavior: Clip.none, children: [ Padding(padding: const EdgeInsets.all(4.0), child: Icon(iconData, color: iconColor, size: 28)), Positioned( bottom: -2, right: -2, child: Container( padding: const EdgeInsets.all(1), decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)), child: const Icon(Icons.add, color: Colors.white, size: 12),),),],); } return Column( mainAxisSize: MainAxisSize.min, children: [ ListTile( leading: SizedBox(width: 40, height: 40, child: Center(child: leadingIcon)), title: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])), onTap: onTap, dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),), const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),],);
  }


  // --- Método build() com Novo Layout e Drawer ---
  @override
  Widget build(BuildContext context) {
     print("Executando build() de BuscaState...");

     // Estilos
    final Color backgroundColor = Colors.grey[100]!;
    final Color cardColor = Colors.white;
    final Color textColor = Colors.grey[800]!;
    final Color labelColor = Colors.grey[600]!;
    final Color iconColor = Colors.grey[700]!;

    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text('Consulta Patrimônio', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        centerTitle: true,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      // Adiciona o Drawer AQUI
      drawer: _buildDrawer(context),
      // Fundo
      backgroundColor: backgroundColor,
      // Corpo
      body: Padding(
         padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
         child: Column(
            children: [
              // Barra de Busca
              _buildSearchBar(iconColor, labelColor),
              const SizedBox(height: 16),

              // Lista ou Indicadores
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(_errorMessage, style: TextStyle(color: Colors.red[700], fontSize: 16), textAlign: TextAlign.center)))
                        : _filteredPatrimonios.isEmpty
                            ? Center(child: Text('Nenhum patrimônio encontrado${_filterController.text.isNotEmpty ? ' para "${_filterController.text}"' : ''}.', style: TextStyle(fontSize: 16, color: labelColor), textAlign: TextAlign.center))
                            : Scrollbar( thumbVisibility: true, child: ListView.builder(
                                  itemCount: _filteredPatrimonios.length,
                                  itemBuilder: (context, index) {
                                    final patrimonio = _filteredPatrimonios[index];
                                    return _buildPatrimonioCard(patrimonio, cardColor, textColor, labelColor, iconColor);
                                  },),),
              ),
            ],
          ),
        ),
    );
  }


  // --- Helper Widgets (_buildSearchBar, _buildPatrimonioCard, _buildDetailRow - Mantidos como antes) ---
  Widget _buildSearchBar(Color iconColor, Color hintColor) {
    // ... (código _buildSearchBar idêntico) ...
     return Container( padding: const EdgeInsets.symmetric(horizontal: 8.0), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(30.0), boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2)), ], ), child: TextField( controller: _filterController, onChanged: _filterPatrimonios, style: TextStyle(color: Colors.grey[800], fontSize: 15), decoration: InputDecoration( icon: Padding(padding: const EdgeInsets.only(left: 8.0), child: Icon(Icons.tune, color: iconColor, size: 20)), hintText: 'Digite o nome ou código do patrimônio', hintStyle: TextStyle(color: hintColor, fontSize: 14), border: InputBorder.none, suffixIcon: Padding(padding: const EdgeInsets.only(right: 8.0), child: Icon(Icons.search, color: iconColor, size: 22)), contentPadding: const EdgeInsets.symmetric(vertical: 14.0), ), ), );
  }

 Widget _buildPatrimonioCard(Map<String, dynamic> patrimonio, Color cardColor, Color textColor, Color labelColor, Color iconColor) {
    // ... (código _buildPatrimonioCard idêntico) ...
     final String codigo = patrimonio['codigo']?.toString() ?? 'N/D'; final String marca = patrimonio['marca']?.toString() ?? 'N/D'; final String modelo = patrimonio['modelo']?.toString() ?? 'N/D'; final String cor = patrimonio['cor']?.toString() ?? 'N/D'; final String status = patrimonio['status']?.toString() ?? 'N/D'; final String? imageUrl = patrimonio['imagem'] != null ? 'http://localhost/server/' + patrimonio['imagem'] : null; return Card( color: cardColor, elevation: 1.5, margin: const EdgeInsets.only(bottom: 12.0, left: 4.0, right: 4.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), child: Padding( padding: const EdgeInsets.all(12.0), child: Row( children: [ Expanded( flex: 3, child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ _buildDetailRow('Codigo:', codigo, labelColor, textColor), const SizedBox(height: 4), _buildDetailRow('Marca:', marca, labelColor, textColor), const SizedBox(height: 4), _buildDetailRow('Modelo:', modelo, labelColor, textColor), const SizedBox(height: 4), _buildDetailRow('Cor:', cor, labelColor, textColor), const SizedBox(height: 4), _buildDetailRow('Status:', status, labelColor, textColor), ], ), ), const SizedBox(width: 12), Expanded( flex: 2, child: Container( height: 80, decoration: BoxDecoration( color: Colors.grey[200], borderRadius: BorderRadius.circular(8.0), ), child: ClipRRect( borderRadius: BorderRadius.circular(8.0), child: imageUrl != null && imageUrl.isNotEmpty ? Image.network( imageUrl, fit: BoxFit.cover, loadingBuilder: (context, child, loadingProgress) { if (loadingProgress == null) return child; return Center( child: CircularProgressIndicator( strokeWidth: 2.0, value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null, ), ); }, errorBuilder: (context, error, stackTrace) { print("Erro ao carregar imagem '$imageUrl': $error"); return Icon(Icons.broken_image_outlined, color: iconColor, size: 40); }, ) : Icon(Icons.image_outlined, color: iconColor, size: 40), ), ), ), const SizedBox(width: 8), IconButton( icon: Icon(Icons.sync, color: iconColor), tooltip: 'Ver Detalhes / Editar', splashRadius: 20, onPressed: () => _goToAlterarPage(patrimonio), ), ], ), ), );
 }

 Widget _buildDetailRow(String label, String value, Color labelColor, Color valueColor) {
    // ... (código _buildDetailRow idêntico) ...
    return RichText( maxLines: 1, overflow: TextOverflow.ellipsis, text: TextSpan( style: TextStyle(fontSize: 12, color: labelColor), children: <TextSpan>[ TextSpan(text: label + ' '), TextSpan( text: value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w500), ), ], ), );
 }

} // Fim da classe _BuscaState
