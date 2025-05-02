import 'dart:convert';        // Para jsonEncode/Decode e base64Encode
import 'dart:typed_data';    // Para Uint8List (bytes da imagem)
import 'dart:io';            // Para File (imagem selecionada)
import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:http/http.dart' as http; // Requisições HTTP
import 'package:image_picker/image_picker.dart'; // Selecionar/tirar fotos
import 'dart:math'; // Para min() usado nos logs

// --- Imports das Telas (GARANTA QUE ESTÃO CORRETOS E COMPLETOS) ---
import 'main.dart';                  // Para Sair e ir pro Login
import 'menuAdm.dart';               // Para Voltar ao Dashboard
import 'busca.dart';                 // Para Consultar Patrimônio
// A importação de 'inserir.dart' abaixo não é necessária pois estamos nele
// import 'inserir.dart';
// import 'alterar.dart';            // Não chamado diretamente pelo Drawer padrão
import 'movimentacaoPatrimonio.dart';// Para Movimentações
import 'inserirFuncionario.dart';    // Para Cadastro de Usuários
import 'excluir.dart';               // Para Excluir Patrimônio (se existir tela)
// --- Fim dos Imports ---


// Definição do StatefulWidget
class Inserir extends StatefulWidget {
  const Inserir({Key? key}) : super(key: key);

  @override
  _InserirState createState() => _InserirState();
}

// Classe State
class _InserirState extends State<Inserir> {
  // --- Controladores e Variáveis de Estado ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String? _fotoBase64;
  Uint8List? _fotoBytes;

  List<Map<String, dynamic>> marcas = [];
  List<Map<String, dynamic>> modelos = []; // Lista para os modelos do banco
  final List<String> setores = ['ADM', 'Radio e TV', 'TI', 'Modelagem'];
  final List<String> statusList = [
    'Alogado',
    'Realogado (Emprestado)',
    'Descartado'
  ];

  String? _marcaSelecionada;
  String? _modeloSelecionado;
  String? _setorSelecionado;
  String? _statusSelecionado;
  // Adicionando Cor como dropdown opcional - MANTIDO DA VERSÃO ANTERIOR
  String? _selectedCor;
  final List<String> _coresExemplo = ['Preto', 'Branco', 'Cinza', 'Azul']; // Lista exemplo para Cor dropdown
  List<String> _cores = []; // Lista dinâmica para Cor dropdown

  Uint8List? _fotoBytes;
  final ImagePicker _picker = ImagePicker();

   // --- Variáveis para o Drawer (copiadas/adaptadas de MenuAdm) ---
  String nomeUsuario = "Usuário"; // TODO: Obter nome real do usuário logado
  String privilegioUsuario = "Admin"; // TODO: Obter privilégio real


  @override
  void initState() {
    super.initState();
    print("initState: Tela Inserir iniciada."); // Log
    _cores = List.from(_coresExemplo); // Inicializa lista de cores
    _carregarMarcas();
    _carregarModelos(); // Carrega os modelos do banco
  }

  Future<void> _carregarMarcas() async {
    // ... (código _carregarMarcas idêntico) ...
     print("Carregando marcas...");
    const String url = 'http://localhost/server/processa_bdCeet.php';
    try {
      final response = await http.post(Uri.parse(url), body: jsonEncode({'acao': 'carregarMarca', 'marca_status': 'ativo'}), headers: {'Content-Type': 'application/json; charset=UTF-8'}).timeout(const Duration(seconds: 15));
      print("Resposta Marcas (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 200))}...");
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          final data = jsonResponse['data'];
          if (data is List) {
            setState(() {
              marcas = List<Map<String, dynamic>>.from(data);
            });
          }
        } else {
          print(
              'Erro no backend ao carregar marcas: ${jsonResponse['message']}');
        }
      } else {
        print('Erro na requisição ao carregar marcas: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao carregar marcas: $error');
    }
  }

  Future<void> _carregarModelos() async {
    const String url = 'http://localhost/server/processa_bdCeet.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'acao': 'listarModelos', // Adicione essa ação no backend
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('_carregarModelos: response.statusCode = ${response.statusCode}');
      print('_carregarModelos: response.body = ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('_carregarModelos: jsonResponse = $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          // Ajuste aqui para acessar a lista de modelos corretamente
          final data = jsonResponse['data']['data'];

          if (data is List) {
            setState(() {
              modelos = List<Map<String, dynamic>>.from(data);
            });
            print('_carregarModelos: modelos = $modelos');
          }
        } else {
          print(
              'Erro no backend ao carregar modelos: ${jsonResponse['message']}');
        }
      } else {
        print('Erro na requisição ao carregar modelos: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao carregar modelos: $error');
    }
  }

  Future<void> _carregarDadosModelo(String modeloSelecionado) async {
    const String url = 'http://localhost/server/processa_bdCeet.php';

    print('_carregarDadosModelo: Modelo Selecionado = $modeloSelecionado');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'acao': 'buscarModelos', // Adicione essa ação no backend
          'modelo': modeloSelecionado,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          '_carregarDadosModelo: response.statusCode = ${response.statusCode}');
      print('_carregarDadosModelo: response.body = ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('_carregarDadosModelo: jsonResponse = $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          // Acesse os dados corretamente
          final data = jsonResponse['data']['data'];

          _corController.text = data['cor'] ?? '';
          _descricaoController.text = data['descricao'] ?? '';

          // Decodifique a imagem Base64
          if (data['imagemModelo'] != null) {
            _fotoBase64 = data['imagemModelo'];
            _fotoBytes = base64Decode(data['imagemModelo']);
          } else {
            _fotoBase64 = null;
            _fotoBytes = null;
          }
          setState(() {});
        } else {
          print('Erro ao buscar dados do modelo: ${jsonResponse['message']}');
        }
      } else {
        print(
            'Erro na requisição ao buscar dados do modelo: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao buscar dados do modelo: $error');
    }
  }

  Future<void> _carregarModelos() async {
    const String url = 'http://localhost/server/processa_bdCeet.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'acao': 'listarModelos', // Adicione essa ação no backend
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('_carregarModelos: response.statusCode = ${response.statusCode}');
      print('_carregarModelos: response.body = ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('_carregarModelos: jsonResponse = $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          // Ajuste aqui para acessar a lista de modelos corretamente
          final data = jsonResponse['data']['data'];

          if (data is List) {
            setState(() {
              modelos = List<Map<String, dynamic>>.from(data);
            });
            print('_carregarModelos: modelos = $modelos');
          }
        } else {
          print(
              'Erro no backend ao carregar modelos: ${jsonResponse['message']}');
        }
      } else {
        print('Erro na requisição ao carregar modelos: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao carregar modelos: $error');
    }
  }

  Future<void> _carregarDadosModelo(String modeloSelecionado) async {
    const String url = 'http://localhost/server/processa_bdCeet.php';

    print('_carregarDadosModelo: Modelo Selecionado = $modeloSelecionado');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'acao': 'buscarModelos', // Adicione essa ação no backend
          'modelo': modeloSelecionado,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print(
          '_carregarDadosModelo: response.statusCode = ${response.statusCode}');
      print('_carregarDadosModelo: response.body = ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print('_carregarDadosModelo: jsonResponse = $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          // Acesse os dados corretamente
          final data = jsonResponse['data']['data'];

          _corController.text = data['cor'] ?? '';
          _descricaoController.text = data['descricao'] ?? '';

          // Decodifique a imagem Base64
          if (data['imagemModelo'] != null) {
            _fotoBase64 = data['imagemModelo'];
            _fotoBytes = base64Decode(data['imagemModelo']);
          } else {
            _fotoBase64 = null;
            _fotoBytes = null;
          }
          setState(() {});
        } else {
          print('Erro ao buscar dados do modelo: ${jsonResponse['message']}');
        }
      } else {
        print(
            'Erro na requisição ao buscar dados do modelo: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao buscar dados do modelo: $error');
    }
  }

  Future<void> _adicionarMarca(String novaMarca) async {
    // ... (código _adicionarMarca idêntico) ...
      const String url = "http://localhost/server/processa_bdCeet.php";
    print("Adicionando marca: $novaMarca");
    try {
      final response = await http.post(Uri.parse(url), body: json.encode({'acao': 'inserirMarca', 'nome': novaMarca}), headers: {'Content-Type': 'application/json; charset=UTF-8'});
      print("Resposta Add Marca (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
        _carregarMarcas();
      } else {
        print("Erro ao adicionar marca: ${response.body}");
      }
    } catch (e) {
      print("Erro na requisição ao adicionar marca: $e");
    }
  }

  Future<void> _enviarDados(BuildContext context) async {
    // ... (código _enviarDados idêntico) ...
     print("Executando _enviarDados (Inserir)...");
    if (!(_formKey.currentState?.validate() ?? false)) { print("Validação do formulário falhou."); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha os campos obrigatórios!'), backgroundColor: Colors.orange)); return; }
     print("Validação OK. Preparando dados...");
     final Map<String, dynamic> body = { 'acao': 'inserir', 'marca_status': _marcaSelecionada, 'modelo': _modeloSelecionado, 'cor': _corController.text, 'codigo': _codigoController.text, 'data': _dataController.text, 'foto': _fotoBase64 ?? '', 'status': _statusSelecionado, 'setor': _setorSelecionado, 'descricao': _descricaoController.text, 'fornecedor': _fornecedorSelecionado ?? '', };
     print("Enviando dados: ${json.encode(body).substring(0, min(json.encode(body).length, 300))}...");
    const String url = "http://localhost/server/processa_bdCeet.php";

    if (_marcaSelecionada == null ||
        _modeloSelecionado == null ||
        _setorSelecionado == null ||
        _statusSelecionado == null ||
        _corController.text.isEmpty ||
        _codigoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> body = {
      'acao': 'inserir',
      'marca_status': _marcaSelecionada,
      'modelo': _modeloSelecionado,
      'cor': _corController.text,
      'codigo': _codigoController.text,
      'data': _dataController.text,
      'foto': _fotoBase64 ?? '',
      'status': _statusSelecionado,
      'setor': _setorSelecionado,
      'descricao': _descricaoController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inserção realizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _marcaSelecionada = null;
            _modeloSelecionado = null;
            _corController.clear();
            _codigoController.clear();
            _dataController.clear();
            _fotoBase64 = null;
            _statusSelecionado = null;
            _setorSelecionado = null;
            _descricaoController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha ao inserir: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao se conectar com o servidor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar dados.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _fotoBase64 = base64Encode(bytes);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma imagem foi selecionada!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    // ... (código _selecionarData idêntico) ...
      print("Executando _selecionarData (Inserir)...");
     FocusScope.of(context).requestFocus(FocusNode());
    final DateTime? pickedDate = await showDatePicker( context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101), locale: const Locale('pt', 'BR'),
       builder: (context, child) { return Theme( data: Theme.of(context).copyWith( colorScheme: const ColorScheme.light( primary: Color(0xFF009688), onPrimary: Colors.white, onSurface: Colors.black87,), textButtonTheme: TextButtonThemeData( style: TextButton.styleFrom(foregroundColor: const Color(0xFF009688)),), dialogTheme: const DialogTheme( shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))))), child: child!,);},);
    if (pickedDate != null) { String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}"; print("Data selecionada (Inserir): $formattedDate"); setState(() { _dataController.text = formattedDate; }); }
    else { print("Seleção de data cancelada (Inserir)."); }
  }

  void _mostrarDialogAdicionarMarca(BuildContext context) {
    // ... (código _mostrarDialogAdicionarMarca idêntico) ...
     print("Executando _mostrarDialogAdicionarMarca (Inserir)...");
    final TextEditingController novaMarcaController = TextEditingController();
    showDialog( context: context, builder: (BuildContext context) { return AlertDialog( title: const Text('Adicionar Nova Marca'), content: TextField(controller: novaMarcaController, decoration: const InputDecoration(labelText: 'Nome da Marca'), autofocus: true), actions: [ TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')), ElevatedButton( onPressed: () { final novaMarca = novaMarcaController.text.trim(); if (novaMarca.isNotEmpty) { _adicionarMarca(novaMarca); } Navigator.of(context).pop(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688)), child: const Text('Adicionar'),),], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),);},);
  }

  // ===========================================================
  //     FUNÇÃO _buildDrawer COPIADA/ADAPTADA DE MenuAdm/Movimentacoes
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

          // Itens de Menu (Navegação ajustada para esta tela)
          _buildDrawerItem(
             iconData: Icons.inventory_2_outlined,
             text: 'Cadastro de Patrimônio', // Item da tela atual
             showPlusIcon: true,
             onTap: () {
               Navigator.pop(context); // Apenas fecha o drawer
             }),
           _buildDrawerItem(
             iconData: Icons.handshake_outlined,
             text: 'Cadastro de Fornecedor',
             showPlusIcon: true,
             onTap: () {
               Navigator.pop(context);
               // TODO: Navegar para tela de Cadastro de Fornecedor (se existir)
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Cadastro Fornecedor (Não implementada)')));
             }),
           _buildDrawerItem(
             iconData: Icons.sync_alt,
             text: 'Movimentações',
             onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => const Movimentacaopatrimonio()));
             }),
            _buildDrawerItem(
             iconData: Icons.bar_chart_outlined,
             text: 'Relatórios',
             onTap: () {
                Navigator.pop(context);
                // TODO: Navegar para tela de Relatórios (se existir)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Relatórios (Não implementada)')));
             }),
            _buildDrawerItem(
             iconData: Icons.person_add_alt_1_outlined,
             text: 'Cadastro de Usuários',
             showPlusIcon: false,
             onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => const InserirFuncionario()));
             }),
            _buildDrawerItem(
              iconData: Icons.search_outlined,
              text: 'Consultar Patrimônio',
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const Busca()));
              },
            ),
             _buildDrawerItem(
              iconData: Icons.delete_outline,
              text: 'Excluir Patrimônio',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar para tela de Excluir (se existir)
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Excluir Patrimônio (Não implementada)')));
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const Excluir()));
              },
            ),

           // --- Divisor e Itens Adicionais ---
           const Divider(thickness: 1, height: 1),
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
  //     HELPER _buildDrawerItem COPIADO DE MenuAdm/Movimentacoes
  // ===========================================================
  Widget _buildDrawerItem({
    required IconData iconData,
    required String text,
    required VoidCallback onTap,
    bool showPlusIcon = false,
  }) {
    // ... (código _buildDrawerItem idêntico) ...
      final Color iconColor = Colors.grey[700]!; Widget leadingIcon = Icon(iconData, color: iconColor, size: 26);
    if (showPlusIcon) { leadingIcon = Stack( clipBehavior: Clip.none, children: [ Padding(padding: const EdgeInsets.all(4.0), child: Icon(iconData, color: iconColor, size: 28)), Positioned( bottom: -2, right: -2, child: Container( padding: const EdgeInsets.all(1), decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)), child: const Icon(Icons.add, color: Colors.white, size: 12),),),],); }
    return Column( mainAxisSize: MainAxisSize.min, children: [ ListTile( leading: SizedBox(width: 40, height: 40, child: Center(child: leadingIcon)), title: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])), onTap: onTap, dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),), const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),],);
  }


  // --- Método build() com Novo Layout e Drawer ---
  @override
  Widget build(BuildContext context) {
    print("Executando build() de InserirState...");

    // Estilos
    final Color labelColor = Colors.grey[600]!;
    final Color inputColor = Colors.black87;
    final Color borderColor = Colors.grey[350]!;
    const double labelFontSize = 12.0;
    final InputBorder inputBorder = UnderlineInputBorder(borderSide: BorderSide(color: borderColor));
    final InputBorder focusedInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Patrimônio'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3), // Azul claro
              Color(0xFF0D47A1), // Azul mais escuro
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildDropdownComAdicao(
                'Marca',
                _marcaSelecionada,
                marcas,
                (newValue) => setState(() {
                  _marcaSelecionada = newValue;
                }),
                () => _mostrarDialogAdicionarMarca(context),
              ),
              const SizedBox(height: 20),
              _buildDropdownModelos(
                'Modelo',
                _modeloSelecionado,
                modelos,
                (newValue) {
                  setState(() {
                    _modeloSelecionado = newValue;
                  });
                  _carregarDadosModelo(newValue);
                },
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                'Setor',
                _setorSelecionado,
                setores,
                (newValue) => setState(() {
                  _setorSelecionado = newValue;
                }),
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                'Status',
                _statusSelecionado,
                statusList,
                (newValue) => setState(() {
                  _statusSelecionado = newValue;
                }),
              ),
              const SizedBox(height: 20),
              _buildTextField(_corController, 'Cor'),
              const SizedBox(height: 20),
              _buildTextField(_codigoController, 'Código'),
              const SizedBox(height: 20),
              _buildDateField(context),
              const SizedBox(height: 20),
              _buildTextField(_descricaoController, 'Descrição'),
              const SizedBox(height: 20),
              _buildFotoPicker(),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => _enviarDados(context),
                    child: const Text('Adicionar Patrimônio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Verde
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownComAdicao(
    String label,
    String? selectedValue,
    List<Map<String, dynamic>> items,
    Function onChanged,
    VoidCallback onAdd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                onChanged: (newValue) => onChanged(newValue),
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                items: items.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> value) {
                  return DropdownMenuItem<String>(
                    value: value['nome'],
                    child: Text(value['nome']),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: onAdd,
            ),
          ],
        ),
      ],
    );
  }

  // Novo Dropdown para Modelos do Banco
  Widget _buildDropdownModelos(
    String label,
    String? selectedValue,
    List<Map<String, dynamic>> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          items:
              items.map<DropdownMenuItem<String>>((Map<String, dynamic> value) {
            return DropdownMenuItem<String>(
              value: value['modelo'],
              child: Text(value['modelo']),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          onChanged: (newValue) => onChanged(newValue),
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextField(
      controller: _dataController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Data',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      onTap: () => _selecionarData(context),
    );
  }

  Widget _buildFotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Center(
          child: _fotoBytes != null
              ? Column(
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _fotoBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _escolherFoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Alterar Foto'),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: _escolherFoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Adicionar Foto'),
                ),
        ),
      ],
    );
  }
}
