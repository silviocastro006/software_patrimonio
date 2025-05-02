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
import 'inserir.dart';               // Para Cadastro de Patrimônio
// import 'alterar.dart';            // Não chamado diretamente pelo Drawer padrão
import 'movimentacaoPatrimonio.dart';// Para Movimentações
import 'excluir.dart';               // Para Excluir Patrimônio (se existir tela)
// Importa a si mesmo? Não necessário. A tela já está aqui.

// --- Fim dos Imports ---


// Convertido para StatefulWidget
class InserirFuncionario extends StatefulWidget {
  const InserirFuncionario({Key? key}) : super(key: key);

  @override
  _InserirFuncionarioState createState() => _InserirFuncionarioState();
}

class _InserirFuncionarioState extends State<InserirFuncionario> {
  // --- Controladores e Variáveis de Estado ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  File? _imagemSelecionada;
  Uint8List? _fotoBytes;
  String? _fotoBase64;
  final ImagePicker _picker = ImagePicker();

  // --- Variáveis para o Drawer (copiadas/adaptadas de MenuAdm) ---
  String nomeUsuario = "Usuário"; // TODO: Obter nome real do usuário logado
  String privilegioUsuario = "Admin"; // TODO: Obter privilégio real

  @override
  void initState() {
    super.initState();
     print("initState: Tela InserirFuncionario iniciada.");
     // TODO: Obter nomeUsuario e privilegioUsuario se vierem do login/estado global
  }

  @override
  void dispose() {
    _usuario.dispose();
    _senha.dispose();
    print("dispose: Controladores de InserirFuncionario limpos.");
    super.dispose();
  }


  // --- Lógica de Envio (Mantida como antes) ---
  Future<void> _enviarDados(BuildContext context) async {
    // ... (código _enviarDados idêntico à resposta anterior) ...
     print("Executando _enviarDados (InserirFuncionario)...");
    if (!(_formKey.currentState?.validate() ?? false)) {
       print("Validação do formulário falhou.");
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha os campos obrigatórios!'), backgroundColor: Colors.orange));
      return;
    }
     print("Validação OK. Preparando dados...");
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, String> data = {
      'acao': 'criaUsuario',
      'usuario': _usuario.text.toUpperCase(),
      'senha': _senha.text.toUpperCase(),
      // 'foto_usuario': _fotoBase64 ?? '', // Opcional
    };
     print("Dados a serem enviados: ${json.encode(data)}");
    try {
      final response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json; charset=UTF-8'}, body: json.encode(data)).timeout(const Duration(seconds: 15));
      print("Resposta Criação Usuário (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          print("Usuário inserido com sucesso.");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário inserido com sucesso!'), backgroundColor: Colors.green));
          setState(() { _usuario.clear(); _senha.clear(); _imagemSelecionada = null; _fotoBytes = null; _fotoBase64 = null; _formKey.currentState?.reset(); print("Campos limpos."); });
        } else {
          print("Falha ao inserir (backend): ${responseBody['message']}");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao inserir: ${responseBody['message']}'), backgroundColor: Colors.red));
        }
      } else {
         print("Erro HTTP ao criar usuário: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no servidor (${response.statusCode}).'), backgroundColor: Colors.red));
      }
    } catch (error, stackTrace) {
      print("Erro CATCH ao criar usuário: $error"); print("StackTrace Criação Usuário: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro durante a requisição: $error'), backgroundColor: Colors.red));
    }
  }

  // --- Funções para Imagem (Mantidas como antes) ---
  Future<void> _escolherFoto() async {
    // ... (código _escolherFoto idêntico à resposta anterior) ...
     print("Executando _escolherFoto (Galeria)...");
    try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          print("Imagem selecionada: ${pickedFile.path}");
          setState(() { _imagemSelecionada = File(pickedFile.path); _fotoBytes = bytes; _fotoBase64 = base64Encode(bytes); print("Foto atualizada no estado."); });
        } else { print("Nenhuma imagem selecionada."); }
    } catch (e, stackTrace) { print("Erro CATCH (escolher foto): $e"); print("StackTrace: $stackTrace"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao acessar galeria: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> _tirarFoto() async {
    // ... (código _tirarFoto idêntico à resposta anterior) ...
     print("Executando _tirarFoto (Câmera)...");
     try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
       if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
         print("Foto tirada: ${pickedFile.path}");
        setState(() { _imagemSelecionada = File(pickedFile.path); _fotoBytes = bytes; _fotoBase64 = base64Encode(bytes); print("Foto atualizada no estado."); });
      } else { print("Nenhuma foto tirada."); }
     } catch (e, stackTrace) { print("Erro CATCH (tirar foto): $e"); print("StackTrace: $stackTrace"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao usar câmera: $e'), backgroundColor: Colors.red)); }
  }

  void _showImagePickerOptions() {
    // ... (código _showImagePickerOptions idêntico à resposta anterior) ...
      print("Executando _showImagePickerOptions...");
    showModalBottomSheet(context: context, backgroundColor: Colors.white, builder: (BuildContext bc) {
        return SafeArea( child: Wrap( children: <Widget>[
              ListTile( leading: Icon(Icons.photo_library_outlined, color: Colors.grey[700]), title: Text('Selecionar da Galeria', style: TextStyle(color: Colors.grey[800])), onTap: () { _escolherFoto(); Navigator.of(context).pop(); },),
              ListTile( leading: Icon(Icons.photo_camera_outlined, color: Colors.grey[700]), title: Text('Tirar Foto', style: TextStyle(color: Colors.grey[800])), onTap: () { _tirarFoto(); Navigator.of(context).pop(); },),
            ],),);},);
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
                Text(nomeUsuario, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(privilegioUsuario, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),

          // Itens de Menu (Navegação ajustada para esta tela)
          _buildDrawerItem(
             iconData: Icons.inventory_2_outlined,
             text: 'Cadastro de Patrimônio',
             showPlusIcon: true,
             onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (context) => const Inserir()));
             }),
           _buildDrawerItem(
             iconData: Icons.handshake_outlined,
             text: 'Cadastro de Fornecedor',
             showPlusIcon: true,
             onTap: () {
               Navigator.pop(context);
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tela Relatórios (Não implementada)')));
             }),
            _buildDrawerItem(
             iconData: Icons.person_add_alt_1_outlined,
             text: 'Cadastro de Usuários', // Item da tela atual
             showPlusIcon: false,
             onTap: () {
               Navigator.pop(context); // Apenas fecha o drawer
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
    // ... (código _buildDrawerItem idêntico à resposta anterior) ...
     final Color iconColor = Colors.grey[700]!;
    Widget leadingIcon = Icon(iconData, color: iconColor, size: 26);

    if (showPlusIcon) {
      leadingIcon = Stack( clipBehavior: Clip.none, children: [
          Padding(padding: const EdgeInsets.all(4.0), child: Icon(iconData, color: iconColor, size: 28)),
          Positioned( bottom: -2, right: -2,
            child: Container( padding: const EdgeInsets.all(1), decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
              child: const Icon(Icons.add, color: Colors.white, size: 12),),),],);
    }
    return Column( mainAxisSize: MainAxisSize.min, children: [
        ListTile( leading: SizedBox(width: 40, height: 40, child: Center(child: leadingIcon)),
          title: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
          onTap: onTap, dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),],);
  }


  // --- Método build() com o Novo Layout e Drawer ---
  @override
  Widget build(BuildContext context) {
     print("Executando build() de InserirFuncionarioState...");

    // Estilos reutilizáveis
    final Color labelColor = Colors.grey[600]!;
    final Color inputColor = Colors.black87;
    final Color borderColor = Colors.grey[350]!;
    const double labelFontSize = 12.0;
    final InputBorder inputBorder = UnderlineInputBorder(borderSide: BorderSide(color: borderColor));
    final InputBorder focusedInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!));

    return Scaffold(
       // AppBar
       appBar: AppBar(
         title: const Text('Cadastro Usuário', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
         backgroundColor: Colors.white,
         foregroundColor: Colors.black54,
         centerTitle: true,
         elevation: 1.0,
         iconTheme: const IconThemeData(color: Colors.black87),
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

               // Campo Usuário
               _buildTextField(
                 controller: _usuario,
                 label: 'Usuário',
                 labelColor: labelColor,
                 labelFontSize: labelFontSize,
                 inputColor: inputColor,
                 keyboardType: TextInputType.text,
                 inputBorder: inputBorder,
                 focusedInputBorder: focusedInputBorder,
                 validator: (value) => (value == null || value.isEmpty) ? 'Informe o nome de usuário' : null,
                 textCapitalization: TextCapitalization.characters,
               ),
               const SizedBox(height: 20),

               // Campo Senha
               _buildTextField(
                 controller: _senha,
                 label: 'Senha',
                 labelColor: labelColor,
                 labelFontSize: labelFontSize,
                 inputColor: inputColor,
                 keyboardType: TextInputType.visiblePassword,
                 inputBorder: inputBorder,
                 focusedInputBorder: focusedInputBorder,
                 obscureText: true,
                 validator: (value) => (value == null || value.isEmpty) ? 'Informe a senha' : null,
                 textCapitalization: TextCapitalization.characters,
               ),
               const SizedBox(height: 35),

               // Seção da Foto
               Center( child: Column( children: [
                     ElevatedButton.icon(
                       icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                       label: Text(_fotoBytes != null ? 'Alterar Foto' : 'Adicionar Foto (Opcional)', style: TextStyle(color: Colors.white)),
                       onPressed: _showImagePickerOptions,
                       style: ElevatedButton.styleFrom( backgroundColor: Colors.grey[850], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 2,),),
                     const SizedBox(height: 15),
                     Container( height: 160, width: 160, decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey[350]!), borderRadius: BorderRadius.circular(8),),
                       child: _fotoBytes != null
                           ? ClipRRect(borderRadius: BorderRadius.circular(7.0), child: Image.memory(_fotoBytes!, fit: BoxFit.cover))
                           : Center(child: Icon(Icons.person_outline, size: 70, color: Colors.grey[400])),), // Ícone de pessoa
                   ],),),
               const SizedBox(height: 35),

               // Botão Salvar
               Center( child: ElevatedButton(
                   onPressed: () => _enviarDados(context),
                   style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFF009688), foregroundColor: Colors.white, minimumSize: const Size(200, 48), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5), elevation: 3,),
                   child: const Text('Salvar Usuário'), ),),

             ],
           ),
         ),
       ),
    );
  }

  // --- Helper _buildTextField (Mantido como antes) ---
  Widget _buildTextField({
    required TextEditingController controller, required String label, required Color labelColor, required double labelFontSize, required Color inputColor, TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? hintText, FormFieldValidator<String>? validator, VoidCallback? onTap, bool readOnly = false, bool obscureText = false, TextCapitalization textCapitalization = TextCapitalization.none, required InputBorder inputBorder, required InputBorder focusedInputBorder, TextInputAction? textInputAction, ValueChanged<String>? onFieldSubmitted,}) {
    return Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: TextStyle(fontSize: labelFontSize, color: labelColor, height: 1.2)),
        TextFormField( controller: controller, keyboardType: keyboardType, maxLines: maxLines, style: TextStyle(fontSize: 15, color: inputColor), obscureText: obscureText, textCapitalization: textCapitalization, textInputAction: textInputAction, onFieldSubmitted: onFieldSubmitted, decoration: InputDecoration( hintText: hintText, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15), enabledBorder: inputBorder, focusedBorder: focusedInputBorder, errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), focusedErrorBorder: focusedInputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)), errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 0.8), isDense: true, contentPadding: const EdgeInsets.only(top: 6.0, bottom: 8.0),), validator: validator, onTap: onTap, readOnly: readOnly,),],); }

} // Fim da classe _InserirFuncionarioState