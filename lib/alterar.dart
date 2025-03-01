import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Alterar extends StatefulWidget {
  final Map<String, dynamic> patrimonio;

  const Alterar({super.key, required this.patrimonio});

  @override
  // ignore: library_private_types_in_public_api
  _AlterarState createState() => _AlterarState();
}

class _AlterarState extends State<Alterar> {
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  late String _id;

  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> marcas = []; // Lista de marcas carregadas do banco
  final List<String> modelos = ['Modelo X', 'Modelo Y', 'Modelo Z'];
  final List<String> setores = ['ADM', 'Radio e TV', 'TI', 'Modelagem'];
  final List<String> statusList = ['Usando', 'Emprestado', 'Descartado'];

  String? _marcaSelecionada;
  String? _modeloSelecionado;
  String? _setorSelecionado;
  String? _statusSelecionado;

  @override
  void initState() {
    super.initState();
    _id = widget.patrimonio['id']?.toString() ?? '';
    _marcaSelecionada = widget.patrimonio['marca'] ?? null; // Usa o campo 'nome' da tabela
    _modeloSelecionado = widget.patrimonio['modelo'] ?? '';
    _corController.text = widget.patrimonio['cor'] ?? '';
    _codigoController.text = widget.patrimonio['codigo'] ?? '';
    _dataController.text = widget.patrimonio['data'] ?? '';
    _setorSelecionado = widget.patrimonio['setor'] ?? '';
    _statusSelecionado = widget.patrimonio['status'] ?? '';
    _descricaoController.text = widget.patrimonio['descricao'] ?? '';

    _carregarMarcas(); // Carrega as marcas ao inicializar a tela
  }

   Future<void> _carregarMarcas() async {
    const String url = 'http://localhost/server/processa_bdCeet.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'acao': 'carregarMarca',
          'marca_status': 'ativo', // Filtra marcas com status 'ativo'
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

  Future<void> _atualizarPatrimonio(BuildContext context) async {
    if (_marcaSelecionada == null ||
        _modeloSelecionado == null ||
        _corController.text.isEmpty ||
        _codigoController.text.isEmpty ||
        _dataController.text.isEmpty ||
        _statusSelecionado == null ||
        _setorSelecionado == null ||
        _descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return;
    }

    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, dynamic> data = {
      'acao': 'altera',
      'id': _id,
      'marca': _marcaSelecionada,
      'modelo': _modeloSelecionado,
      'cor': _corController.text,
      'codigo': _codigoController.text,
      'data': _dataController.text,
      'setor': _setorSelecionado,
      'status': _statusSelecionado,
      'descricao': _descricaoController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseBody = json.decode(response.body);
      if (responseBody['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualização realizada com sucesso!')),
        );
        Navigator.pop(context); // Retorna à tela anterior após a atualização
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Falha ao atualizar: ${responseBody['message']}')),
        );
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar patrimônio.')),
      );
    }
  }

  

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Alterar Patrimônio',
        style: TextStyle(color: Colors.white),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
          },
        ),
      ],
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Substitua _buildDropdownMarcas() pelo FutureBuilder
              FutureBuilder<void>(
                future: _carregarMarcas(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Exibe um indicador de carregamento
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar marcas: ${snapshot.error}');
                  } else {
                    return _buildDropdownMarcas(); // Exibe o Dropdown de marcas
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown('Modelo', _modeloSelecionado, modelos, (newValue) {
                setState(() => _modeloSelecionado = newValue);
              }),
              const SizedBox(height: 16),
              _buildTextField('Cor', _corController),
              const SizedBox(height: 16),
              _buildTextField('Código', _codigoController),
              const SizedBox(height: 16),
              _buildTextField('Descrição', _descricaoController),
              const SizedBox(height: 16),
              _buildDropdown('Setor', _setorSelecionado, setores, (newValue) {
                setState(() => _setorSelecionado = newValue);
              }),
              const SizedBox(height: 16),
              _buildDropdown('Status', _statusSelecionado, statusList, (newValue) {
                setState(() => _statusSelecionado = newValue);
              }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Data',
                  labelStyle: const TextStyle(color: Colors.white),
                  fillColor: Colors.white.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                readOnly: true,
                onTap: () => _selecionarData(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF4CAF50), // Verde
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _atualizarPatrimonio(context),
                child: const Text('Atualizar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  Widget _buildDropdownMarcas() {
    return DropdownButtonFormField<String>(
      value: marcas.any((marca) => marca['nome'] == _marcaSelecionada)
          ? _marcaSelecionada
          : null,
      items: marcas.map<DropdownMenuItem<String>>((Map<String, dynamic> marca) {
        return DropdownMenuItem<String>(
          value: marca['nome'] as String, // Usa o campo 'nome' da tabela
          child: Text(
            marca['nome'] as String,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _marcaSelecionada = newValue;
        });
      },
      dropdownColor: Colors.grey[800],
      decoration: InputDecoration(
        labelText: 'Marca',
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue,
      List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options.map((String option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.grey[800],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
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
}