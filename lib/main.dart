import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu.dart';
import 'menuAdm.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login Usuário",
      home: MeuAplicativo(),
      theme: ThemeData(
        primaryColor: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Definindo a cor padrão do texto
        ),
      ),
    );
  }
}

class MeuAplicativo extends StatelessWidget {
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _login = TextEditingController();

  MeuAplicativo({super.key});

  Future<void> _enviarDados(BuildContext context) async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, String> data = {
      'acao': 'logar',
      'usuario': _login.text.toUpperCase(),
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
          if (_login.text.toLowerCase().startsWith('adm')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuAdm()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Menu()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login falhou: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Falha ao enviar os dados. Código de resposta: ${response.statusCode}");
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: Container(
  color: const Color.fromARGB(137, 0, 89, 255), // Cor sólida definida aqui
  child: Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400, // Responsivo em telas maiores
        ),
        child: Column(
          children: <Widget>[
            const Text(
              'Bem-vindo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _login,
              style: const TextStyle(color: Colors.white), // Cor do texto inserido
              decoration: InputDecoration(
                labelText: 'Login',
                labelStyle: const TextStyle(color: Colors.white),
                fillColor: Colors.white.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _senha,
              style: const TextStyle(color: Colors.white), // Cor do texto inserido
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: const TextStyle(color: Colors.white),
                fillColor: Colors.white.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 6, 0, 61), // Verde claro para o botão
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                _enviarDados(context);
              },
              child: const Text('Entrar'),
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
