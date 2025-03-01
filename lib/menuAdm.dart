import 'dart:convert';
import 'package:ceetpatrimonio/modelo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart'; // Import da tela de login
import 'busca.dart';
import 'inserir.dart';
import 'excluir.dart';
import 'inserirFuncionario.dart';
import 'package:http/http.dart' as http;

import 'movimentacaoPatrimonio.dart';

class MenuAdm extends StatelessWidget {
  const MenuAdm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue, // Cor do ícone selecionado
          unselectedItemColor: Colors.grey, // Cor do ícone não selecionado
          //backgroundColor: Colors.white, // Fundo da barra de navegação
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
    const Modelo(),
    const Busca(),
    const Movimentacaopatrimonio(),
    InserirFuncionario(),
    const Excluir(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(//RETA SUPERIOR 
        /*title: const Text('Menu Administrador'),
        backgroundColor: Colors.white, // Fundo branco para a AppBar
        foregroundColor: Colors.black, // Cor do texto e ícones
        elevation: 4, // Sombra sutil*/
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
            icon: Icon(Icons.add),
            label: 'Inserir Modelo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Consulta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Movimentar Patrimonio',
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
        margin: const EdgeInsets.only(bottom: 45), // Ajuste de posição
        child: FloatingActionButton(
          backgroundColor: Colors.red, // Cor de destaque para o botão de saída
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
  String descartado = '0';
  String emprestado = '0';
  String usando = '0';
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
            descartado = responseData['data']['descartado'].toString();
            emprestado = responseData['data']['Emprestado'].toString();
            usando = responseData['data']['Usando'].toString();
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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Resumo de Patrimônio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildResumoCard(
            'Patrimônio Alocado',
            usando,
            Colors.green,
            Icons.check_circle,
          ),
          const SizedBox(height: 20),
          _buildResumoCard(
            'Patrimônio Realocado (Emprestado)',
            emprestado,
            Colors.orange,
            Icons.group,
          ),
          const SizedBox(height: 20),
          _buildResumoCard(
            'Patrimônio Descartado',
            descartado,
            Colors.red,
            Icons.delete_forever,
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}