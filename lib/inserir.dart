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

  List<Map<String, dynamic>> marcas = [];
  final List<String> modelos = ['Modelo X', 'Modelo Y', 'Modelo Z'];
  final List<String> setores = ['ADM', 'Radio e TV', 'TI', 'Modelagem'];
  final List<String> statusList = ['Usando', 'Emprestado', 'Descartado'];
  List<Map<String, dynamic>> fornecedores = [{'id': 1, 'nome': 'Fornecedor A'}, {'id': 2, 'nome': 'Fornecedor B'}];
  String? _fornecedorSelecionado;

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
    // TODO: Obter nomeUsuario e privilegioUsuario
    // TODO: Carregar fornecedores e outras listas se necessário
  }

   @override
  void dispose() {
    _corController.dispose();
    _codigoController.dispose();
    _dataController.dispose();
    _descricaoController.dispose();
     print("dispose: Controladores de Inserir limpos."); // Log
    super.dispose();
  }

  // --- Funções Lógicas (Mantidas como antes) ---
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
              marcas.clear();
              marcas = List<Map<String, dynamic>>.from(data.map((item) => item is Map ? Map<String, dynamic>.from(item) : {}));
              marcas.removeWhere((item) => item.isEmpty || !item.containsKey('nome'));
               print("Marcas carregadas: ${marcas.length} itens");
            });
          } else { print('Erro no formato dos dados recebidos para marcas.'); }
        } else { print('Erro no backend ao carregar marcas: ${jsonResponse['message']}'); }
      } else { print('Erro na requisição HTTP ao carregar marcas: ${response.statusCode}'); }
    } catch (error, stackTrace) { print('Erro CATCH ao carregar marcas: $error'); print('StackTrace: $stackTrace'); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar marcas: $error'), backgroundColor: Colors.red)); }
  }

  Future<void> _adicionarMarca(String novaMarca) async {
    // ... (código _adicionarMarca idêntico) ...
      const String url = "http://localhost/server/processa_bdCeet.php";
    print("Adicionando marca: $novaMarca");
    try {
      final response = await http.post(Uri.parse(url), body: json.encode({'acao': 'inserirMarca', 'nome': novaMarca}), headers: {'Content-Type': 'application/json; charset=UTF-8'});
      print("Resposta Add Marca (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
         final responseBody = json.decode(response.body);
         if(responseBody['status'] == 'success') {
            print("Marca adicionada com sucesso, recarregando lista...");
            await _carregarMarcas();
            if (marcas.any((m) => m['nome'] == novaMarca)) { setState(() { _marcaSelecionada = novaMarca; }); print("Marca '$novaMarca' selecionada."); }
            else { print("Marca '$novaMarca' adicionada mas não encontrada após recarregar."); }
         } else { print("Erro no backend ao adicionar marca: ${responseBody['message']}"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar marca: ${responseBody['message']}'), backgroundColor: Colors.red)); }
      } else { print("Erro HTTP ao adicionar marca: ${response.statusCode}"); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro de comunicação ao adicionar marca.'), backgroundColor: Colors.red)); }
    } catch (e, stackTrace) { print("Erro CATCH ao adicionar marca: $e"); print("StackTrace Add Marca: $stackTrace"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar marca: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> _enviarDados(BuildContext context) async {
    // ... (código _enviarDados idêntico) ...
     print("Executando _enviarDados (Inserir)...");
    if (!(_formKey.currentState?.validate() ?? false)) { print("Validação do formulário falhou."); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha os campos obrigatórios!'), backgroundColor: Colors.orange)); return; }
     print("Validação OK. Preparando dados...");
     final Map<String, dynamic> body = { 'acao': 'inserir', 'marca_status': _marcaSelecionada, 'modelo': _modeloSelecionado, 'cor': _corController.text, 'codigo': _codigoController.text, 'data': _dataController.text, 'foto': _fotoBase64 ?? '', 'status': _statusSelecionado, 'setor': _setorSelecionado, 'descricao': _descricaoController.text, 'fornecedor': _fornecedorSelecionado ?? '', };
     print("Enviando dados: ${json.encode(body).substring(0, min(json.encode(body).length, 300))}...");
    const String url = "http://localhost/server/processa_bdCeet.php";
    try {
      final response = await http.post(Uri.parse(url), body: json.encode(body), headers: {'Content-Type': 'application/json; charset=UTF-8'}).timeout(const Duration(seconds: 20));
      print("Resposta Envio (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') { print("Inserção bem-sucedida."); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inserção realizada com sucesso!'), backgroundColor: Colors.green));
          setState(() { _marcaSelecionada = null; _modeloSelecionado = null; _setorSelecionado = null; _statusSelecionado = null; _fornecedorSelecionado = null; _selectedCor = null; _corController.clear(); _codigoController.clear(); _dataController.clear(); _descricaoController.clear(); _fotoBase64 = null; _fotoBytes = null; _formKey.currentState?.reset(); print("Campos limpos."); });
        } else { print("Falha ao inserir (backend): ${responseBody['message']}"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao inserir: ${responseBody['message']}'), backgroundColor: Colors.red)); }
      } else { print("Erro HTTP ao enviar: ${response.statusCode}"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no servidor (${response.statusCode}).'), backgroundColor: Colors.red)); }
    } catch (error, stackTrace) { print("Erro CATCH durante envio: $error"); print("StackTrace Envio: $stackTrace"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar dados: $error'), backgroundColor: Colors.red)); }
  }

  Future<void> _escolherFoto() async {
    // ... (código _escolherFoto idêntico) ...
      print("Executando _escolherFoto (Galeria)...");
    try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes(); print("Imagem selecionada: ${pickedFile.path}");
          setState(() { _fotoBytes = bytes; _fotoBase64 = base64Encode(bytes); print("Foto atualizada no estado."); });
        } else { print('Nenhuma imagem selecionada.'); }
    } catch (e, stackTrace) { print("Erro CATCH (escolher foto): $e"); print("StackTrace: $stackTrace"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao acessar galeria: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> _tirarFoto() async {
    // ... (código _tirarFoto idêntico) ...
      print("Executando _tirarFoto (Câmera)...");
     try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
       if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes(); print("Foto tirada: ${pickedFile.path}");
        setState(() { _fotoBytes = bytes; _fotoBase64 = base64Encode(bytes); print("Foto atualizada no estado."); });
      } else { print("Nenhuma foto tirada."); }
     } catch (e, stackTrace) { print("Erro CATCH (tirar foto): $e"); print("StackTrace: $stackTrace"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao usar câmera: $e'), backgroundColor: Colors.red)); }
  }

  void _showImagePickerOptions() {
    // ... (código _showImagePickerOptions idêntico) ...
      print("Executando _showImagePickerOptions...");
    showModalBottomSheet(context: context, backgroundColor: Colors.white, builder: (BuildContext bc) {
        return SafeArea( child: Wrap( children: <Widget>[
              ListTile( leading: Icon(Icons.photo_library_outlined, color: Colors.grey[700]), title: Text('Selecionar da Galeria', style: TextStyle(color: Colors.grey[800])), onTap: () { _escolherFoto(); Navigator.of(context).pop(); },),
              ListTile( leading: Icon(Icons.photo_camera_outlined, color: Colors.grey[700]), title: Text('Tirar Foto', style: TextStyle(color: Colors.grey[800])), onTap: () { _tirarFoto(); Navigator.of(context).pop(); },),
            ],),);},);
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
      // AppBar com Ícone do Drawer automático
      appBar: AppBar(
        title: const Text('Cadastro Patrimonio', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54, // Cor do ícone do Drawer
        centerTitle: true,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87), // Garante a cor do ícone do Drawer
      ),
      // Adiciona o Drawer AQUI
      drawer: _buildDrawer(context),
      // Fundo
      backgroundColor: const Color(0xFFF8F8F8),
      // Corpo
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              // --- Campos do Formulário (Mantidos como antes) ---
              _buildDropdownRowWithAdd(label: 'Marca', labelColor: labelColor, labelFontSize: labelFontSize, value: _marcaSelecionada, items: marcas.map((m) => DropdownMenuItem<String>(value: m['nome']?.toString() ?? '', child: Text(m['nome']?.toString() ?? ''))).toList(), onChanged: (v) => setState(() => _marcaSelecionada = v), onAddTap: () => _mostrarDialogAdicionarMarca(context), inputBorder: inputBorder, focusedInputBorder: focusedInputBorder, validator: (v) => v == null ? 'Selecione' : null),
              const SizedBox(height: 20),
              _buildDropdownRowWithAdd(label: 'Modelo', labelColor: labelColor, labelFontSize: labelFontSize, value: _modeloSelecionado, items: modelos.map((m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => _modeloSelecionado = v), onAddTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Modelo NI'))), inputBorder: inputBorder, focusedInputBorder: focusedInputBorder, validator: (v) => v == null ? 'Selecione' : null),
              const SizedBox(height: 20),
              _buildDropdownSimple(label: 'Setor', labelColor: labelColor, labelFontSize: labelFontSize, value: _setorSelecionado, items: setores.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _setorSelecionado = v), inputBorder: inputBorder, focusedInputBorder: focusedInputBorder, validator: (v) => v == null ? 'Selecione' : null),
              const SizedBox(height: 20),
              _buildDropdownSimple(label: 'Status', labelColor: labelColor, labelFontSize: labelFontSize, value: _statusSelecionado, items: statusList.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _statusSelecionado = v), inputBorder: inputBorder, focusedInputBorder: focusedInputBorder, validator: (v) => v == null ? 'Selecione' : null),
              const SizedBox(height: 20),
               _buildTextField(controller: _corController, label: 'Cor', labelColor: labelColor, labelFontSize: labelFontSize, inputColor: inputColor, inputBorder: inputBorder, focusedInputBorder: focusedInputBorder, validator: (v)=>(v==null||v.isEmpty)?'Informe':null), // Usando _corController
              const SizedBox(height: 20),
              _buildTextField(controller: _codigoController, label: 'Codigo', labelColor: labelColor, labelFontSize: labelFontSize, inputColor: inputColor, keyboardType: TextInputType.text, inputBorder: inputBorder, focusedInputBorder: focusedInputBorder, validator: (v)=>(v==null||v.isEmpty)?'Informe':null),
              const SizedBox(height: 20),
              _buildTextField(controller: _dataController, label: 'Data', labelColor: labelColor, labelFontSize: labelFontSize, inputColor: inputColor, hintText: 'dd / mm / aaaa', keyboardType: TextInputType.datetime, inputBorder: inputBorder, focusedInputBorder: focusedInputBorder, onTap: () => _selecionarData(context), readOnly: true),
              const SizedBox(height: 20),
              _buildTextField(controller: _descricaoController, label: 'Descrição', labelColor: labelColor, labelFontSize: labelFontSize, inputColor: inputColor, keyboardType: TextInputType.multiline, maxLines: 3, inputBorder: inputBorder, focusedInputBorder: focusedInputBorder),
              const SizedBox(height: 20),
               _buildDropdownRowWithAdd(label: 'Fornecedor', labelColor: labelColor, labelFontSize: labelFontSize, value: _fornecedorSelecionado, items: fornecedores.map((f) => DropdownMenuItem<String>(value: f['nome']?.toString() ?? '', child: Text(f['nome']?.toString() ?? ''))).toList(), onChanged: (v) => setState(() => _fornecedorSelecionado = v), onAddTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Fornecedor NI'))), inputBorder: inputBorder, focusedInputBorder: focusedInputBorder),
              const SizedBox(height: 35),

              // --- Seção da Foto (Mantida como antes) ---
              Center( child: Column( children: [
                    ElevatedButton.icon(icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white), label: const Text('Tirar Foto', style: TextStyle(color: Colors.white)), onPressed: _showImagePickerOptions, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[850], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 2,),),
                    const SizedBox(height: 15),
                    Container( height: 160, width: 160, decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[350]!), borderRadius: BorderRadius.circular(8),),
                      child: _fotoBytes != null ? ClipRRect(borderRadius: BorderRadius.circular(7.0), child: Image.memory(_fotoBytes!, fit: BoxFit.cover)) : Center(child: Icon(Icons.image_outlined, size: 70, color: Colors.grey[400])),),
                  ],),),
              const SizedBox(height: 35),

              // --- Botão Salvar (Mantido como antes) ---
              Center( child: ElevatedButton(
                  onPressed: () => _enviarDados(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688), foregroundColor: Colors.white, minimumSize: const Size(200, 48), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5), elevation: 3,),
                  child: const Text('Salvar'),),),
            ],
          ),
        ),
      ),
    );
  }


 // ===========================================================
 //     HELPER WIDGETS PARA LAYOUT (Mantidos como antes)
 // ===========================================================
 // _buildTextField, _buildDropdownSimple, _buildDropdownRowWithAdd
  Widget _buildTextField({ required TextEditingController controller, required String label, required Color labelColor, required double labelFontSize, required Color inputColor, TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? hintText, FormFieldValidator<String>? validator, VoidCallback? onTap, bool readOnly = false, required InputBorder inputBorder, required InputBorder focusedInputBorder, bool obscureText = false, TextCapitalization textCapitalization = TextCapitalization.none, TextInputAction? textInputAction, ValueChanged<String>? onFieldSubmitted}) { return Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Text(label, style: TextStyle(fontSize: labelFontSize, color: labelColor, height: 1.2)), TextFormField( controller: controller, keyboardType: keyboardType, maxLines: maxLines, style: TextStyle(fontSize: 15, color: inputColor), obscureText: obscureText, textCapitalization: textCapitalization, textInputAction: textInputAction, onFieldSubmitted: onFieldSubmitted, decoration: InputDecoration( hintText: hintText, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15), enabledBorder: inputBorder, focusedBorder: focusedInputBorder, errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), focusedErrorBorder: focusedInputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 0.8), isDense: true, contentPadding: const EdgeInsets.only(top: 6.0, bottom: 8.0),), validator: validator, onTap: onTap, readOnly: readOnly,),],); }
  Widget _buildDropdownSimple({ required String label, required Color labelColor, required double labelFontSize, required String? value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged, FormFieldValidator<String>? validator, required InputBorder inputBorder, required InputBorder focusedInputBorder }) { final validValue = items.any((item) => item.value == value) ? value : null; return Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Text(label, style: TextStyle(fontSize: labelFontSize, color: labelColor, height: 1.2)), DropdownButtonFormField<String>( value: validValue, items: items, onChanged: onChanged, style: TextStyle(fontSize: 15, color: Colors.black87), decoration: InputDecoration( enabledBorder: inputBorder, focusedBorder: focusedInputBorder, errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), focusedErrorBorder: focusedInputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 0.8), isDense: true, contentPadding: const EdgeInsets.only(top: 6.0, bottom: 8.0, right: 0),), icon: Padding( padding: const EdgeInsets.only(left: 8.0), child: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),), iconSize: 24, isExpanded: true, validator: validator,),],); }
  Widget _buildDropdownRowWithAdd({ required String label, required Color labelColor, required double labelFontSize, required String? value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged, required VoidCallback onAddTap, FormFieldValidator<String>? validator, required InputBorder inputBorder, required InputBorder focusedInputBorder }) { final validValue = items.any((item) => item.value == value) ? value : null; return Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ Text(label, style: TextStyle(fontSize: labelFontSize, color: labelColor, height: 1.2)), Row( crossAxisAlignment: CrossAxisAlignment.end, children: [ Expanded( child: DropdownButtonFormField<String>( value: validValue, items: items, onChanged: onChanged, style: TextStyle(fontSize: 15, color: Colors.black87), decoration: InputDecoration( enabledBorder: inputBorder, focusedBorder: focusedInputBorder, errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), focusedErrorBorder: focusedInputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 0.8), isDense: true, contentPadding: const EdgeInsets.only(top: 6.0, bottom: 8.0, right: 0),), icon: Padding( padding: const EdgeInsets.only(left: 8.0), child: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),), iconSize: 24, isExpanded: true, validator: validator,),), Padding( padding: const EdgeInsets.only(left: 8.0, bottom: 0), child: IconButton( icon: Icon(Icons.add_circle_outline, color: Colors.grey[700], size: 26), padding: EdgeInsets.zero, constraints: const BoxConstraints(), splashRadius: 20, tooltip: 'Adicionar Novo $label', onPressed: onAddTap,),),],),],); }

} // Fim da classe _InserirState