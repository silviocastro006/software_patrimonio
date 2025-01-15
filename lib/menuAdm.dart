import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart'; // Import da tela de login
import 'busca.dart';
import 'inserir.dart';
import 'excluir.dart';
import 'inserirFuncionario.dart';
import 'package:http/http.dart' as http;

class MenuAdm extends StatelessWidget {
  const MenuAdm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.orange,
          backgroundColor: Colors.grey,
        ),
      ),
      home: const TelaPrincipalAdm(),
    );
  }
}

class TelaPrincipalAdm extends StatefulWidget {
  const TelaPrincipalAdm({Key? key}) : super(key: key);

  @override
  _TelaPrincipalAdmState createState() => _TelaPrincipalAdmState();
}

class _TelaPrincipalAdmState extends State<TelaPrincipalAdm> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ResumoPatrimonio(),
    const Inserir(),
    const Busca(),
    InserirFuncionario(),
    const Excluir(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Administrador'),
        backgroundColor: const Color.fromARGB(179, 233, 224, 224), // Cor de fundo cinza
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color.fromARGB(179, 233, 224, 224), // Cor de fundo cinza
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Resumo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Inserir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Consulta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Funcionário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Excluir',
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 45), // Move o botão 10px para cima
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
              (Route<dynamic> route) => false,
            );
          },
          child: const Icon(Icons.exit_to_app, color: Colors.white),
          tooltip: 'Sair',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class ResumoPatrimonio extends StatefulWidget {
  const ResumoPatrimonio({Key? key}) : super(key: key);

  @override
  _ResumoPatrimonioState createState() => _ResumoPatrimonioState();
}

class _ResumoPatrimonioState extends State<ResumoPatrimonio> {
  String descartado = '0';  // Declarado como String
  String emprestado = '0';  // Declarado como String
  String usando = '0';      // Declarado como String
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResumoPatrimonio();
  }

 Future<void> _fetchResumoPatrimonio() async {
  const String url = "http://localhost/server/processa_bdCeet.php";
  final Map<String, dynamic> data = {'acao': 'buscaResumoPatrimonio'};

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        setState(() {
          // Converta para String se necessário, mas verifique o tipo antes de usá-lo
          descartado = responseData['data']['descartado'].toString(); // Garantir que é String
          emprestado = responseData['data']['Emprestado'].toString(); // Garantir que é String
          usando = responseData['data']['Usando'].toString(); // Garantir que é String
          isLoading = false;
        });
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('Erro ao comunicar com o servidor.');
    }
  } catch (e) {
    print('Erro: $e');
    setState(() {
      isLoading = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Resumo de Patrimônio',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
       
          child: _buildResumoCard(
            context,
            'Patrimônio em Uso',
            usando,
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(height: 20),
        Container(
         
          child: _buildResumoCard(
            context,
            'Patrimônio Emprestado',
            emprestado,
            Colors.orange,
            Icons.group,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          
          child: _buildResumoCard(
            context,
            'Patrimônio Descartado',
            descartado,
            Colors.black,
            Icons.delete_forever,
          ),
        ),
      ],
    ),
  );
}
Widget _buildResumoCard(
  BuildContext context,
  String title,
  String value,  // Modificado para aceitar String
  Color color,
  IconData icon,
) {
  return Card(
    color: Colors.white, // Define o fundo do card como branco
    elevation: 4, // Adiciona uma leve sombra para destacar o card
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Cantos arredondados para o card
    ),
    child: ListTile(
      leading: Icon(icon, color: color, size: 40),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: color, // Cor do texto correspondente ao parâmetro `color`
        ),
      ),
      trailing: Text(
        value, // Exibindo como string
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: color, // Cor do texto correspondente ao parâmetro `color`
        ),
      ),
    ),
  );
}
}