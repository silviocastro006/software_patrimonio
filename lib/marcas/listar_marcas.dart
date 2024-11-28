import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListarMarcas extends StatefulWidget {
  const ListarMarcas({Key? key}) : super(key: key);

  @override
  _ListarMarcasState createState() => _ListarMarcasState();
}

class _ListarMarcasState extends State<ListarMarcas> {
  List<dynamic> marcas = [];

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
  }

  Future<void> _carregarMarcas() async {
    const String url = "http://localhost/server/processa_bdCeet.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'acao': 'listarMarcas'}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          marcas = json.decode(response.body);
        });
      } else {
        print('Erro ao carregar marcas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }

  Future<void> _excluirMarca(int id) async {
    const String url = "http://localhost/server/processa_bdCeet.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'acao': 'excluirMarca', 'id': id.toString()}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marca excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _carregarMarcas(); // Recarregar a lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Erro ao excluir: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listar Marcas'),
        backgroundColor: Colors.blue,
      ),
      body: marcas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: marcas.length,
              itemBuilder: (context, index) {
                final marca = marcas[index];
                return Card(
                  child: ListTile(
                    title: Text(marca['nome']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluirMarca(marca['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
