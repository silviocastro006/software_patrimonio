import 'dart:convert';        // Para jsonEncode/Decode
import 'dart:typed_data';    // Para Uint8List (bytes da imagem)
import 'dart:io';            // Para File (imagem selecionada)
import 'package:flutter/material.dart'; // Widgets Flutter
import 'package:http/http.dart' as http; // Requisições HTTP
import 'package:image_picker/image_picker.dart'; // Selecionar/tirar fotos
import 'dart:math'; // Para min() usado nos logs

// Definição do StatefulWidget (como no seu código original)
class Alterar extends StatefulWidget {
  final Map<String, dynamic> patrimonio; // Patrimônio recebido para alteração

  const Alterar({super.key, required this.patrimonio});

  @override
  // ignore: library_private_types_in_public_api
  _AlterarState createState() => _AlterarState();
}

// Classe State onde toda a lógica e UI são construídas
class _AlterarState extends State<Alterar> {
  // --- Controladores e Variáveis de Estado (Adaptados da sua lógica original) ---
  final _formKey = GlobalKey<FormState>(); // Chave para validação do formulário
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  late String _id; // ID do patrimônio sendo alterado

  // Variáveis para imagem (nova ou existente)
  File? _imagemSelecionadaNova; // Guarda um NOVO arquivo selecionado
  Uint8List? _fotoBytesNovos;    // Bytes da NOVA imagem para exibição
  String? _fotoBase64Nova;    // Base64 da NOVA imagem para envio (se houver)
  String? _imageUrlExistente; // URL da imagem atual (se houver)

  final ImagePicker _picker = ImagePicker(); // Instância do ImagePicker

  // Listas e seleções para Dropdowns (sua lógica original)
  List<Map<String, dynamic>> marcas = [];
  // TODO: Carregar estas listas do backend se necessário
  final List<String> modelos = ['Modelo X', 'Modelo Y', 'Modelo Z'];
  final List<String> setores = ['ADM', 'Radio e TV', 'TI', 'Modelagem'];
  final List<String> statusList = ['Usando', 'Emprestado', 'Descartado'];
  // Adicionando fornecedores (exemplo, carregar do backend)
  List<Map<String, dynamic>> fornecedores = [{'id': 1, 'nome': 'Fornecedor A'}, {'id': 2, 'nome': 'Fornecedor B'}];
  String? _fornecedorSelecionado;

  String? _marcaSelecionada;
  String? _modeloSelecionado;
  String? _setorSelecionado;
  String? _statusSelecionado;

  bool _isLoadingMarcas = true; // Para indicar carregamento das marcas

  // --- initState (Lógica Original Adaptada) ---
  @override
  void initState() {
    super.initState();
    print("initState (Alterar): Populando campos com dados recebidos..."); // Log
    _id = widget.patrimonio['id']?.toString() ?? '';
    _marcaSelecionada = widget.patrimonio['marca']?.toString();
    _modeloSelecionado = widget.patrimonio['modelo']?.toString();
    _corController.text = widget.patrimonio['cor']?.toString() ?? '';
    _codigoController.text = widget.patrimonio['codigo']?.toString() ?? '';
    _dataController.text = widget.patrimonio['data']?.toString() ?? '';
    _setorSelecionado = widget.patrimonio['setor']?.toString();
    _statusSelecionado = widget.patrimonio['status']?.toString();
    _descricaoController.text = widget.patrimonio['descricao']?.toString() ?? '';
    _fornecedorSelecionado = widget.patrimonio['fornecedor']?.toString();

    if (widget.patrimonio['imagem'] != null && widget.patrimonio['imagem'].toString().isNotEmpty) {
      _imageUrlExistente = 'http://localhost/server/' + widget.patrimonio['imagem'].toString();
       print("Imagem existente URL: $_imageUrlExistente"); // Log
    } else {
       print("Nenhuma imagem existente encontrada."); // Log
    }

    _carregarMarcas();
  }

  // --- dispose (Lógica Original Mantida) ---
   @override
  void dispose() {
    _corController.dispose();
    _codigoController.dispose();
    _dataController.dispose();
    _descricaoController.dispose();
    print("dispose (Alterar): Controladores limpos."); // Log
    super.dispose();
  }

  // --- Funções Lógicas Originais (Mantidas e Adaptadas) ---

  // Função para carregar marcas (sua lógica original)
  Future<void> _carregarMarcas() async {
    // ... (código _carregarMarcas permanece o mesmo) ...
     setState(() => _isLoadingMarcas = true);
    print("Executando _carregarMarcas (Alterar)...");
    const String url = 'http://localhost/server/processa_bdCeet.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'acao': 'carregarMarca', 'marca_status': 'ativo'}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(const Duration(seconds: 15));

      print("Resposta Marcas (Alterar) (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 200))}...");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          final data = jsonResponse['data'];
          if (data is List) {
            marcas = List<Map<String, dynamic>>.from(
              data.map((item) => item is Map ? Map<String, dynamic>.from(item) : {})
            );
            marcas.removeWhere((item) => item.isEmpty || !item.containsKey('nome'));
             print("Marcas carregadas (Alterar): ${marcas.length} itens");
             if (_marcaSelecionada != null && !marcas.any((m) => m['nome'] == _marcaSelecionada)) {
               print("Atenção: Marca selecionada ('$_marcaSelecionada') não encontrada na lista carregada.");
             }
          } else {
             print('Erro no formato dos dados das marcas (Alterar).');
          }
        } else {
          print('Erro backend (carregar marcas - Alterar): ${jsonResponse['message']}');
        }
      } else {
        print('Erro HTTP (carregar marcas - Alterar): ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      print('Erro CATCH (carregar marcas - Alterar): $error');
      print('StackTrace: $stackTrace');
    } finally {
       if (mounted) {
          setState(() => _isLoadingMarcas = false);
       }
    }
  }

  // Função para adicionar nova marca (reutilizada de Inserir, mas adaptada)
  Future<void> _adicionarMarca(String novaMarca) async {
    // ... (código _adicionarMarca permanece o mesmo) ...
    const String url = "http://localhost/server/processa_bdCeet.php";
    print("Executando _adicionarMarca (Alterar): $novaMarca");
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'acao': 'inserirMarca', 'nome': novaMarca}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
       print("Resposta Add Marca (Alterar) (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
         final responseBody = json.decode(response.body);
         if(responseBody['status'] == 'success') {
             print("Marca '$novaMarca' adicionada, recarregando...");
            await _carregarMarcas();
            if (marcas.any((m) => m['nome'] == novaMarca)) {
               setState(() { _marcaSelecionada = novaMarca; });
               print("Marca '$novaMarca' selecionada (Alterar).");
            } else {
               print("Marca '$novaMarca' adicionada mas não encontrada após recarregar (Alterar).");
            }
         } else {
             print("Erro backend (add marca - Alterar): ${responseBody['message']}");
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar marca: ${responseBody['message']}'), backgroundColor: Colors.red));
         }
      } else {
         print("Erro HTTP (add marca - Alterar): ${response.statusCode}");
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro de comunicação ao adicionar marca.'), backgroundColor: Colors.red));
      }
    } catch (e, stackTrace) {
      print("Erro CATCH (add marca - Alterar): $e");
      print("StackTrace Add Marca (Alterar): $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao adicionar marca: $e'), backgroundColor: Colors.red));
    }
  }

  // Função para atualizar o patrimônio (sua lógica original adaptada)
  Future<void> _atualizarPatrimonio(BuildContext context) async {
    // ... (código _atualizarPatrimonio permanece o mesmo) ...
     print("Executando _atualizarPatrimonio...");
    if (!(_formKey.currentState?.validate() ?? false)) {
      print("Validação do formulário falhou (Alterar).");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha os campos obrigatórios destacados!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
     print("Validação do formulário OK (Alterar).");

    final Map<String, dynamic> data = {
      'acao': 'altera',
      'id': _id,
      'marca': _marcaSelecionada ?? '',
      'modelo': _modeloSelecionado ?? '',
      'cor': _corController.text,
      'codigo': _codigoController.text,
      'data': _dataController.text,
      'setor': _setorSelecionado ?? '',
      'status': _statusSelecionado ?? '',
      'descricao': _descricaoController.text,
      'fornecedor': _fornecedorSelecionado ?? '',
      // Se uma NOVA imagem foi selecionada, envia o base64 dela.
      // if (_fotoBase64Nova != null) 'foto': _fotoBase64Nova, // DESCOMENTE SE NECESSÁRIO E SE O BACKEND SUPORTAR
    };

    print("Dados a serem atualizados: ${json.encode(data).substring(0, min(json.encode(data).length, 300))}...");

    const String url = "http://localhost/server/processa_bdCeet.php";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 20));

      print("Resposta Atualização (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          if (responseBody['status'] == 'success') {
             print("Atualização bem-sucedida.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Atualização realizada com sucesso!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true); // Sinaliza sucesso para tela anterior
          } else {
            print("Falha ao atualizar (backend): ${responseBody['message']}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao atualizar: ${responseBody['message']}'), backgroundColor: Colors.red),
            );
          }
      } else {
          print("Erro HTTP ao atualizar: ${response.statusCode}");
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Erro no servidor (${response.statusCode}).'), backgroundColor: Colors.red),
           );
      }
    } catch (error, stackTrace) {
      print("Erro CATCH ao atualizar: $error");
      print("StackTrace Atualizar: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar patrimônio: $error'), backgroundColor: Colors.red),
      );
    }
  }

   // Função para selecionar/tirar NOVA foto - CORRIGIDO: Sem BuildContext
  Future<void> _escolherFotoNova() async { // <--- CORREÇÃO AQUI
    final picker = ImagePicker();
    print("Executando _escolherFotoNova (Galeria - Alterar)...");
    try {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
           print("Nova imagem selecionada da galeria: ${pickedFile.path}");
          setState(() {
            _imagemSelecionadaNova = File(pickedFile.path);
            _fotoBytesNovos = bytes;
            _fotoBase64Nova = base64Encode(bytes);
            _imageUrlExistente = null;
            print("Nova foto atualizada no estado (Alterar).");
          });
        } else {
          print('Nenhuma nova imagem selecionada da galeria (Alterar).');
        }
    } catch (e, stackTrace) {
       print("Erro CATCH (escolher foto nova): $e");
       print("StackTrace Escolher Foto Nova: $stackTrace");
       // Usa o context disponível na classe State
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao acessar a galeria: $e'), backgroundColor: Colors.red));
    }
  }

  // Função para tirar foto com a câmera - CORRIGIDO: Sem BuildContext
  Future<void> _tirarFotoNova() async { // <--- CORREÇÃO AQUI
     final picker = ImagePicker();
      print("Executando _tirarFotoNova (Câmera - Alterar)...");
     try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
       if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        print("Nova foto tirada com a câmera: ${pickedFile.path}");
        setState(() {
           _imagemSelecionadaNova = File(pickedFile.path);
           _fotoBytesNovos = bytes;
           _fotoBase64Nova = base64Encode(bytes);
           _imageUrlExistente = null;
           print("Nova foto atualizada no estado (Alterar).");
        });
      } else {
          print('Nenhuma nova foto tirada (cancelado - Alterar).');
      }
     } catch (e, stackTrace) {
       print("Erro CATCH (tirar foto nova): $e");
       print("StackTrace Tirar Foto Nova: $stackTrace");
       // Usa o context disponível na classe State
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao usar a câmera: $e'), backgroundColor: Colors.red));
     }
  }

  // Função para mostrar opções de imagem (BottomSheet)
  void _showImagePickerOptions() {
     print("Executando _showImagePickerOptions (Alterar)...");
    showModalBottomSheet(
      context: context, // Usa o context da classe State
      backgroundColor: Colors.white,
      builder: (BuildContext context) { // Este context é do builder
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: Colors.grey[700]),
                title: Text('Selecionar Nova Foto', style: TextStyle(color: Colors.grey[800])),
                onTap: () {
                   print("Opção Galeria selecionada (Alterar).");
                  _escolherFotoNova(); // Chama a função corrigida
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: Colors.grey[700]),
                title: Text('Tirar Nova Foto', style: TextStyle(color: Colors.grey[800])),
                onTap: () {
                   print("Opção Câmera selecionada (Alterar).");
                  _tirarFotoNova(); // Chama a função corrigida
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Função para selecionar data (sua lógica original)
  Future<void> _selecionarData(BuildContext context) async {
    // ... (código _selecionarData permanece o mesmo) ...
      print("Executando _selecionarData (Alterar)...");
     FocusScope.of(context).requestFocus(FocusNode());
    DateTime initialDate = DateTime.now();
    try {
      if (_dataController.text.isNotEmpty) {
        initialDate = DateTime.parse(_dataController.text);
      }
    } catch (e) {
      print("Erro ao parsear data inicial: $e. Usando data atual.");
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
       builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF009688),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF009688)),
            ),
             dialogTheme: const DialogTheme(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)))
            )
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
       String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
       print("Data selecionada (Alterar): $formattedDate");
      setState(() {
        _dataController.text = formattedDate;
      });
    } else {
       print("Seleção de data cancelada (Alterar).");
    }
  }

   // Função para mostrar dialog de adicionar marca (Reutilizada)
  void _mostrarDialogAdicionarMarca(BuildContext context) {
    // ... (código _mostrarDialogAdicionarMarca permanece o mesmo) ...
     print("Executando _mostrarDialogAdicionarMarca (Alterar)...");
    final TextEditingController novaMarcaController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Marca'),
          content: TextField(controller: novaMarcaController, decoration: const InputDecoration(labelText: 'Nome da Marca'), autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final novaMarca = novaMarcaController.text.trim();
                if (novaMarca.isNotEmpty) { _adicionarMarca(novaMarca); }
                Navigator.of(context).pop();
              },
               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688)),
              child: const Text('Adicionar'),
            ),
          ],
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        );
      },
    );
  }


  // --- Método build() com o Novo Layout ---
  @override
  Widget build(BuildContext context) {
     print("Executando build() de AlterarState...");

    // Estilos reutilizáveis
    final Color labelColor = Colors.grey[600]!;
    final Color inputColor = Colors.black87;
    final Color borderColor = Colors.grey[350]!;
    const double labelFontSize = 12.0;
    final InputBorder inputBorder = UnderlineInputBorder(borderSide: BorderSide(color: borderColor));
    final InputBorder focusedInputBorder = UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!));

    return Scaffold(
      // AppBar com novo estilo (com botão Voltar explícito)
      appBar: AppBar(
        leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.black87),
           onPressed: () => Navigator.of(context).pop(),
           tooltip: 'Voltar',
        ),
        title: const Text('Alterar Patrimonio', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1.0,
      ),
      // Fundo da tela
      backgroundColor: const Color(0xFFF8F8F8),
      // Corpo principal
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              // --- Campo Marca ---
              _isLoadingMarcas
                ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
                : _buildDropdownRowWithAdd(
                    label: 'Marca',
                    labelColor: labelColor,
                    labelFontSize: labelFontSize,
                    value: _marcaSelecionada,
                    items: marcas.map((marcaMap) {
                        final String nomeMarca = marcaMap['nome']?.toString() ?? 'Inválido';
                        return DropdownMenuItem<String>(value: nomeMarca, child: Text(nomeMarca));
                    }).toList(),
                    onChanged: (newValue) => setState(() { _marcaSelecionada = newValue; }),
                    onAddTap: () => _mostrarDialogAdicionarMarca(context),
                    inputBorder: inputBorder,
                    focusedInputBorder: focusedInputBorder,
                    validator: (value) => value == null ? 'Selecione uma marca' : null,
                 ),
              const SizedBox(height: 20),

              // --- Campo Modelo ---
              _buildDropdownRowWithAdd(
                 label: 'Modelo',
                 labelColor: labelColor,
                 labelFontSize: labelFontSize,
                 value: _modeloSelecionado,
                 items: modelos.map((String modelo) => DropdownMenuItem<String>(value: modelo, child: Text(modelo))).toList(),
                 onChanged: (newValue) => setState(() { _modeloSelecionado = newValue; }),
                 onAddTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionar novo modelo (Não implementado)'))); },
                 inputBorder: inputBorder,
                 focusedInputBorder: focusedInputBorder,
                 validator: (value) => value == null ? 'Selecione um modelo' : null,
              ),
              const SizedBox(height: 20),

              // --- Campo Setor ---
               _buildDropdownSimple(
                label: 'Setor',
                labelColor: labelColor,
                labelFontSize: labelFontSize,
                value: _setorSelecionado,
                items: setores.map((String setor) => DropdownMenuItem<String>(value: setor, child: Text(setor))).toList(),
                onChanged: (newValue) => setState(() { _setorSelecionado = newValue; }),
                inputBorder: inputBorder,
                focusedInputBorder: focusedInputBorder,
                 validator: (value) => value == null ? 'Selecione um setor' : null,
              ),
              const SizedBox(height: 20),

               // --- Campo Status ---
               _buildDropdownSimple(
                label: 'Status',
                labelColor: labelColor,
                labelFontSize: labelFontSize,
                value: _statusSelecionado,
                items: statusList.map((String status) => DropdownMenuItem<String>(value: status, child: Text(status))).toList(),
                onChanged: (newValue) => setState(() { _statusSelecionado = newValue; }),
                inputBorder: inputBorder,
                focusedInputBorder: focusedInputBorder,
                 validator: (value) => value == null ? 'Selecione um status' : null,
              ),
              const SizedBox(height: 20),

              // --- Campo Cor ---
              _buildTextField(
                controller: _corController,
                label: 'Cor',
                labelColor: labelColor,
                labelFontSize: labelFontSize,
                inputColor: inputColor,
                keyboardType: TextInputType.text,
                inputBorder: inputBorder,
                focusedInputBorder: focusedInputBorder,
                 validator: (value) => (value == null || value.isEmpty) ? 'Informe a cor' : null,
              ),
              const SizedBox(height: 20),

              // --- Campo Codigo ---
               _buildTextField(
                controller: _codigoController,
                label: 'Codigo',
                labelColor: labelColor,
                labelFontSize: labelFontSize,
                inputColor: inputColor,
                keyboardType: TextInputType.text,
                inputBorder: inputBorder,
                focusedInputBorder: focusedInputBorder,
                 validator: (value) => (value == null || value.isEmpty) ? 'Informe o código' : null,
              ),
              const SizedBox(height: 20),

              // --- Campo Data ---
              _buildTextField(
                controller: _dataController,
                label: 'Data',
                labelColor: labelColor,
                labelFontSize: labelFontSize,
                inputColor: inputColor,
                hintText: 'dd / mm / aaaa',
                keyboardType: TextInputType.datetime,
                inputBorder: inputBorder,
                focusedInputBorder: focusedInputBorder,
                onTap: () => _selecionarData(context),
                readOnly: true,
              ),
              const SizedBox(height: 20),

               // --- Campo Descrição ---
               _buildTextField(
                controller: _descricaoController,
                label: 'Descrição',
                labelColor: labelColor,
                labelFontSize: labelFontSize,
                inputColor: inputColor,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                inputBorder: inputBorder,
                focusedInputBorder: focusedInputBorder,
              ),
              const SizedBox(height: 20),

              // --- Campo Fornecedor ---
              _buildDropdownRowWithAdd(
                 label: 'Fornecedor',
                 labelColor: labelColor,
                 labelFontSize: labelFontSize,
                 value: _fornecedorSelecionado,
                 items: fornecedores.map((fornMap) {
                    final String nomeForn = fornMap['nome']?.toString() ?? 'Inválido';
                    return DropdownMenuItem<String>(value: nomeForn, child: Text(nomeForn));
                 }).toList(),
                 onChanged: (newValue) => setState(() { _fornecedorSelecionado = newValue; }),
                 onAddTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionar novo fornecedor (Não implementado)'))); },
                 inputBorder: inputBorder,
                 focusedInputBorder: focusedInputBorder,
              ),
              const SizedBox(height: 35),

              // --- Seção da Foto ---
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                      label: Text(
                        _fotoBytesNovos != null || _imageUrlExistente != null ? 'Alterar Foto' : 'Adicionar Foto',
                        style: TextStyle(color: Colors.white)
                       ),
                      onPressed: _showImagePickerOptions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey[350]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                         borderRadius: BorderRadius.circular(7.0),
                         child: _fotoBytesNovos != null
                           ? Image.memory(_fotoBytesNovos!, fit: BoxFit.cover)
                           : _imageUrlExistente != null
                               ? Image.network(
                                   _imageUrlExistente!,
                                   fit: BoxFit.cover,
                                   loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator(strokeWidth: 2, value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null)),
                                   errorBuilder: (context, error, stack) {
                                     print("Erro ao carregar imagem existente '$_imageUrlExistente': $error");
                                     return Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey[400]);
                                   }
                                 )
                               : Center(child: Icon(Icons.image_outlined, size: 70, color: Colors.grey[400])),
                        ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // --- Botão Atualizar ---
              Center(
                child: ElevatedButton(
                  onPressed: () => _atualizarPatrimonio(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    elevation: 3,
                  ),
                  child: const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


 // ===========================================================
 //     REUTILIZAÇÃO DOS HELPER WIDGETS DE 'inserir.dart'
 // ===========================================================

 // Helper para campos de texto com label acima e underline
 Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color labelColor,
    required double labelFontSize,
    required Color inputColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hintText,
    FormFieldValidator<String>? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    required InputBorder inputBorder,
    required InputBorder focusedInputBorder,
  }) {
    // ... (código _buildTextField permanece o mesmo) ...
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: labelFontSize, color: labelColor, height: 1.2)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 15, color: inputColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            enabledBorder: inputBorder,
            focusedBorder: focusedInputBorder,
            errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)),
            focusedErrorBorder: focusedInputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)),
            errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 0.8), // Estilo da msg de erro
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 6.0, bottom: 8.0), // Ajuste fino do padding vertical
          ),
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
        ),
      ],
    );
  }

 // Helper para Dropdowns simples com label acima e underline
 Widget _buildDropdownSimple({
    required String label,
    required Color labelColor,
    required double labelFontSize,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String>? validator,
     required InputBorder inputBorder,
     required InputBorder focusedInputBorder,
  }) {
    // ... (código _buildDropdownSimple permanece o mesmo) ...
    final validValue = items.any((item) => item.value == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
       mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: labelFontSize, color: labelColor, height: 1.2)),
        DropdownButtonFormField<String>(
          value: validValue,
          items: items,
          onChanged: onChanged,
          style: TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            enabledBorder: inputBorder,
            focusedBorder: focusedInputBorder,
            errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)),
            focusedErrorBorder: focusedInputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)),
             errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 0.8),
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 6.0, bottom: 8.0, right: 0),
          ),
          icon: Padding(
             padding: const EdgeInsets.only(left: 8.0),
             child: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ),
          iconSize: 24,
          isExpanded: true,
          validator: validator,
        ),
      ],
    );
  }

 // Helper para Dropdowns com label acima, underline E botão '+'
 Widget _buildDropdownRowWithAdd({
    required String label,
    required Color labelColor,
    required double labelFontSize,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required VoidCallback onAddTap,
    FormFieldValidator<String>? validator,
    required InputBorder inputBorder,
    required InputBorder focusedInputBorder,
  }) {
    // ... (código _buildDropdownRowWithAdd permanece o mesmo) ...
     final validValue = items.any((item) => item.value == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
       mainAxisSize: MainAxisSize.min,
      children: [
         Text(label, style: TextStyle(fontSize: labelFontSize, color: labelColor, height: 1.2)),
         Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                 value: validValue,
                items: items,
                onChanged: onChanged,
                style: TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  enabledBorder: inputBorder,
                  focusedBorder: focusedInputBorder,
                  errorBorder: inputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)),
                  focusedErrorBorder: focusedInputBorder.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.2)),
                  errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent, height: 0.8),
                  isDense: true,
                  contentPadding: const EdgeInsets.only(top: 6.0, bottom: 8.0, right: 0),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ),
                 iconSize: 24,
                isExpanded: true,
                validator: validator,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 0),
              child: IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.grey[700], size: 26),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20,
                tooltip: 'Adicionar Novo $label',
                onPressed: onAddTap,
              ),
            ),
          ],
        ),
      ],
    );
  }


} // Fim da classe _AlterarState
