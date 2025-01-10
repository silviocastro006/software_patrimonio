import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C3A5C), Color(0xFF004d40), Color(0xFF311B92)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Cadastrar Funcionário', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent, // Mantém o fundo transparente para usar o gradiente
            elevation: 0, // Removendo a sombra do AppBar
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C3A5C), Color(0xFF004d40), Color(0xFF311B92)],
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
                  TextFormField(
                    controller: _usuario,
                    style: const TextStyle(color: Colors.white), // Texto dentro do campo branco
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors
                          .transparent, // Definido como transparente para manter o fundo do campo igual ao da página
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senha,
                    style: const TextStyle(color: Colors.white), // Texto dentro do campo branco
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors
                          .transparent, // Definido como transparente para manter o fundo do campo igual ao da página
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          const Color(0xFF50E3C2), // Verde claro para o botão
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
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
