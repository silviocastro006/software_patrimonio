import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Excluir extends StatefulWidget {
  const Excluir({Key? key}) : super(key: key);

  @override
  _ExcluirState createState() => _ExcluirState();
}

class _ExcluirState extends State<Excluir> {
  List<Map<String, dynamic>> _produtos = [];

  @override
  void initState() {
    super.initState();
    _listarProdutos();
  }

  Future<void> _listarProdutos() async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, String> data = {
      'acao': 'listar',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            // Filtra os produtos, excluindo os que têm status 'descartado'
            _produtos = List<Map<String, dynamic>>.from(responseBody['produtos'])
                .where((produto) => produto['status'] != 'descartado')
                .toList();
          });
        } else {
          _showErrorDialog('Erro ao listar produtos');
        }
      } else {
        _showErrorDialog('Falha na comunicação com o servidor');
      }
    } catch (e) {
      _showErrorDialog('Erro ao se conectar com o servidor: $e');
    }
  }

  Future<void> _descartarProduto(int id) async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, dynamic> data = {
      'acao': 'descartar',
      'id': id,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          _showSuccessDialog(responseBody['message']);
          _listarProdutos(); // Atualiza a lista após a exclusão
        } else {
          _showErrorDialog(responseBody['message']);
        }
      } else {
        _showErrorDialog('Falha na comunicação com o servidor');
      }
    } catch (e) {
      _showErrorDialog('Erro ao se conectar com o servidor: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sucesso'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: const Text('Excluir Produto'),
        backgroundColor: const Color(0xFF1C3A5C), // Cor do AppBar semelhante ao main.dart
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1C3A5C),
              Color(0xFF004d40),
              Color(0xFF311B92)
            ], // Cores do gradiente de fundo
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _produtos.length,
          itemBuilder: (context, index) {
            final produto = _produtos[index];
            return Card(
              color: Colors.white.withOpacity(0.8),
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  produto['marca'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Modelo: ${produto['modelo']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _descartarProduto(produto['id']);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
