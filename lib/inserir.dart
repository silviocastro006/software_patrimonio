import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Inserir extends StatefulWidget {
  const Inserir({Key? key}) : super(key: key);

  @override
  _InserirState createState() => _InserirState();
}

class _InserirState extends State<Inserir> {
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String? _fotoBase64;

  // Listas de opções para marca e modelo
  final List<String> marcas = ['MOOB', 'MOOB Chicago', 'Atlanta Duoffice'];
  final List<String> modelos = ['Modelo X', 'Modelo Y', 'Modelo Z'];

  // Valores selecionados
  String? _marcaSelecionada;
  String? _modeloSelecionado;

  Future<void> _enviarDados(BuildContext context) async {
    const String url = "http://localhost/server/processa_bdCeet.php";

    final Map<String, String> data = {
      'comando': 'inserir',
      'marca': _marcaSelecionada ?? '',
      'modelo': _modeloSelecionado ?? '',
      'cor': _corController.text,
      'codigo': _codigoController.text,
      'data': _dataController.text,
      'foto': _fotoBase64 ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(data),
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
        print("Erro na requisição. Código de resposta: ${response.statusCode}");
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
    }
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _fotoBase64 = base64Encode(bytes);
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserir Dados'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C3A5C), Color(0xFF004d40), Color(0xFF311B92)], // Tons mais escuros
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // Responsividade em telas maiores
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _marcaSelecionada,
                    items: marcas.map((String marca) {
                      return DropdownMenuItem(
                        value: marca,
                        child: Text(marca, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _marcaSelecionada = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Marca',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _modeloSelecionado,
                    items: modelos.map((String modelo) {
                      return DropdownMenuItem(
                        value: modelo,
                        child: Text(modelo, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _modeloSelecionado = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Modelo',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _corController,
                    decoration: InputDecoration(
                      labelText: 'Cor',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataController,
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
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF50E3C2), // Verde claro para o botão
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _escolherFoto,
                    child: const Text('Escolher Foto'),
                  ),
                  if (_fotoBase64 != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.memory(
                        base64Decode(_fotoBase64!),
                        height: 100,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF50E3C2), // Verde claro para o botão
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => _enviarDados(context),
                    child: const Text('Inserir'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
