import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InserirFuncionario extends StatelessWidget {
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _senha = TextEditingController();

  InserirFuncionario({Key? key}) : super(key: key);

  Future<void> _enviarDados(BuildContext context) async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, String> data = {
      'acao': 'criaUsuario',
      'usuario': _usuario.text.toUpperCase(),
      'senha': _senha.text.toUpperCase(),
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
          // Limpa os campos após a inserção bem-sucedida
          _usuario.clear();
          _senha.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastrar Funcionário',
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // Responsividade em telas maiores
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _usuario,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      labelStyle: const TextStyle(color: Colors.white),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _senha,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.white),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF4CAF50), // Verde
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 5, // Sombra sutil
                    ),
                    onPressed: () {
                      _enviarDados(context);
                    },
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