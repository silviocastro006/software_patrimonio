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
      'comando': 'listar',
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
            _produtos = List<Map<String, dynamic>>.from(responseBody['produtos']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao buscar produtos: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Erro ao listar os produtos. Código de resposta: ${response.statusCode}");
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
    }
  }

  Future<void> _excluirProduto(int id) async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, String> data = {
      'comando': 'deletar',
      'id': id.toString(),
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
            _produtos.removeWhere((produto) => produto['id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir produto: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Erro ao excluir o produto. Código de resposta: ${response.statusCode}");
      }
    } catch (error) {
      print("Erro durante a requisição de exclusão: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela de Excluir'),
        backgroundColor: const Color(0xFF1C3A5C),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C3A5C), Color(0xFF004d40), Color(0xFF311B92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _produtos.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _produtos.length,
                itemBuilder: (context, index) {
                  final produto = _produtos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        produto['marca'],
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        'Modelo: ${produto['modelo']} | Cor: ${produto['cor']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _excluirProduto(produto['id']),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
