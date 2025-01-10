import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Alterar extends StatefulWidget {
  final Map<String, dynamic> patrimonio;

  const Alterar({Key? key, required this.patrimonio}) : super(key: key);

  @override
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

  final List<String> marcas = ['MOOB', 'MOOB Chicago', 'Atlanta Duoffice'];
  final List<String> modelos = ['Modelo X', 'Modelo Y', 'Modelo Z'];
  final List<String> setores = ['ADM', 'Radio e TV', 'TI', 'Modelagem'];
  final List<String> statusList = ['Usando', 'Emprestado', 'descartado'];

  String? _marcaSelecionada;
  String? _modeloSelecionado;
  String? _setorSelecionado;
  String? _statusSelecionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _marcaSelecionada = widget.patrimonio['marca'] ?? '';
        _modeloSelecionado = widget.patrimonio['modelo'] ?? '';
        _corController.text = widget.patrimonio['cor'] ?? '';
        _codigoController.text = widget.patrimonio['codigo'] ?? '';
        _dataController.text = widget.patrimonio['data'] ?? '';
        _setorSelecionado = widget.patrimonio['setor'] ?? '';
        _statusSelecionado = widget.patrimonio['status'] ?? '';
        _descricaoController.text = widget.patrimonio['descricao'] ?? '';
      });
    });
    _id = widget.patrimonio['id'].toString(); // Inicializa o ID do patrimônio
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C3A5C), Color(0xFF004d40), Color(0xFF311B92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Cabeçalho personalizado
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1C3A5C),
                    Color(0xFF004d40),
                    Color(0xFF311B92)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'Alterar Dados',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Corpo do formulário
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        _buildDropdown('Marca', _marcaSelecionada, marcas,
                            (newValue) {
                          setState(() => _marcaSelecionada = newValue);
                        }),
                        const SizedBox(height: 16),
                        _buildDropdown('Modelo', _modeloSelecionado, modelos,
                            (newValue) {
                          setState(() => _modeloSelecionado = newValue);
                        }),
                        const SizedBox(height: 16),
                        _buildTextField('Cor', _corController),
                        const SizedBox(height: 16),
                        _buildTextField('Código', _codigoController),
                        const SizedBox(height: 16),
                        _buildTextField('Descrição', _descricaoController),
                        const SizedBox(height: 16),
                        _buildDropdown('Setor', _setorSelecionado, setores,
                            (newValue) {
                          setState(() => _setorSelecionado = newValue);
                        }),
                        const SizedBox(height: 16),
                        _buildDropdown('Status', _statusSelecionado, statusList,
                            (newValue) {
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
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selecionarData(context),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, // Cor do texto
                            backgroundColor: const Color.fromARGB(255, 11, 128, 102), // Verde claro para o botão
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Borda arredondada
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15), // Espaçamento interno
                            minimumSize: const Size(double.infinity,
                                50), // Largura total e altura mínima
                          ),
                          onPressed: () => _atualizarPatrimonio(context),
                          child: const Text('Atualizar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      dropdownColor: Colors.black,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
          color: Colors.white), // Define o texto digitado como branco
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
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
