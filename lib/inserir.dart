import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Inserir extends StatefulWidget {
  const Inserir({Key? key}) : super(key: key);

  @override
  _InserirState createState() => _InserirState();
}

class _InserirState extends State<Inserir> {
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String? _fotoBase64;

  List<Map<String, dynamic>> marcas = [];
  final List<String> modelos = ['Modelo X', 'Modelo Y', 'Modelo Z'];
  final List<String> setores = ['ADM', 'Radio e TV', 'TI', 'Modelagem'];
  final List<String> statusList = ['Usando', 'Emprestado', 'Descartado'];

  String? _marcaSelecionada; // Alteração aqui: agora é uma String
  String? _modeloSelecionado;
  String? _setorSelecionado;
  String? _statusSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
  }

  Future<void> fetchBrands() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost/server/processa_bdCeet.php'));

      // Imprimir a resposta para diagnóstico
      print('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        // Parse JSON apenas se a resposta for válida
        final data = jsonDecode(response.body);
        // Lógica para processar os dados
      } else {
        print('Erro ao carregar dados: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao fazer a requisição: $e');
    }
  }

  Future<void> listarMarcas() async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, dynamic> data = {
      'acao': 'listarMarcas',
    };

    try {
      // Enviando a requisição POST
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );

      if (response.statusCode == 200) {
        // Se a requisição for bem-sucedida
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'sucesso') {
          List marcas = jsonResponse['dados'];
          // Preencher o campo marcas com os dados
          print(marcas); // Exemplo de como usar a lista de marcas
        } else {
          print("Erro: ${jsonResponse['mensagem']}");
        }
      } else {
        print("Erro na requisição: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro na requisição ou ao decodificar o JSON: $e");
    }
  }

  Future<void> _carregarMarcas() async {
    const String url = 'http://localhost/server/processa_bdCeet.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'acao': 'carregarMarca',
          'marca_status': 'ativo',
        }),
        headers: {'Content-Type': 'application/json'},
      );

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
          print('Erro no backend: ${jsonResponse['message']}');
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao carregar marcas: $error');
    }
  }

  Future<void> _adicionarMarca(String novaMarca) async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'acao': 'inserirMarca', 'nome': novaMarca}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _carregarMarcas(); // Atualizar a lista de marcas após adicionar
      } else {
        print("Erro ao adicionar marca: ${response.body}");
      }
    } catch (e) {
      print("Erro na requisição ao adicionar marca: $e");
    }
  }

  Future<void> _enviarDados(BuildContext context) async {
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
      'marca_status': _marcaSelecionada, // Agora é uma string
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
        _fotoBase64 = base64Encode(bytes); // Atribuindo a imagem base64
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione uma foto!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dataController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _mostrarDialogAdicionarMarca(BuildContext context) {
    final TextEditingController novaMarcaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Marca'),
          content: TextField(
            controller: novaMarcaController,
            decoration: const InputDecoration(labelText: 'Nova Marca'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final novaMarca = novaMarcaController.text.trim();
                if (novaMarca.isNotEmpty) {
                  _adicionarMarca(novaMarca);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Adicionar Patrimônio'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildDropdownComAdicao(
              'Marca',
              _marcaSelecionada, // Alteração aqui: agora é uma String
              marcas,
              (newValue) => setState(() {
                _marcaSelecionada = newValue;
              }),
              () => _mostrarDialogAdicionarMarca(context),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Modelo',
              _modeloSelecionado,
              modelos,
              (newValue) => setState(() {
                _modeloSelecionado = newValue;
              }),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Setor',
              _setorSelecionado as String?,
              setores,
              (newValue) => setState(() {
                _setorSelecionado = newValue as String?;
              }),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              'Status',
              _statusSelecionado as String?,
              statusList,
              (newValue) => setState(() {
                _statusSelecionado = newValue as String?;
              }),
            ),
            const SizedBox(height: 10),
            _buildTextField(_corController, 'Cor'),
            const SizedBox(height: 10),
            _buildTextField(_codigoController, 'Código'),
            const SizedBox(height: 10),
            _buildDateField(context),
            const SizedBox(height: 10),
            _buildTextField(_descricaoController, 'Descrição'),
            const SizedBox(height: 10),
            _buildFotoPicker(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _enviarDados(context),
              child: const Text('Adicionar Patrimônio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                foregroundColor:
                    Colors.white, // Define a cor do texto como branca
              ),
            ),
          ],
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
        Text(label, style: const TextStyle(color: Colors.white)),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                onChanged: (newValue) => onChanged(newValue),
                dropdownColor: Colors.grey[800], // Cor de fundo do menu
                style: const TextStyle(
                    color: Colors.white), // Cor do texto selecionado
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

  Widget _buildDropdown(String label, String? selectedValue, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          onChanged: (newValue) => onChanged(newValue),
          dropdownColor: Colors.grey[800], // Cor de fundo do menu
          style:
              const TextStyle(color: Colors.white), // Cor do texto selecionado
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _dataController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Data',
              labelStyle: const TextStyle(color: Colors.white),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              filled: true,
              fillColor: Colors.grey[800],
            ),
            onTap: () => _selecionarData(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFotoPicker() {
    return GestureDetector(
      onTap: _escolherFoto,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _fotoBase64 == null
            ? const Icon(Icons.add_a_photo, color: Colors.white)
            : Image.memory(
                base64Decode(_fotoBase64!),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
