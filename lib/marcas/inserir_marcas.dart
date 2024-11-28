import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InserirMarcas extends StatefulWidget {
  const InserirMarcas({Key? key}) : super(key: key);

  @override
  _InserirMarcasState createState() => _InserirMarcasState();
}

class _InserirMarcasState extends State<InserirMarcas> {
  final TextEditingController _marcaController = TextEditingController();

  Future<void> _adicionarMarca(BuildContext context) async {
    const String url = "http://localhost/server/processa_bdCeet.php";

    if (_marcaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O campo marca não pode estar vazio!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, String> data = {
      'acao': 'inserirMarca',
      'nome': _marcaController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marca adicionada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _marcaController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserir Marca'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _marcaController,
              decoration: InputDecoration(
                labelText: 'Nome da Marca',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _adicionarMarca(context),
              child: const Text('Adicionar Marca'),
            ),
          ],
        ),
      ),
    );
  }
}
