import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu.dart'; // Import da tela de menu normal
import 'menuAdm.dart'; // Import da tela de menu admin
import 'alterar.dart'; // Import da tela de alterar

class Busca extends StatefulWidget {
  const Busca({super.key});

  @override
  _BuscaState createState() => _BuscaState();
}

class _BuscaState extends State<Busca> {
  final TextEditingController _filterController = TextEditingController();
  List<Map<String, dynamic>> _patrimonios = [];
  List<Map<String, dynamic>> _filteredPatrimonios = [];

  @override
  void initState() {
    super.initState();
    _fetchPatrimonios();
  }

  Future<void> _fetchPatrimonios() async {
    const String url = "http://localhost/api/processa_bdCeet.php";
    final Map<String, String> data = {'acao': 'listar'};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            _patrimonios =
                List<Map<String, dynamic>>.from(responseBody['produtos'])
                    .where((patrimonio) => patrimonio['status'] != 'descartado')
                    .toList();
            _filteredPatrimonios = _patrimonios;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao buscar: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
    }
  }

  void _filterPatrimonios(String query) {
    setState(() {
      _filteredPatrimonios = _patrimonios.where((patrimonio) {
        bool matchesQuery = patrimonio['marca']
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            patrimonio['modelo'].toLowerCase().contains(query.toLowerCase()) ||
            patrimonio['data'].contains(query);
        bool isNotDescartado = patrimonio['status'] != 'descartado';
        return matchesQuery && isNotDescartado;
      }).toList();
    });
  }

  void _goToAlterarPage(Map<String, dynamic> patrimonio) {
    // Verifica se o patrimônio contém todos os campos necessários
    if (patrimonio['id'] == null ||
        patrimonio['marca'] == null ||
        patrimonio['modelo'] == null ||
        patrimonio['cor'] == null ||
        patrimonio['codigo'] == null ||
        patrimonio['data'] == null ||
        patrimonio['setor'] == null ||
        patrimonio['status'] == null ||
        patrimonio['descricao'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do patrimônio incompletos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Log para depuração
    print('Dados do patrimônio: $patrimonio');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Alterar(
          patrimonio: patrimonio, // Passa o patrimônio inteiro, incluindo o ID
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consultar Patrimônios',
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuAdm(),
                ),
                (Route<dynamic> route) => false,
              );
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
          child: Column(
            children: [
              TextField(
                controller: _filterController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Filtrar por marca, modelo, data ou status',
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                onChanged: _filterPatrimonios,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredPatrimonios.length,
                  itemBuilder: (context, index) {
                    final patrimonio = _filteredPatrimonios[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      color: Colors.white.withOpacity(0.1),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://localhost/api/' + patrimonio['imagem'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Erro ao carregar imagem: $error');
                              return const Icon(Icons.error, color: Colors.white);
                            },
                          ),
                        ),
                        title: Text(
                          'Marca: ${patrimonio['marca']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Modelo: ${patrimonio['modelo']}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Cor: ${patrimonio['cor']}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Data: ${patrimonio['data']}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Status: ${patrimonio['status']}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _goToAlterarPage(patrimonio),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50), // Verde
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '+ Detalhes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}