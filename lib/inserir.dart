import 'dart:convert';
import 'dart:typed_data';
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

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
    _carregarModelos(); // Carrega os modelos do banco
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

  Future<void> _adicionarMarca(String novaMarca) async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'acao': 'inserirMarca', 'nome': novaMarca}),
        headers: {'Content-Type': 'application/json'},
      );
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
